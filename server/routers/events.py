from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

import models, schemas
from database import get_db

router = APIRouter(prefix="/api/events", tags=["Events"])


@router.get("/", response_model=List[schemas.EventOut])
def get_all_events(
    event_type: Optional[str] = Query(None, description="Filter by type: MUSIC, FOOD, CULTURE"),
    db: Session = Depends(get_db),
):
    """Return all upcoming events."""
    query = db.query(models.Event)
    if event_type:
        query = query.filter(models.Event.event_type == event_type.upper())
    return query.all()


@router.get("/{event_id}", response_model=schemas.EventOut)
def get_event(event_id: int, db: Session = Depends(get_db)):
    """Return a single event by ID."""
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event


@router.post("/", response_model=schemas.EventOut, status_code=201)
def create_event(data: schemas.EventCreate, db: Session = Depends(get_db)):
    """Create a new event."""
    event = models.Event(**data.model_dump())
    db.add(event)
    db.commit()
    db.refresh(event)
    return event


@router.delete("/{event_id}", status_code=204)
def delete_event(event_id: int, db: Session = Depends(get_db)):
    """Delete an event by ID."""
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    db.delete(event)
    db.commit()
