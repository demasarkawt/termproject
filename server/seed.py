"""
seed.py — Populates the database with initial Kurdistan Go data.
Run once after you have your DATABASE_URL set:
    python seed.py
"""
import logging
import os

from sqlalchemy.orm import Session
from dotenv import load_dotenv

load_dotenv()

from database import engine, SessionLocal, Base
import models
import wiki_images

_log = logging.getLogger(__name__)


def _wiki_seed_enabled() -> bool:
    raw = os.getenv("WIKI_SEED_IMAGES", "true").strip().lower()
    return raw not in {"0", "false", "no", "off"}


def _attach_wiki_image(
    db: Session,
    *,
    image_model,
    parent_attr: str,
    parent_id: int,
    title: str,
    folder: str,
    log_prefix: str,
):
    """Best-effort: download a Wikipedia thumbnail and persist it as the
    cover image. Silently skips when R2 isn't configured or the lookup
    fails — the bundled assets keep the apps usable."""
    if not _wiki_seed_enabled():
        return
    existing = (
        db.query(image_model)
        .filter(getattr(image_model, parent_attr) == parent_id)
        .count()
    )
    if existing > 0:
        return
    try:
        result = wiki_images.upload_to_r2(title, folder=folder)
    except Exception as exc:
        _log.warning("%s wiki upload failed for %s: %s", log_prefix, title, exc)
        return
    if result is None:
        return
    public_url, key, size, content_type = result
    db.add(
        image_model(
            **{parent_attr: parent_id},
            url=public_url,
            r2_key=key,
            is_cover=True,
            sort_order=0,
            content_type=content_type,
            size_bytes=size,
        )
    )

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
            _attach_wiki_image(
                db,
                image_model=models.CityImage,
                parent_attr="city_id",
                parent_id=obj.id,
                title=obj.name,
                folder=f"cities/{obj.id}",
                log_prefix="city",
            )
            city_objects.append(obj)
        else:
            city_objects.append(existing)

    db.commit()
    print(f"[seed] Cities seeded: {[c.name for c in city_objects]}")

    # ── Seed Places ──────────────────────────────────────────────────────────────
    places_data = [
        # Erbil City Places
        {"name": "Erbil Citadel", "description": "A UNESCO World Heritage Site and one of the oldest continuously inhabited cities in the world. Enjoy panoramic views of Erbil from its ancient walls.", "category": "CULTURE", "rating": 4.9, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.1909, "longitude": 44.0092},
        {"name": "Qaysari Bazaar", "description": "Erbil's traditional covered market, perfect for experiencing local culture, buying Kurdish textiles, spices, and drinking traditional tea.", "category": "CULTURE", "rating": 4.8, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.1887, "longitude": 44.0086},
        {"name": "Geli Ali Beg Waterfall", "description": "The highest waterfall in Kurdistan and the Middle East, so iconic it is featured on the 5,000 Iraqi dinar banknote.", "category": "NATURE", "rating": 4.9, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.6340, "longitude": 44.4230},
        {"name": "Mount Korek Resort", "description": "A spectacular mountain resort accessible by a 4km cable car. Ideal for summer retreats and winter skiing.", "category": "ADVENTURE", "rating": 4.8, "is_premium": True, "city_id": city_objects[0].id, "latitude": 36.5833, "longitude": 44.4667},
        {"name": "Bekhal Waterfall", "description": "A beautiful and powerful natural waterfall near Soran where you can dine outdoors directly next to the rushing water.", "category": "NATURE", "rating": 4.7, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.6358, "longitude": 44.5381},
        {"name": "Shaqlawa Resort", "description": "A beautiful town nestled at the base of Mount Safeen, known for its cooler climate, lush orchards, and local markets selling honey and dried fruits.", "category": "NATURE", "rating": 4.6, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.4022, "longitude": 44.3314},
        
        # Sulaymaniyah City Places
        {"name": "Amna Suraka (Red House)", "description": "The former intelligence headquarters during Saddam Hussein's regime, now a sobering but essential museum documenting Kurdish history and resilience.", "category": "CULTURE", "rating": 4.9, "is_premium": False, "city_id": city_objects[1].id, "latitude": 35.5681, "longitude": 45.4328},
        {"name": "Sulaymaniyah National Museum", "description": "The second-largest museum in Iraq, housing a massive collection of artifacts from the Paleolithic era, Sumerian, and Ottoman periods.", "category": "CULTURE", "rating": 4.8, "is_premium": False, "city_id": city_objects[1].id, "latitude": 35.5583, "longitude": 45.4267},
        {"name": "Dukan Lake", "description": "The largest lake in the Kurdistan Region, offering beautiful turquoise waters, boating, and scenic picnic spots.", "category": "NATURE", "rating": 4.7, "is_premium": False, "city_id": city_objects[1].id, "latitude": 35.9400, "longitude": 44.9575},
        {"name": "Goyzha Mountain", "description": "The mountain defining the skyline of Sulaymaniyah. Drive to the top at sunset for breathtaking views and bustling food stalls.", "category": "ADVENTURE", "rating": 4.8, "is_premium": False, "city_id": city_objects[1].id, "latitude": 35.5867, "longitude": 45.4294},
        {"name": "Ahmad Awa Waterfall", "description": "A stunning, multi-tiered waterfall situated in a lush, green mountain valley near the Iran border.", "category": "NATURE", "rating": 4.8, "is_premium": False, "city_id": city_objects[1].id, "latitude": 35.2917, "longitude": 46.1042},
        
        # Duhok City Places
        {"name": "Amedi (Amadiya)", "description": "A fairy-tale like 5,000-year-old town built entirely on the flat top of a mountain, rich in ancient mosques, churches, and synagogues.", "category": "CULTURE", "rating": 5.0, "is_premium": False, "city_id": city_objects[2].id, "latitude": 37.0911, "longitude": 43.4864},
        {"name": "Lalish Temple", "description": "The holiest spiritual site for the Yazidi faith, nestled in a beautiful green valley. Known for its cone-shaped domes and ancient sacred olive oil traditions. Must visit barefoot.", "category": "CULTURE", "rating": 4.9, "is_premium": False, "city_id": city_objects[2].id, "latitude": 36.7725, "longitude": 43.3006},
        {"name": "Gara Mountain", "description": "A towering mountain range providing incredible hiking opportunities and panoramic views over the valleys of Duhok.", "category": "ADVENTURE", "rating": 4.7, "is_premium": False, "city_id": city_objects[2].id, "latitude": 36.9833, "longitude": 43.3667},
        {"name": "Shanidar Cave", "description": "A vastly important prehistoric archaeological site where the remains of multiple Neanderthals were discovered, changing modern anthropology.", "category": "CULTURE", "rating": 4.7, "is_premium": False, "city_id": city_objects[2].id, "latitude": 36.8322, "longitude": 44.0322},
        
        # Halabja City Places
        {"name": "Halabja Monument", "description": "A memorial monument and museum dedicated to the victims of the 1988 chemical attack. An important site for understanding the history of the region.", "category": "CULTURE", "rating": 4.8, "is_premium": False, "city_id": city_objects[3].id, "latitude": 35.1837, "longitude": 45.9868},
        {"name": "Hawraman Region (Byara & Tawela)", "description": "Stunning mountainous border villages known for their unique terraced architecture, where the roof of one house is the yard of another.", "category": "CULTURE", "rating": 4.9, "is_premium": False, "city_id": city_objects[3].id, "latitude": 35.2344, "longitude": 46.1264},

        # Erbil City Food
        {"name": "Iskan Street", "description": "The heart of Erbil's nightlife and street food scene, packed with stalls serving kebabs, grilled meats, and local snacks late into the night.", "category": "FOOD", "rating": 4.8, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.1834, "longitude": 43.9912},
        {"name": "Mam Khalil Chaikhana", "description": "A historic, deeply authentic teahouse hidden inside the Qaysari Bazaar. The perfect spot to experience traditional tea culture.", "category": "FOOD", "rating": 4.9, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.1885, "longitude": 44.0090},

        # Sulaymaniyah City Food
        {"name": "Sardar Restaurant", "description": "Highly rated authentic Kurdish cuisine known for its incredible roasted meats and welcoming hospitality.", "category": "FOOD", "rating": 4.7, "is_premium": True, "city_id": city_objects[1].id, "latitude": 35.5650, "longitude": 45.4300},

        # Duhok City Food
        {"name": "Manqal Restaurant", "description": "A frequently recommended spot in Duhok offering beautifully grilled meats and sweeping views of the city.", "category": "FOOD", "rating": 4.6, "is_premium": True, "city_id": city_objects[2].id, "latitude": 36.8600, "longitude": 42.9900},

        # Malls (MALL category)
        {"name": "Family Mall Erbil",   "description": "Anchored by Carrefour, with cinemas, an ice rink, restaurants, and a wide international fashion mix.",                       "category": "MALL", "rating": 4.6, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.2032, "longitude": 43.9706},
        {"name": "Majidi Mall",         "description": "One of Erbil's largest shopping centers, featuring international brands, food courts, and a multiplex cinema.",                "category": "MALL", "rating": 4.5, "is_premium": False, "city_id": city_objects[0].id, "latitude": 36.2154, "longitude": 43.9909},
        {"name": "Empire Mall",         "description": "Modern mall in Empire World with luxury fashion, dining, and family entertainment.",                                          "category": "MALL", "rating": 4.5, "is_premium": True,  "city_id": city_objects[0].id, "latitude": 36.1989, "longitude": 43.9456},
        {"name": "Mazi Mall",           "description": "A Duhok favorite with a lively food court, cinemas, and a children's play area on the upper floors.",                          "category": "MALL", "rating": 4.4, "is_premium": False, "city_id": city_objects[2].id, "latitude": 36.8632, "longitude": 42.9876},
        {"name": "Goran City Mall",     "description": "Sulaymaniyah's downtown shopping hub - ideal for a rainy afternoon with fashion, electronics, and casual eateries.",            "category": "MALL", "rating": 4.3, "is_premium": False, "city_id": city_objects[1].id, "latitude": 35.5635, "longitude": 45.4296},
    ]

    place_objects = []
    for p in places_data:
        existing = db.query(models.Place).filter(models.Place.name == p["name"]).first()
        if not existing:
            obj = models.Place(**p)
            db.add(obj)
            db.flush()
            _attach_wiki_image(
                db,
                image_model=models.PlaceImage,
                parent_attr="place_id",
                parent_id=obj.id,
                title=obj.name,
                folder=f"places/{obj.id}",
                log_prefix="place",
            )
            place_objects.append(obj)
        else:
            place_objects.append(existing)

    db.commit()
    print(f"[seed] Places seeded: {len(place_objects)} records")

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
    print(f"[seed] Events seeded: {len(events_data)} records")

    # ── Mock Users, Trips, and Saved Places ──────────────────────────────────────
    from passlib.context import CryptContext
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
    
    mock_users = [
        {"name": "Aland", "email": "aland@example.com", "hashed_password": pwd_context.hash("password123"), "level": 5},
        {"name": "Zhya", "email": "zhya@example.com", "hashed_password": pwd_context.hash("password123"), "level": 12},
    ]

    user_objects = []
    for u in mock_users:
        existing = db.query(models.User).filter(models.User.email == u["email"]).first()
        if not existing:
            obj = models.User(**u)
            db.add(obj)
            db.flush()
            user_objects.append(obj)
        else:
            user_objects.append(existing)

    db.commit()
    print(f"[seed] Users seeded: {len(user_objects)} records")

    if user_objects and place_objects:
        # Mock Trips
        trips = [
            {"title": "Weekend at Shaqlawa", "start_date": "2024-05-10", "end_date": "2024-05-12", "user_id": user_objects[0].id, "status": "PLANNED"},
            {"title": "Sulaymaniyah Culture Tour", "start_date": "2024-06-01", "end_date": "2024-06-05", "user_id": user_objects[1].id, "status": "COMPLETED"},
        ]
        for t in trips:
            existing = db.query(models.Trip).filter(models.Trip.title == t["title"]).first()
            if not existing:
                db.add(models.Trip(**t))

        # Mock Saved Places
        saved_places = [
            {"user_id": user_objects[0].id, "place_id": place_objects[0].id}, # Aland saved Erbil Citadel
            {"user_id": user_objects[0].id, "place_id": place_objects[2].id}, # Aland saved Waterfall
            {"user_id": user_objects[1].id, "place_id": place_objects[6].id}, # Zhya saved Amna Suraka
        ]
        for sp in saved_places:
            existing = db.query(models.SavedPlace).filter(models.SavedPlace.user_id == sp["user_id"], models.SavedPlace.place_id == sp["place_id"]).first()
            if not existing:
                db.add(models.SavedPlace(**sp))

        db.commit()
        print("[seed] Mock Trips and Saved Places seeded.")

    db.close()
    print("[seed] Database seeding complete. Kurdistan Go is ready.")
    return True

if __name__ == "__main__":
    run_seed()
