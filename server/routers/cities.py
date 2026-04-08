from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

import models, schemas
from database import get_db

router = APIRouter(prefix="/api/cities", tags=["Cities"])


@router.get("/", response_model=List[schemas.CityOut])
def get_all_cities(db: Session = Depends(get_db)):
    """Return a list of all cities in Kurdistan."""
    cities = db.query(models.City).all()
    return cities


@router.get("/{city_id}", response_model=schemas.CityOut)
def get_city(city_id: int, db: Session = Depends(get_db)):
    """Return a single city by ID."""
    city = db.query(models.City).filter(models.City.id == city_id).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")
    return city


@router.get("/{city_id}/places", response_model=List[schemas.PlaceOut])
def get_places_by_city(city_id: int, db: Session = Depends(get_db)):
    """Return all places for a given city."""
    places = db.query(models.Place).filter(models.Place.city_id == city_id).all()
    return places
