import json
import os
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from openai import OpenAI

import models
import schemas
from database import get_db

router = APIRouter(prefix="/api/ai", tags=["AI Search"])

# Initialize the OpenAI client pointing to Inception Labs API
# Using the fallback key provided by the user if the env variable isn't set
client = OpenAI(
    api_key=os.environ.get("INCEPTION_API_KEY", "sk_c80f70c85a6a048f6ba4dfdf59b15b0a"),
    base_url="https://api.inceptionlabs.ai/v1"
)

class MoodSearchRequest(BaseModel):
    prompt: str

@router.post("/mood-search", response_model=list[schemas.PlaceResponse])
def search_places_by_mood(request: MoodSearchRequest, db: Session = Depends(get_db)):
    """
    Takes a natural language prompt from the user (e.g., "I'm in the mood for something green and quiet")
    and uses the Inception Labs 'mercury-2' model to map it to the best matching places in the database.
    """
    try:
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

        # 4. Hit the Inception Labs API
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
        print(f"AI Search Error: {e}")
        # fallback if AI fails: just return an empty list or top trending
        return []
