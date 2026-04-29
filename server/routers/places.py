from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy.orm import Session
from typing import List, Optional

import models
import schemas
import r2_client
from auth import require_admin
from database import get_db

router = APIRouter(prefix="/api/places", tags=["Places"])


# ─── Read ────────────────────────────────────────────────────────────────────
@router.get("/", response_model=List[schemas.PlaceOut])
def get_all_places(
    category: Optional[str] = Query(None, description="CULTURE | NATURE | ADVENTURE | FOOD | MALL"),
    city_id: Optional[int] = Query(None),
    has_coords: Optional[bool] = Query(None),
    limit: int = Query(100, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    query = db.query(models.Place)
    if category:
        query = query.filter(models.Place.category == category.upper())
    if city_id:
        query = query.filter(models.Place.city_id == city_id)
    if has_coords:
        query = query.filter(
            models.Place.latitude.isnot(None),
            models.Place.longitude.isnot(None),
        )
    return (
        query.order_by(models.Place.id.asc())
        .offset(offset)
        .limit(limit)
        .all()
    )


@router.get("/trending", response_model=List[schemas.PlaceOut])
def get_trending_places(db: Session = Depends(get_db)):
    return (
        db.query(models.Place)
        .order_by(models.Place.rating.desc())
        .limit(10)
        .all()
    )


@router.get("/{place_id}", response_model=schemas.PlaceOut)
def get_place(place_id: int, db: Session = Depends(get_db)):
    place = db.query(models.Place).filter(models.Place.id == place_id).first()
    if not place:
        raise HTTPException(status_code=404, detail="Place not found")
    return place


# ─── Write (admin) ───────────────────────────────────────────────────────────
@router.post(
    "/",
    response_model=schemas.PlaceOut,
    status_code=201,
    dependencies=[Depends(require_admin)],
)
def create_place(data: schemas.PlaceCreate, db: Session = Depends(get_db)):
    city = db.query(models.City).filter(models.City.id == data.city_id).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")
    place = models.Place(**data.model_dump())
    db.add(place)
    db.commit()
    db.refresh(place)
    return place


@router.patch(
    "/{place_id}",
    response_model=schemas.PlaceOut,
    dependencies=[Depends(require_admin)],
)
def update_place(place_id: int, data: schemas.PlaceUpdate, db: Session = Depends(get_db)):
    place = db.query(models.Place).filter(models.Place.id == place_id).first()
    if not place:
        raise HTTPException(status_code=404, detail="Place not found")
    payload = data.model_dump(exclude_unset=True)
    if "city_id" in payload:
        city = db.query(models.City).filter(models.City.id == payload["city_id"]).first()
        if not city:
            raise HTTPException(status_code=404, detail="City not found")
    for k, v in payload.items():
        setattr(place, k, v)
    db.commit()
    db.refresh(place)
    return place


@router.delete(
    "/{place_id}",
    status_code=204,
    dependencies=[Depends(require_admin)],
)
def delete_place(place_id: int, db: Session = Depends(get_db)):
    place = db.query(models.Place).filter(models.Place.id == place_id).first()
    if not place:
        raise HTTPException(status_code=404, detail="Place not found")
    if r2_client.is_configured():
        for img in list(place.images):
            if img.r2_key:
                try:
                    r2_client.delete_object(img.r2_key)
                except RuntimeError:
                    pass
    db.delete(place)
    db.commit()


# ─── Place image gallery ─────────────────────────────────────────────────────
@router.get("/{place_id}/images", response_model=List[schemas.ImageOut])
def list_place_images(place_id: int, db: Session = Depends(get_db)):
    place = db.query(models.Place).filter(models.Place.id == place_id).first()
    if not place:
        raise HTTPException(status_code=404, detail="Place not found")
    return place.images


@router.post(
    "/{place_id}/images",
    response_model=List[schemas.ImageOut],
    status_code=201,
    dependencies=[Depends(require_admin)],
)
async def upload_place_images(
    place_id: int,
    files: List[UploadFile] = File(..., description="One or more image files"),
    db: Session = Depends(get_db),
):
    place = db.query(models.Place).filter(models.Place.id == place_id).first()
    if not place:
        raise HTTPException(status_code=404, detail="Place not found")
    if not r2_client.is_configured():
        raise HTTPException(status_code=503, detail="R2 is not configured")

    existing_max = max(
        (img.sort_order for img in place.images), default=-1
    )
    has_cover = any(img.is_cover for img in place.images)

    created: List[models.PlaceImage] = []
    for idx, upload in enumerate(files, start=1):
        key = r2_client.build_key(
            upload.filename or "image",
            folder=f"places/{place_id}",
        )
        try:
            r2_client.upload_fileobj(
                fileobj=upload.file,
                key=key,
                content_type=upload.content_type,
            )
            url = r2_client.url_for(key)
        except RuntimeError as exc:
            for img in created:
                try:
                    r2_client.delete_object(img.r2_key)
                except RuntimeError:
                    pass
            raise HTTPException(status_code=502, detail=str(exc))

        size_bytes: Optional[int] = None
        try:
            upload.file.seek(0, 2)
            size_bytes = upload.file.tell()
        except Exception:
            size_bytes = None

        img = models.PlaceImage(
            place_id=place.id,
            url=url,
            r2_key=key,
            is_cover=(not has_cover and idx == 1),
            sort_order=existing_max + idx,
            content_type=upload.content_type,
            size_bytes=size_bytes,
        )
        db.add(img)
        created.append(img)
        if not has_cover and idx == 1:
            has_cover = True

    db.commit()
    for img in created:
        db.refresh(img)

    cover = next((i for i in created if i.is_cover), None)
    if cover and not place.image_url:
        place.image_url = cover.url
        db.commit()
    return created


@router.patch(
    "/{place_id}/images/{image_id}",
    response_model=schemas.ImageOut,
    dependencies=[Depends(require_admin)],
)
def update_place_image(
    place_id: int,
    image_id: int,
    data: schemas.ImageUpdate,
    db: Session = Depends(get_db),
):
    img = (
        db.query(models.PlaceImage)
        .filter(
            models.PlaceImage.id == image_id,
            models.PlaceImage.place_id == place_id,
        )
        .first()
    )
    if not img:
        raise HTTPException(status_code=404, detail="Image not found")

    if data.is_cover is True:
        db.query(models.PlaceImage).filter(
            models.PlaceImage.place_id == place_id,
            models.PlaceImage.id != image_id,
        ).update({"is_cover": False})
        img.is_cover = True
        place = db.query(models.Place).filter(models.Place.id == place_id).first()
        if place:
            place.image_url = img.url
    elif data.is_cover is False:
        img.is_cover = False

    if data.sort_order is not None:
        img.sort_order = data.sort_order

    db.commit()
    db.refresh(img)
    return img


@router.delete(
    "/{place_id}/images/{image_id}",
    status_code=204,
    dependencies=[Depends(require_admin)],
)
def delete_place_image(place_id: int, image_id: int, db: Session = Depends(get_db)):
    img = (
        db.query(models.PlaceImage)
        .filter(
            models.PlaceImage.id == image_id,
            models.PlaceImage.place_id == place_id,
        )
        .first()
    )
    if not img:
        raise HTTPException(status_code=404, detail="Image not found")
    if img.r2_key and r2_client.is_configured():
        try:
            r2_client.delete_object(img.r2_key)
        except RuntimeError:
            pass
    was_cover = img.is_cover
    db.delete(img)
    db.commit()
    if was_cover:
        next_img = (
            db.query(models.PlaceImage)
            .filter(models.PlaceImage.place_id == place_id)
            .order_by(models.PlaceImage.sort_order.asc())
            .first()
        )
        if next_img:
            next_img.is_cover = True
            place = db.query(models.Place).filter(models.Place.id == place_id).first()
            if place:
                place.image_url = next_img.url
            db.commit()
