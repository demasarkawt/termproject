from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

import models, schemas
from database import get_db

router = APIRouter(prefix="/api/media", tags=["Media"])


@router.get("/", response_model=List[schemas.MediaItemOut])
def list_media(folder: str = None, db: Session = Depends(get_db)):
    query = db.query(models.MediaItem)
    if folder:
        query = query.filter(models.MediaItem.folder == folder)
    return query.order_by(models.MediaItem.created_at.desc()).all()


@router.post("/", response_model=schemas.MediaItemOut, status_code=201)
def upload_media(data: schemas.MediaItemCreate, db: Session = Depends(get_db)):
    item = models.MediaItem(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.delete("/{item_id}", status_code=204)
def delete_media(item_id: int, db: Session = Depends(get_db)):
    item = db.query(models.MediaItem).filter(models.MediaItem.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Media item not found")
    db.delete(item)
    db.commit()
