from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

import models, schemas
from database import get_db

router = APIRouter(prefix="/api/places", tags=["Places"])


@router.get("/", response_model=List[schemas.PlaceOut])
def get_all_places(
    category: Optional[str] = Query(None, description="Filter by category e.g. NATURE, CULTURE, FOOD"),
    city_id: Optional[int] = Query(None, description="Filter by city"),
    limit: int = Query(20, le=100),
    db: Session = Depends(get_db),
):
    """Return all places, with optional category and city filters."""
    query = db.query(models.Place)
    if category:
        query = query.filter(models.Place.category == category.upper())
    if city_id:
        query = query.filter(models.Place.city_id == city_id)
    return query.limit(limit).all()


@router.get("/trending", response_model=List[schemas.PlaceOut])
def get_trending_places(db: Session = Depends(get_db)):
    """Return top-rated places."""
    places = (
        db.query(models.Place)
        .order_by(models.Place.rating.desc())
        .limit(10)
        .all()
    )
    return places


@router.get("/{place_id}", response_model=schemas.PlaceOut)
def get_place(place_id: int, db: Session = Depends(get_db)):
    """Return a single place by ID."""
    place = db.query(models.Place).filter(models.Place.id == place_id).first()
    if not place:
        raise HTTPException(status_code=404, detail="Place not found")
    return place
