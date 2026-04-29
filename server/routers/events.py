from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

import models
import schemas
from auth import require_admin
from database import get_db

router = APIRouter(prefix="/api/events", tags=["Events"])


@router.get("/", response_model=List[schemas.EventOut])
def get_all_events(
    event_type: Optional[str] = Query(None, description="MUSIC | FOOD | CULTURE"),
    db: Session = Depends(get_db),
):
    query = db.query(models.Event)
    if event_type:
        query = query.filter(models.Event.event_type == event_type.upper())
    return query.order_by(models.Event.id.asc()).all()


@router.get("/{event_id}", response_model=schemas.EventOut)
def get_event(event_id: int, db: Session = Depends(get_db)):
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event


@router.post(
    "/",
    response_model=schemas.EventOut,
    status_code=201,
    dependencies=[Depends(require_admin)],
)
def create_event(data: schemas.EventCreate, db: Session = Depends(get_db)):
    event = models.Event(**data.model_dump())
    db.add(event)
    db.commit()
    db.refresh(event)
    return event


@router.patch(
    "/{event_id}",
    response_model=schemas.EventOut,
    dependencies=[Depends(require_admin)],
)
def update_event(event_id: int, data: schemas.EventUpdate, db: Session = Depends(get_db)):
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(event, k, v)
    db.commit()
    db.refresh(event)
    return event


@router.delete(
    "/{event_id}",
    status_code=204,
    dependencies=[Depends(require_admin)],
)
def delete_event(event_id: int, db: Session = Depends(get_db)):
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    db.delete(event)
    db.commit()
