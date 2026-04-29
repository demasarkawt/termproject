"""Sync events from a public ICS calendar.

Configure `EVENTS_ICS_URL` in the environment to point at the calendar feed
(e.g. a Google / Apple shareable URL ending in `.ics`). The endpoint is
admin-gated and idempotent — events keep their existing row when their
`UID` re-appears, so it can run on a nightly schedule without duplication.
"""

from __future__ import annotations

import logging
import os
from datetime import date, datetime, timezone
from typing import Any, Optional

import requests
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import models
from auth import require_admin
from database import get_db

router = APIRouter(prefix="/api/events", tags=["Events"])

log = logging.getLogger(__name__)


def _ics_url() -> Optional[str]:
    return (os.getenv("EVENTS_ICS_URL") or "").strip() or None


def _normalize_dt(value: Any) -> Optional[str]:
    """Return an ISO-8601-ish string the existing schema can store as VARCHAR."""
    if value is None:
        return None
    if isinstance(value, datetime):
        if value.tzinfo is None:
            value = value.replace(tzinfo=timezone.utc)
        return value.isoformat()
    if isinstance(value, date):
        return value.isoformat()
    return str(value)


def _map_event_type(categories: Any) -> Optional[str]:
    """ICS CATEGORIES → existing event_type taxonomy (MUSIC / FOOD / CULTURE)."""
    if not categories:
        return None
    raw = categories
    if hasattr(categories, "to_ical"):
        try:
            raw = categories.to_ical().decode("utf-8")
        except Exception:
            raw = str(categories)
    text = (str(raw) or "").lower()
    if "music" in text or "concert" in text:
        return "MUSIC"
    if "food" in text or "festival" in text:
        return "FOOD"
    if "sport" in text or "adventure" in text:
        return "ADVENTURE"
    return "CULTURE"


@router.post(
    "/sync",
    dependencies=[Depends(require_admin)],
)
def sync_events(db: Session = Depends(get_db)):
    """Pull the configured ICS feed and reconcile events by `external_uid`."""
    url = _ics_url()
    if not url:
        return {
            "status": "skipped",
            "reason": "EVENTS_ICS_URL not configured",
            "added": 0,
            "updated": 0,
            "removed": 0,
        }

    try:
        resp = requests.get(url, timeout=15)
        resp.raise_for_status()
    except requests.RequestException as exc:
        raise HTTPException(status_code=502, detail=f"ICS download failed: {exc}")

    try:
        from icalendar import Calendar
    except ImportError as exc:  # pragma: no cover - guarded by requirements.txt
        raise HTTPException(status_code=500, detail=f"icalendar missing: {exc}")

    try:
        cal = Calendar.from_ical(resp.content)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"ICS parse failed: {exc}")

    seen_uids: set[str] = set()
    added = 0
    updated = 0
    now = datetime.now(timezone.utc)

    for component in cal.walk("VEVENT"):
        uid = str(component.get("UID") or "").strip()
        if not uid:
            continue
        seen_uids.add(uid)

        title = str(component.get("SUMMARY") or "Untitled event").strip()
        description = component.get("DESCRIPTION")
        location = component.get("LOCATION")
        dtstart = component.get("DTSTART")
        dtend = component.get("DTEND")
        categories = component.get("CATEGORIES")

        payload = {
            "title": title or "Untitled event",
            "description": (str(description) if description else None),
            "location": (str(location) if location else None),
            "start_date": _normalize_dt(dtstart.dt if dtstart else None),
            "end_date": _normalize_dt(dtend.dt if dtend else None),
            "event_type": _map_event_type(categories),
            "source": "ics",
            "last_synced_at": now,
        }

        existing = (
            db.query(models.Event)
            .filter(models.Event.external_uid == uid)
            .first()
        )
        if existing is None:
            db.add(models.Event(external_uid=uid, **payload))
            added += 1
        else:
            for k, v in payload.items():
                setattr(existing, k, v)
            updated += 1

    removed_q = (
        db.query(models.Event)
        .filter(models.Event.source == "ics")
        .filter(~models.Event.external_uid.in_(seen_uids) if seen_uids else True)
    )
    removed = removed_q.count()
    removed_q.delete(synchronize_session=False)
    db.commit()

    return {
        "status": "ok",
        "added": added,
        "updated": updated,
        "removed": removed,
        "total_in_feed": len(seen_uids),
        "synced_at": now.isoformat(),
    }


@router.get("/sync/status")
def sync_status(db: Session = Depends(get_db)):
    """Public read: when did we last sync and how many ICS-sourced events exist?"""
    last = (
        db.query(models.Event)
        .filter(models.Event.source == "ics")
        .order_by(models.Event.last_synced_at.desc())
        .first()
    )
    return {
        "configured": bool(_ics_url()),
        "ics_event_count": (
            db.query(models.Event)
            .filter(models.Event.source == "ics")
            .count()
        ),
        "last_synced_at": (
            last.last_synced_at.isoformat()
            if last is not None and last.last_synced_at is not None
            else None
        ),
    }
