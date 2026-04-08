import hashlib
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

import models, schemas
from database import get_db

router = APIRouter(prefix="/api/users", tags=["Users"])


from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def _hash_password(password: str) -> str:
    """Hash password using bcrypt."""
    return pwd_context.hash(password)

def _verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify plain password against hashed password."""
    return pwd_context.verify(plain_password, hashed_password)


@router.post("/register", response_model=schemas.UserOut, status_code=201)
def register_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    """Register a new user account."""
    existing = db.query(models.User).filter(models.User.email == user.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    new_user = models.User(
        name=user.name,
        email=user.email,
        hashed_password=_hash_password(user.password),
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@router.post("/login", response_model=schemas.UserOut)
def login_user(user: schemas.UserLogin, db: Session = Depends(get_db)):
    """Login a user and return the user profile. In a real app we would return a JWT."""
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if not db_user:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    if not _verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    return db_user


@router.get("/{user_id}", response_model=schemas.UserOut)
def get_user(user_id: int, db: Session = Depends(get_db)):
    """Return user profile by ID."""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.get("/{user_id}/trips", response_model=List[schemas.TripOut])
def get_user_trips(user_id: int, db: Session = Depends(get_db)):
    """Return all trips for a given user."""
    trips = db.query(models.Trip).filter(models.Trip.user_id == user_id).all()
    return trips


@router.post("/{user_id}/trips", response_model=schemas.TripOut, status_code=201)
def create_trip(user_id: int, trip: schemas.TripCreate, db: Session = Depends(get_db)):
    """Create a new trip for the user."""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    new_trip = models.Trip(
        title=trip.title,
        start_date=trip.start_date,
        end_date=trip.end_date,
        user_id=user_id,
    )
    db.add(new_trip)
    db.commit()
    db.refresh(new_trip)
    return new_trip


@router.post("/{user_id}/save/{place_id}", status_code=201)
def save_place(user_id: int, place_id: int, db: Session = Depends(get_db)):
    """Save a place to user's collection."""
    existing = db.query(models.SavedPlace).filter(
        models.SavedPlace.user_id == user_id,
        models.SavedPlace.place_id == place_id,
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Place already saved")
    saved = models.SavedPlace(user_id=user_id, place_id=place_id)
    db.add(saved)
    db.commit()
    return {"message": "Place saved successfully"}


@router.get("/{user_id}/saved", response_model=List[schemas.PlaceOut])
def get_saved_places(user_id: int, db: Session = Depends(get_db)):
    """Return all places saved by a user."""
    saved = db.query(models.SavedPlace).filter(models.SavedPlace.user_id == user_id).all()
    return [s.place for s in saved]
