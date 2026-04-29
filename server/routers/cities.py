from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session
from typing import List, Optional

import models
import schemas
import r2_client
from auth import require_admin
from database import get_db

router = APIRouter(prefix="/api/cities", tags=["Cities"])


# ─── Read ────────────────────────────────────────────────────────────────────
@router.get("/", response_model=List[schemas.CityOut])
def get_all_cities(db: Session = Depends(get_db)):
    """Return a list of all cities in Kurdistan."""
    return db.query(models.City).order_by(models.City.id.asc()).all()


@router.get("/{city_id}", response_model=schemas.CityOut)
def get_city(city_id: int, db: Session = Depends(get_db)):
    city = db.query(models.City).filter(models.City.id == city_id).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")
    return city


@router.get("/{city_id}/places", response_model=List[schemas.PlaceOut])
def get_places_by_city(city_id: int, db: Session = Depends(get_db)):
    return (
        db.query(models.Place)
        .filter(models.Place.city_id == city_id)
        .order_by(models.Place.id.asc())
        .all()
    )


# ─── Write (admin) ───────────────────────────────────────────────────────────
@router.post(
    "/",
    response_model=schemas.CityOut,
    status_code=201,
    dependencies=[Depends(require_admin)],
)
def create_city(data: schemas.CityCreate, db: Session = Depends(get_db)):
    if db.query(models.City).filter(models.City.name == data.name).first():
        raise HTTPException(status_code=400, detail="City with that name already exists")
    city = models.City(**data.model_dump())
    db.add(city)
    db.commit()
    db.refresh(city)
    return city


@router.patch(
    "/{city_id}",
    response_model=schemas.CityOut,
    dependencies=[Depends(require_admin)],
)
def update_city(city_id: int, data: schemas.CityUpdate, db: Session = Depends(get_db)):
    city = db.query(models.City).filter(models.City.id == city_id).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(city, k, v)
    db.commit()
    db.refresh(city)
    return city


@router.delete(
    "/{city_id}",
    status_code=204,
    dependencies=[Depends(require_admin)],
)
def delete_city(city_id: int, db: Session = Depends(get_db)):
    city = db.query(models.City).filter(models.City.id == city_id).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")
    # Best-effort R2 cleanup for the city's gallery.
    if r2_client.is_configured():
        for img in list(city.images):
            if img.r2_key:
                try:
                    r2_client.delete_object(img.r2_key)
                except RuntimeError:
                    pass
    db.delete(city)
    db.commit()


# ─── City image gallery ──────────────────────────────────────────────────────
@router.get("/{city_id}/images", response_model=List[schemas.ImageOut])
def list_city_images(city_id: int, db: Session = Depends(get_db)):
    city = db.query(models.City).filter(models.City.id == city_id).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")
    return city.images


@router.post(
    "/{city_id}/images",
    response_model=List[schemas.ImageOut],
    status_code=201,
    dependencies=[Depends(require_admin)],
)
async def upload_city_images(
    city_id: int,
    files: List[UploadFile] = File(..., description="One or more image files"),
    db: Session = Depends(get_db),
):
    city = db.query(models.City).filter(models.City.id == city_id).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")
    if not r2_client.is_configured():
        raise HTTPException(status_code=503, detail="R2 is not configured")

    existing_max = max(
        (img.sort_order for img in city.images), default=-1
    )
    has_cover = any(img.is_cover for img in city.images)

    created: List[models.CityImage] = []
    for idx, upload in enumerate(files, start=1):
        key = r2_client.build_key(
            upload.filename or "image",
            folder=f"cities/{city_id}",
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

        img = models.CityImage(
            city_id=city.id,
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
    # If this was the first cover, mirror it onto City.image_url for compatibility.
    cover = next((i for i in created if i.is_cover), None)
    if cover and not city.image_url:
        city.image_url = cover.url
        db.commit()
    return created


@router.post(
    "/{city_id}/images/from-media",
    response_model=List[schemas.ImageOut],
    status_code=201,
    dependencies=[Depends(require_admin)],
)
def attach_city_images_from_media(
    city_id: int,
    data: schemas.AttachGalleryFromMedia,
    db: Session = Depends(get_db),
):
    city = db.query(models.City).filter(models.City.id == city_id).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")

    uniq = list(dict.fromkeys(data.media_ids))
    existing_max = max((img.sort_order for img in city.images), default=-1)
    has_cover = any(img.is_cover for img in city.images)
    existing_urls = {img.url for img in city.images}

    created: List[models.CityImage] = []
    seq = existing_max
    for media_id in uniq:
        row = db.query(models.MediaItem).filter(models.MediaItem.id == media_id).first()
        if not row:
            raise HTTPException(status_code=404, detail=f"Media item {media_id} not found")
        url = (row.data_url or "").strip()
        if not url:
            raise HTTPException(status_code=400, detail=f"Media item {media_id} has empty URL")
        if len(url) > 500:
            raise HTTPException(
                status_code=400,
                detail=f"Media item {media_id}: URL exceeds 500 characters.",
            )
        if url in existing_urls:
            continue
        existing_urls.add(url)
        seq += 1
        img = models.CityImage(
            city_id=city.id,
            url=url,
            r2_key=None,
            is_cover=(not has_cover),
            sort_order=seq,
            content_type=row.content_type,
            size_bytes=row.size_bytes,
        )
        db.add(img)
        created.append(img)
        if img.is_cover:
            has_cover = True

    if not created:
        return []

    db.commit()
    for img in created:
        db.refresh(img)

    cover = next((i for i in created if i.is_cover), None)
    if cover and not city.image_url:
        city.image_url = cover.url
        db.commit()

    return created


@router.patch(
    "/{city_id}/images/{image_id}",
    response_model=schemas.ImageOut,
    dependencies=[Depends(require_admin)],
)
def update_city_image(
    city_id: int,
    image_id: int,
    data: schemas.ImageUpdate,
    db: Session = Depends(get_db),
):
    img = (
        db.query(models.CityImage)
        .filter(
            models.CityImage.id == image_id,
            models.CityImage.city_id == city_id,
        )
        .first()
    )
    if not img:
        raise HTTPException(status_code=404, detail="Image not found")

    if data.is_cover is True:
        # Demote any other cover for this city.
        db.query(models.CityImage).filter(
            models.CityImage.city_id == city_id,
            models.CityImage.id != image_id,
        ).update({"is_cover": False})
        img.is_cover = True
        img.place if False else None  # noop guard
        # Mirror to City.image_url for compatibility.
        city = db.query(models.City).filter(models.City.id == city_id).first()
        if city:
            city.image_url = img.url
    elif data.is_cover is False:
        img.is_cover = False

    if data.sort_order is not None:
        img.sort_order = data.sort_order

    db.commit()
    db.refresh(img)
    return img


@router.delete(
    "/{city_id}/images/{image_id}",
    status_code=204,
    dependencies=[Depends(require_admin)],
)
def delete_city_image(city_id: int, image_id: int, db: Session = Depends(get_db)):
    img = (
        db.query(models.CityImage)
        .filter(
            models.CityImage.id == image_id,
            models.CityImage.city_id == city_id,
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
            db.query(models.CityImage)
            .filter(models.CityImage.city_id == city_id)
            .order_by(models.CityImage.sort_order.asc())
            .first()
        )
        if next_img:
            next_img.is_cover = True
            city = db.query(models.City).filter(models.City.id == city_id).first()
            if city:
                city.image_url = next_img.url
            db.commit()
