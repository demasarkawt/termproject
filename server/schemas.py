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
class PlaceCreate(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    category: Optional[str] = None
    rating: Optional[float] = 0.0
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    is_premium: bool = False
    city_id: int

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


# ───────── Auth ─────────
class MediaItemCreate(BaseModel):
    name: str
    data_url: str
    folder: Optional[str] = None

class MediaItemOut(BaseModel):
    id: int
    name: str
    data_url: str
    folder: Optional[str]
    created_at: Optional[datetime]

    class Config:
        from_attributes = True

class LoginResponse(BaseModel):
    user: UserOut
    access_token: str
    token_type: str = "bearer"


# ───────── Event ─────────
class EventCreate(BaseModel):
    title: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    event_type: Optional[str] = None
    location: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None

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
