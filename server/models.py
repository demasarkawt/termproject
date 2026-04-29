from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    level = Column(Integer, default=1)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    trips = relationship("Trip", back_populates="user")
    saved_places = relationship("SavedPlace", back_populates="user")


class City(Base):
    __tablename__ = "cities"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    places = relationship("Place", back_populates="city")
    images = relationship(
        "CityImage",
        back_populates="city",
        cascade="all, delete-orphan",
        order_by="CityImage.sort_order",
    )


class Place(Base):
    __tablename__ = "places"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    category = Column(String(50), nullable=True)   # e.g. NATURE, CULTURE, FOOD
    rating = Column(Float, default=0.0)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    is_premium = Column(Boolean, default=False)
    city_id = Column(Integer, ForeignKey("cities.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    city = relationship("City", back_populates="places")
    saved_by = relationship("SavedPlace", back_populates="place")
    images = relationship(
        "PlaceImage",
        back_populates="place",
        cascade="all, delete-orphan",
        order_by="PlaceImage.sort_order",
    )


class Trip(Base):
    __tablename__ = "trips"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    start_date = Column(String(50), nullable=True)
    end_date = Column(String(50), nullable=True)
    status = Column(String(20), default="upcoming")  # upcoming | past
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="trips")


class SavedPlace(Base):
    __tablename__ = "saved_places"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=False)
    saved_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="saved_places")
    place = relationship("Place", back_populates="saved_by")


class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    event_type = Column(String(50), nullable=True)  # MUSIC, FOOD, CULTURE
    location = Column(String(200), nullable=True)
    start_date = Column(String(50), nullable=True)
    end_date = Column(String(50), nullable=True)
    external_uid = Column(String(255), nullable=True, unique=True, index=True)
    source = Column(String(20), default="manual")  # manual | ics
    last_synced_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class PlaceImage(Base):
    __tablename__ = "place_images"

    id = Column(Integer, primary_key=True, index=True)
    place_id = Column(
        Integer,
        ForeignKey("places.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    url = Column(String(500), nullable=False)
    r2_key = Column(String(500), nullable=True)
    is_cover = Column(Boolean, default=False)
    sort_order = Column(Integer, default=0)
    content_type = Column(String(100), nullable=True)
    size_bytes = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    place = relationship("Place", back_populates="images")


class CityImage(Base):
    __tablename__ = "city_images"

    id = Column(Integer, primary_key=True, index=True)
    city_id = Column(
        Integer,
        ForeignKey("cities.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    url = Column(String(500), nullable=False)
    r2_key = Column(String(500), nullable=True)
    is_cover = Column(Boolean, default=False)
    sort_order = Column(Integer, default=0)
    content_type = Column(String(100), nullable=True)
    size_bytes = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    city = relationship("City", back_populates="images")


class SiteSettings(Base):
    __tablename__ = "site_settings"

    id = Column(Integer, primary_key=True, index=True)
    site_name = Column(String(150), default="Kurdistan Go")
    site_description = Column(Text, nullable=True)
    contact_email = Column(String(150), nullable=True)
    maintenance_mode = Column(Boolean, default=False)
    seo_keywords = Column(Text, nullable=True)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class MediaItem(Base):
    __tablename__ = "media_items"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    data_url = Column(Text, nullable=False)   # base64 data URL, https URL, or R2 public URL
    folder = Column(String(100), nullable=True)
    # R2 object key when the file is stored in Cloudflare R2; null for legacy items.
    r2_key = Column(String(500), nullable=True)
    content_type = Column(String(100), nullable=True)
    size_bytes = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
