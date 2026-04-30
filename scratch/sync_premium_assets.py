import sys
import os

# Add server directory to path to import database and models
sys.path.append(os.path.join(os.getcwd(), 'server'))

from sqlalchemy.orm import Session
from database import SessionLocal, engine
import models

PREMIUM_IMAGES = {
    "Erbil Citadel": "https://upload.wikimedia.org/wikipedia/commons/c/c8/1._Erbil_Citadel%2C_Erbil_Governorate%2C_Iraqi_Kurdistan.jpg",
    "Qaysari Bazaar": "https://upload.wikimedia.org/wikipedia/commons/b/b1/VKK_5743_bazar_slemani_kurdistan_%2852386789218%29.jpg",
    "Geli Ali Beg Waterfall": "https://upload.wikimedia.org/wikipedia/commons/1/1d/20190509_145417.Gali_Ali_Bag.Erbil.Kurdistan.jpg",
    "Mount Korek Resort": "https://upload.wikimedia.org/wikipedia/commons/2/29/The_Korek_Mountain_Resort_%26_Spa.jpg",
    "Bekhal Waterfall": "https://upload.wikimedia.org/wikipedia/commons/a/ab/Bekhal_Waterfall_03.jpg",
    "Amedi (Amadiya)": "https://upload.wikimedia.org/wikipedia/commons/2/2e/173606_The_picturesque_village_of_Amedye%2C_Iraq_in_2009.jpg",
    "Hawraman Region (Byara & Tawela)": "https://upload.wikimedia.org/wikipedia/commons/1/1e/A_traditional_Hawrami_village%2C_Kurdistan.jpg",
    "Ahmad Awa Waterfall": "https://upload.wikimedia.org/wikipedia/commons/6/68/Ahmed_Awa_Waterfall%2C_Halabja%2C_Tourism.jpg",
    "Shanidar Cave": "https://upload.wikimedia.org/wikipedia/commons/e/ea/1._Shanidar_cave%2C_a_paleolithic_cave_in_Bradost_Mountain%2C_Erbil_Governorate%2C_Iraqi_Kurdistan._April_4%2C_2014.jpg",
    "Gara Mountain": "https://upload.wikimedia.org/wikipedia/commons/b/bd/Cheekhedar.jpg",
}

CITY_IMAGES = {
    "Erbil": "https://upload.wikimedia.org/wikipedia/commons/c/c8/1._Erbil_Citadel%2C_Erbil_Governorate%2C_Iraqi_Kurdistan.jpg",
    "Sulaymaniyah": "https://upload.wikimedia.org/wikipedia/commons/1/1d/Sulaymaniyah_skyline.jpg",
    "Duhok": "https://upload.wikimedia.org/wikipedia/commons/e/ed/Panorama_of_Duhok.jpg",
    "Halabja": "https://upload.wikimedia.org/wikipedia/commons/6/68/Ahmed_Awa_Waterfall%2C_Halabja%2C_Tourism.jpg",
}

def sync():
    db = SessionLocal()
    try:
        # Update Places
        for name, url in PREMIUM_IMAGES.items():
            place = db.query(models.Place).filter(models.Place.name == name).first()
            if place:
                print(f"Updating place: {name}")
                place.image_url = url
                
                # Also update/add to PlaceImage
                existing_img = db.query(models.PlaceImage).filter(
                    models.PlaceImage.place_id == place.id,
                    models.PlaceImage.is_cover == True
                ).first()
                
                if existing_img:
                    existing_img.url = url
                else:
                    db.add(models.PlaceImage(
                        place_id=place.id,
                        url=url,
                        is_cover=True,
                        sort_order=0
                    ))

        # Update Cities
        for name, url in CITY_IMAGES.items():
            city = db.query(models.City).filter(models.City.name == name).first()
            if city:
                print(f"Updating city: {name}")
                city.image_url = url
                
                # Also update/add to CityImage
                existing_img = db.query(models.CityImage).filter(
                    models.CityImage.city_id == city.id,
                    models.CityImage.is_cover == True
                ).first()
                
                if existing_img:
                    existing_img.url = url
                else:
                    db.add(models.CityImage(
                        city_id=city.id,
                        url=url,
                        is_cover=True,
                        sort_order=0
                    ))

        # Update Media Library
        for name, url in PREMIUM_IMAGES.items():
            existing_media = db.query(models.MediaItem).filter(models.MediaItem.name == name).first()
            if not existing_media:
                print(f"Adding to Media Library: {name}")
                db.add(models.MediaItem(
                    name=name,
                    data_url=url,
                    folder="premium"
                ))

        for name, url in CITY_IMAGES.items():
            existing_media = db.query(models.MediaItem).filter(models.MediaItem.name == f"City: {name}").first()
            if not existing_media:
                print(f"Adding to Media Library: City: {name}")
                db.add(models.MediaItem(
                    name=f"City: {name}",
                    data_url=url,
                    folder="cities"
                ))

        db.commit()
        print("Successfully synced premium assets to database and media library.")
    except Exception as e:
        print(f"Error syncing assets: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    sync()
