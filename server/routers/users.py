import os
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import List
import jwt

import models, schemas
from auth import require_admin
from database import get_db

router = APIRouter(prefix="/api/users", tags=["Users"])

from passlib.context import CryptContext
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ─── JWT Config ───────────────────────────────────────────────────────────────
SECRET_KEY = os.environ.get("SECRET_KEY", "kurdistan-go-dev-secret-2024")
ALGORITHM = "HS256"
TOKEN_EXPIRE_DAYS = 7

security = HTTPBearer()


def _hash_password(password: str) -> str:
    return pwd_context.hash(password)

def _verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def _create_token(user_id: int) -> str:
    payload = {
        "sub": str(user_id),
        "exp": datetime.utcnow() + timedelta(days=TOKEN_EXPIRE_DAYS),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def _decode_token(token: str) -> int:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return int(payload["sub"])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security),
    db: Session = Depends(get_db),
) -> models.User:
    user_id = _decode_token(credentials.credentials)
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user


@router.post("/register", response_model=schemas.LoginResponse, status_code=201)
def register_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    """Register a new user and return a login token."""
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
    return {"user": new_user, "access_token": _create_token(new_user.id), "token_type": "bearer"}


@router.post("/login", response_model=schemas.LoginResponse)
def login_user(user: schemas.UserLogin, db: Session = Depends(get_db)):
    """Login and return user profile + JWT token."""
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if not db_user or not _verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return {"user": db_user, "access_token": _create_token(db_user.id), "token_type": "bearer"}


@router.get("/", response_model=List[schemas.UserOut])
def list_users(db: Session = Depends(get_db)):
    """Return all registered users (admin use)."""
    return db.query(models.User).order_by(models.User.created_at.desc()).all()


@router.patch(
    "/{user_id}/admin",
    response_model=schemas.UserOut,
    dependencies=[Depends(require_admin)],
)
def admin_update_user(
    user_id: int,
    data: schemas.UserAdminUpdate,
    db: Session = Depends(get_db),
):
    """Admin-only: change a user's level or active status."""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    payload = data.model_dump(exclude_unset=True)
    for k, v in payload.items():
        setattr(user, k, v)
    db.commit()
    db.refresh(user)
    return user


@router.get("/{user_id}", response_model=schemas.UserOut)
def get_user(
    user_id: int,
    current_user: models.User = Depends(get_current_user),
):
    """Return user profile. Only the owner can access."""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    return current_user


@router.get("/{user_id}/trips", response_model=List[schemas.TripOut])
def get_user_trips(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Return all trips for the authenticated user."""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    return db.query(models.Trip).filter(models.Trip.user_id == user_id).all()


@router.post("/{user_id}/trips", response_model=schemas.TripOut, status_code=201)
def create_trip(
    user_id: int,
    trip: schemas.TripCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Create a new trip for the authenticated user."""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
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
def save_place(
    user_id: int,
    place_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Save a place to the authenticated user's collection."""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    existing = db.query(models.SavedPlace).filter(
        models.SavedPlace.user_id == user_id,
        models.SavedPlace.place_id == place_id,
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Place already saved")
    db.add(models.SavedPlace(user_id=user_id, place_id=place_id))
    db.commit()
    return {"message": "Place saved successfully"}


@router.delete("/{user_id}/save/{place_id}")
def unsave_place(
    user_id: int,
    place_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Remove a saved place from the authenticated user's collection."""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    saved = db.query(models.SavedPlace).filter(
        models.SavedPlace.user_id == user_id,
        models.SavedPlace.place_id == place_id,
    ).first()
    if not saved:
        raise HTTPException(status_code=404, detail="Saved place not found")
    db.delete(saved)
    db.commit()
    return {"message": "Place removed from saved"}


@router.get("/{user_id}/saved", response_model=List[schemas.PlaceOut])
def get_saved_places(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Return all places saved by the authenticated user."""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    saved = db.query(models.SavedPlace).filter(models.SavedPlace.user_id == user_id).all()
    return [s.place for s in saved]
