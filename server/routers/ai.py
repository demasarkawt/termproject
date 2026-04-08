import json
import os
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel

import models
import schemas
from database import get_db

router = APIRouter(prefix="/api/ai", tags=["AI Search"])


def _get_ai_client() -> OpenAI:
    """
    Lazily create the Inception Labs AI client.
    Raises HTTP 503 if INCEPTION_API_KEY is not configured,
    instead of crashing the whole server at startup.
    """
    api_key = os.environ.get("INCEPTION_API_KEY")
    if not api_key:
        raise HTTPException(
            status_code=503,
            detail="AI service is not configured. Please set INCEPTION_API_KEY."
        )
    return OpenAI(
        api_key=api_key,
        base_url="https://api.inceptionlabs.ai/v1"
    )


class MoodSearchRequest(BaseModel):
    prompt: str


class TripPlannerRequest(BaseModel):
    city: str
    interests: str


@router.post("/mood-search", response_model=list[schemas.PlaceOut])
def search_places_by_mood(request: MoodSearchRequest, db: Session = Depends(get_db)):
    """
    Takes a natural language prompt from the user (e.g., "I'm in the mood for something green and quiet")
    and uses the Inception Labs 'mercury-2' model to map it to the best matching places in the database.
    """
    try:
        # 0. Get AI client (raises 503 if key not set)
        client = _get_ai_client()

        # 1. Fetch all places from the database
        all_places = db.query(models.Place).all()
        if not all_places:
            return []

        # 2. Format places into a string for the AI context
        context_lines = []
        for p in all_places:
            context_lines.append(f"[ID: {p.id}] {p.name} - {p.category} - {p.description}")

        places_context = "\n".join(context_lines)

        # 3. Create the prompt array
        messages = [
            {
                "role": "system",
                "content": (
                    "You are 'Kurdistan Go AI', an expert local travel guide. You have a strict database of places. "
                    "When the user describes their mood or what they want to do, you must select between 1 and 4 places that perfectly match their request.\n\n"
                    "AVAILABLE PLACES:\n"
                    f"{places_context}\n\n"
                    "INSTRUCTIONS:\n"
                    "Output ONLY a raw JSON array of the matching integer IDs. Do not output markdown, do not output explanations, just the raw JSON list of numbers.\n"
                    "Example output: [2, 5, 12]"
                )
            },
            {
                "role": "user",
                "content": f"My mood/preference: {request.prompt}"
            }
        ]

        # 4. Hit the Inception Labs Mercury-2 API
        response = client.chat.completions.create(
            model="mercury-2",
            messages=messages,
            max_tokens=150,
            temperature=0.2
        )

        raw_content = response.choices[0].message.content.strip()

        # Clean markdown if the AI accidentally included it
        if raw_content.startswith("```json"):
            raw_content = raw_content.replace("```json", "").replace("```", "").strip()
        elif raw_content.startswith("```"):
            raw_content = raw_content.replace("```", "").strip()

        # Parse the JSON array
        place_ids = json.loads(raw_content)

        if not isinstance(place_ids, list):
            place_ids = []

        # 5. Fetch the fully realized place objects from the DB
        matched_places = db.query(models.Place).filter(models.Place.id.in_(place_ids)).all()

        return matched_places

    except Exception as e:
        print(f"AI Mood Search Error: {e}")
        return []


@router.post("/trip-planner")
def plan_trip(request: TripPlannerRequest):
    """
    Takes a city name and user interests, then uses Mercury-2 to generate
    a personalized 1-day itinerary as a text response.
    """
    try:
        # Get AI client (raises 503 if key not set)
        client = _get_ai_client()

        messages = [
            {
                "role": "system",
                "content": (
                    "You are 'Kurdistan Go AI', a local expert travel planner for Kurdistan, Iraq. "
                    "Create short, engaging 1-day itineraries that feel personal and exciting. "
                    "Format your response as a clear, readable day plan with Morning, Afternoon, and Evening sections. "
                    "Keep the total response under 300 words. Use friendly, enthusiastic language."
                )
            },
            {
                "role": "user",
                "content": (
                    f"Plan a 1-day trip to {request.city}, Kurdistan. "
                    f"My interests are: {request.interests}"
                )
            }
        ]

        response = client.chat.completions.create(
            model="mercury-2",
            messages=messages,
            max_tokens=400,
            temperature=0.7
        )

        itinerary = response.choices[0].message.content.strip()
        return {"city": request.city, "itinerary": itinerary}

    except Exception as e:
        print(f"AI Trip Planner Error: {e}")
        raise HTTPException(status_code=500, detail="Failed to generate trip plan. Please try again.")
