from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime


# ───────── User ─────────
class UserBase(BaseModel):
    name: str
    email: EmailStr

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserOut(UserBase):
    id: int
    level: int
    is_active: bool
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


# ───────── City ─────────
class CityOut(BaseModel):
    id: int
    name: str
    description: Optional[str]
    image_url: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]

    class Config:
        from_attributes = True


# ───────── Place ─────────
class PlaceOut(BaseModel):
    id: int
    name: str
    description: Optional[str]
    image_url: Optional[str]
    category: Optional[str]
    rating: Optional[float]
    latitude: Optional[float]
    longitude: Optional[float]
    is_premium: bool
    city_id: int

    class Config:
        from_attributes = True


# ───────── Trip ─────────
class TripCreate(BaseModel):
    title: str
    start_date: Optional[str]
    end_date: Optional[str]

class TripOut(TripCreate):
    id: int
    status: str
    user_id: int
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


# ───────── Event ─────────
class EventOut(BaseModel):
    id: int
    title: str
    description: Optional[str]
    image_url: Optional[str]
    event_type: Optional[str]
    location: Optional[str]
    start_date: Optional[str]
    end_date: Optional[str]

    class Config:
        from_attributes = True
