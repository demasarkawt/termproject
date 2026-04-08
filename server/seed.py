"""
seed.py — Populates the database with initial Kurdistan Go data.
Run once after you have your DATABASE_URL set:
    python seed.py
"""
import os
from sqlalchemy.orm import Session
from dotenv import load_dotenv

load_dotenv()

from database import engine, SessionLocal, Base
import models

def run_seed():
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()

    # ── Seed Cities ──────────────────────────────────────────────────────────────
    cities_data = [
        {"name": "Erbil",         "description": "Capital of Kurdistan Region", "latitude": 36.1911, "longitude": 44.0092},
        {"name": "Sulaymaniyah",  "description": "Cultural and artistic hub",   "latitude": 35.5571, "longitude": 45.4348},
        {"name": "Duhok",         "description": "Gateway to mountain nature",  "latitude": 36.8664, "longitude": 42.9827},
        {"name": "Halabja",       "description": "City of peace and beauty",    "latitude": 35.1782, "longitude": 45.9888},
    ]

    city_objects = []
    for c in cities_data:
        existing = db.query(models.City).filter(models.City.name == c["name"]).first()
        if not existing:
            obj = models.City(**c)
            db.add(obj)
            db.flush()
            city_objects.append(obj)
        else:
            city_objects.append(existing)

    db.commit()
    print(f"✅ Cities seeded: {[c.name for c in city_objects]}")

    # ── Seed Places ──────────────────────────────────────────────────────────────
    places_data = [
        {"name": "Erbil Citadel",   "description": "UNESCO World Heritage Site, one of the oldest continuously inhabited places on Earth.", "category": "CULTURE", "rating": 4.9, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.1909, "longitude": 44.0092},
        {"name": "Rawanduz Canyon",  "description": "Breathtaking geological wonder with winding roads and emerald rivers.", "category": "NATURE",  "rating": 4.8, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.6100, "longitude": 44.5200},
        {"name": "Bekhal Falls",     "description": "Beautiful waterfall near Soran region — free access.", "category": "NATURE",  "rating": 4.7, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.6390, "longitude": 44.5453},
        {"name": "Mount Korek",      "description": "Summer escape and winter skiing destination.", "category": "ADVENTURE", "rating": 4.8, "is_premium": True,  "city_id": city_objects[0].id, "latitude": 36.7000, "longitude": 44.3200},
        {"name": "Shanidar Cave",    "description": "Historic archaeological site with Neanderthal findings.", "category": "CULTURE", "rating": 4.6, "is_premium": False, "city_id": city_objects[2].id, "latitude": 36.8300, "longitude": 44.2200},
        {"name": "Dukan Lake",       "description": "Stunning lake popular for boat trips and picnics.", "category": "NATURE",  "rating": 4.7, "is_premium": False, "city_id": city_objects[1].id, "latitude": 35.9500, "longitude": 44.9500},
    ]

    for p in places_data:
        existing = db.query(models.Place).filter(models.Place.name == p["name"]).first()
        if not existing:
            db.add(models.Place(**p))

    db.commit()
    print(f"✅ Places seeded: {len(places_data)} records")

    # ── Seed Events ──────────────────────────────────────────────────────────────
    events_data = [
        {"title": "Citadel Flavors Expo",  "description": "A two-day sensory journey through Kurdish recipes at the heart of Erbil.", "event_type": "FOOD",    "location": "Erbil Citadel",      "start_date": "2024-09-20", "end_date": "2024-09-21"},
        {"title": "Mountain Melodies",     "description": "Traditional Kurdish instruments meet modern jazz under the stars.",        "event_type": "MUSIC",   "location": "Sulaymaniyah",       "start_date": "2024-10-05", "end_date": "2024-10-06"},
        {"title": "Pomegranate Festival",  "description": "Annual harvest celebration in the valleys of Kurdistan.",                  "event_type": "CULTURE", "location": "Halabja",            "start_date": "2024-11-01", "end_date": "2024-11-03"},
        {"title": "Newroz Fire Festival",  "description": "Ancient fire festivals of Newroz across all regions.",                     "event_type": "CULTURE", "location": "All Cities",         "start_date": "2025-03-21", "end_date": "2025-03-22"},
    ]

    for e in events_data:
        existing = db.query(models.Event).filter(models.Event.title == e["title"]).first()
        if not existing:
            db.add(models.Event(**e))

    db.commit()
    print(f"✅ Events seeded: {len(events_data)} records")

    db.close()
    print("\n🌿 Database seeding complete! Kurdistan Go is ready.")
    return True

if __name__ == "__main__":
    run_seed()
