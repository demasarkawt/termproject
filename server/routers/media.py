from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session
from typing import List, Optional

import models
import schemas
import r2_client
from auth import require_admin
from database import get_db

router = APIRouter(prefix="/api/media", tags=["Media"])


# ─── List ────────────────────────────────────────────────────────────────────
@router.get("/", response_model=List[schemas.MediaItemOut])
def list_media(folder: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(models.MediaItem)
    if folder:
        query = query.filter(models.MediaItem.folder == folder)
    return query.order_by(models.MediaItem.created_at.desc()).all()


# ─── Create from JSON (legacy: external URL or base64 data URL) ──────────────
@router.post(
    "/",
    response_model=schemas.MediaItemOut,
    status_code=201,
    dependencies=[Depends(require_admin)],
)
def create_media(data: schemas.MediaItemCreate, db: Session = Depends(get_db)):
    item = models.MediaItem(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


# ─── Upload a file directly to Cloudflare R2 ─────────────────────────────────
@router.post(
    "/upload",
    response_model=schemas.MediaItemOut,
    status_code=201,
    dependencies=[Depends(require_admin)],
)
async def upload_media(
    file: UploadFile = File(...),
    folder: Optional[str] = Form(None),
    name: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    """
    Multipart upload that streams the file to Cloudflare R2 and stores
    the resulting URL/key in the database.

    Form fields:
      - file:   the binary file (required)
      - folder: optional folder/prefix in the bucket (e.g. "places")
      - name:   optional display name; defaults to the uploaded filename
    """
    if not r2_client.is_configured():
        raise HTTPException(
            status_code=503,
            detail="R2 is not configured on the server. Set R2_* env vars.",
        )

    key = r2_client.build_key(file.filename or "file", folder)

    try:
        r2_client.upload_fileobj(
            fileobj=file.file,
            key=key,
            content_type=file.content_type,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc))

    # Resolve a URL for the client. Falls back to a presigned URL when the
    # bucket is private and R2_PUBLIC_URL is not set.
    try:
        served_url = r2_client.url_for(key)
    except RuntimeError as exc:
        # Roll back the uploaded object so we don't leak orphans.
        try:
            r2_client.delete_object(key)
        except RuntimeError:
            pass
        raise HTTPException(status_code=502, detail=str(exc))

    # Best-effort size detection.
    size_bytes: Optional[int] = None
    try:
        file.file.seek(0, 2)
        size_bytes = file.file.tell()
    except Exception:
        size_bytes = None

    item = models.MediaItem(
        name=name or file.filename or key,
        data_url=served_url,
        folder=folder,
        r2_key=key,
        content_type=file.content_type,
        size_bytes=size_bytes,
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


# ─── Presigned URL for a stored object ───────────────────────────────────────
@router.get("/{item_id}/presigned-url", response_model=schemas.PresignedUrlOut)
def get_presigned_url(item_id: int, db: Session = Depends(get_db)):
    item = db.query(models.MediaItem).filter(models.MediaItem.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Media item not found")
    if not item.r2_key:
        raise HTTPException(
            status_code=400,
            detail="This media item is not stored in R2.",
        )
    if not r2_client.is_configured():
        raise HTTPException(status_code=503, detail="R2 is not configured.")
    try:
        url = r2_client.presigned_get_url(item.r2_key)
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc))
    return schemas.PresignedUrlOut(
        url=url,
        expires_in=r2_client.R2_PRESIGN_EXPIRES,
    )


# ─── Delete (DB row + R2 object) ─────────────────────────────────────────────
@router.delete(
    "/{item_id}",
    status_code=204,
    dependencies=[Depends(require_admin)],
)
def delete_media(item_id: int, db: Session = Depends(get_db)):
    item = db.query(models.MediaItem).filter(models.MediaItem.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Media item not found")

    if item.r2_key and r2_client.is_configured():
        try:
            r2_client.delete_object(item.r2_key)
        except RuntimeError:
            # Don't block DB cleanup if R2 is unreachable; admin can purge later.
            pass

    db.delete(item)
    db.commit()
