"""Weather proxy backed by Open-Meteo with a tiny in-memory TTL cache.

Both the Flutter app and the dashboard hit this endpoint, so they share
results and we keep the upstream call rate low. No API key required.
"""

from __future__ import annotations

import time
from typing import Any, Optional

import requests
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

import models
from database import get_db

router = APIRouter(prefix="/api/weather", tags=["Weather"])

OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"
CACHE_TTL_SECONDS = 600  # 10 minutes per the plan
_cache: dict[str, tuple[float, dict[str, Any]]] = {}


# Mapping of WMO weather codes to short descriptions. See
# https://open-meteo.com/en/docs#weather_variable_documentation
_WEATHER_CODES: dict[int, str] = {
    0: "Clear sky",
    1: "Mainly clear",
    2: "Partly cloudy",
    3: "Overcast",
    45: "Fog",
    48: "Rime fog",
    51: "Light drizzle",
    53: "Drizzle",
    55: "Heavy drizzle",
    56: "Freezing drizzle",
    57: "Heavy freezing drizzle",
    61: "Light rain",
    63: "Rain",
    65: "Heavy rain",
    66: "Freezing rain",
    67: "Heavy freezing rain",
    71: "Light snow",
    73: "Snow",
    75: "Heavy snow",
    77: "Snow grains",
    80: "Rain showers",
    81: "Heavy rain showers",
    82: "Violent rain showers",
    85: "Snow showers",
    86: "Heavy snow showers",
    95: "Thunderstorm",
    96: "Thunderstorm with hail",
    99: "Severe thunderstorm",
}


def _describe(code: int) -> str:
    return _WEATHER_CODES.get(code, "Unknown")


def _fetch(lat: float, lng: float) -> dict[str, Any]:
    """Hit Open-Meteo and shape the response into a small, stable payload."""
    params = {
        "latitude": lat,
        "longitude": lng,
        "current": "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m",
        "timezone": "auto",
    }
    try:
        resp = requests.get(OPEN_METEO_URL, params=params, timeout=8)
        resp.raise_for_status()
    except requests.RequestException as e:
        raise HTTPException(status_code=502, detail=f"Weather upstream error: {e}")

    data = resp.json()
    cur = data.get("current", {}) or {}
    code = int(cur.get("weather_code") or 0)
    return {
        "temperature_c": cur.get("temperature_2m"),
        "weather_code": code,
        "description": _describe(code),
        "wind_kmh": cur.get("wind_speed_10m"),
        "humidity": cur.get("relative_humidity_2m"),
        "fetched_at": int(time.time()),
    }


def _cache_get(key: str) -> Optional[dict[str, Any]]:
    hit = _cache.get(key)
    if not hit:
        return None
    ts, payload = hit
    if time.time() - ts > CACHE_TTL_SECONDS:
        _cache.pop(key, None)
        return None
    return payload


def _cache_set(key: str, payload: dict[str, Any]) -> None:
    _cache[key] = (time.time(), payload)


@router.get("")
@router.get("/")
def get_weather(
    city_id: Optional[int] = Query(None, description="Resolve coordinates from a city row"),
    lat: Optional[float] = Query(None),
    lng: Optional[float] = Query(None),
    db: Session = Depends(get_db),
):
    """Return current weather for a city (or arbitrary lat/lng).

    Cached for 10 minutes per (lat,lng) tuple, no admin key required.
    """
    if city_id is None and (lat is None or lng is None):
        raise HTTPException(
            status_code=400,
            detail="Pass either city_id or both lat & lng",
        )

    resolved_city_id: Optional[int] = None
    if city_id is not None:
        city = db.query(models.City).filter(models.City.id == city_id).first()
        if not city:
            raise HTTPException(status_code=404, detail="City not found")
        if city.latitude is None or city.longitude is None:
            raise HTTPException(
                status_code=422,
                detail=f"City '{city.name}' has no coordinates set",
            )
        lat = float(city.latitude)
        lng = float(city.longitude)
        resolved_city_id = city.id

    assert lat is not None and lng is not None  # narrow for type-checkers
    key = f"{round(lat, 3)},{round(lng, 3)}"
    payload = _cache_get(key)
    if payload is None:
        payload = _fetch(lat, lng)
        _cache_set(key, payload)

    return {
        "city_id": resolved_city_id,
        "lat": lat,
        "lng": lng,
        **payload,
    }
