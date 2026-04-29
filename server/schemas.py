from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional, List
from datetime import datetime


# ───────── Categories ─────────
PLACE_CATEGORIES = {"CULTURE", "NATURE", "ADVENTURE", "FOOD", "MALL"}


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

class UserAdminUpdate(BaseModel):
    level: Optional[int] = None
    is_active: Optional[bool] = None


# ───────── Image (gallery) ─────────
class ImageOut(BaseModel):
    id: int
    url: str
    r2_key: Optional[str] = None
    is_cover: bool = False
    sort_order: int = 0
    content_type: Optional[str] = None
    size_bytes: Optional[int] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class ImageUpdate(BaseModel):
    is_cover: Optional[bool] = None
    sort_order: Optional[int] = None


# ───────── City ─────────
class CityCreate(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class CityUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class CityOut(BaseModel):
    id: int
    name: str
    description: Optional[str]
    image_url: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]
    images: List[ImageOut] = []

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

    @field_validator("category")
    @classmethod
    def _category_valid(cls, v):
        if v is None or v == "":
            return v
        if v not in PLACE_CATEGORIES:
            raise ValueError(
                f"category must be one of {sorted(PLACE_CATEGORIES)}"
            )
        return v


class PlaceUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    category: Optional[str] = None
    rating: Optional[float] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    is_premium: Optional[bool] = None
    city_id: Optional[int] = None

    @field_validator("category")
    @classmethod
    def _category_valid(cls, v):
        if v is None or v == "":
            return v
        if v not in PLACE_CATEGORIES:
            raise ValueError(
                f"category must be one of {sorted(PLACE_CATEGORIES)}"
            )
        return v


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
    images: List[ImageOut] = []

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


# ───────── Media ─────────
class MediaItemCreate(BaseModel):
    name: str
    data_url: str
    folder: Optional[str] = None

class MediaItemOut(BaseModel):
    id: int
    name: str
    data_url: str
    folder: Optional[str]
    r2_key: Optional[str] = None
    content_type: Optional[str] = None
    size_bytes: Optional[int] = None
    created_at: Optional[datetime]

    class Config:
        from_attributes = True

class PresignedUrlOut(BaseModel):
    url: str
    expires_in: int


# ───────── Auth ─────────
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

class EventUpdate(BaseModel):
    title: Optional[str] = None
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


# ───────── Site Settings ─────────
class SiteSettingsOut(BaseModel):
    site_name: str
    site_description: Optional[str] = None
    contact_email: Optional[str] = None
    maintenance_mode: bool = False
    seo_keywords: Optional[str] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class SiteSettingsUpdate(BaseModel):
    site_name: Optional[str] = None
    site_description: Optional[str] = None
    contact_email: Optional[str] = None
    maintenance_mode: Optional[bool] = None
    seo_keywords: Optional[str] = None
