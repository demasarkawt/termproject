import asyncio
import logging
import os
from datetime import datetime, time as dtime, timedelta, timezone

from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import text, inspect

import r2_client
from auth import require_admin
from database import engine, get_db, Base, SessionLocal
from routers import (
    cities,
    places,
    events,
    users,
    ai,
    media,
    settings as settings_router,
    weather,
    events_sync,
)


def _ensure_extra_columns():
    """
    Lightweight forward-only migration: add columns introduced after the
    initial schema when running against an existing DB. Both PostgreSQL and
    SQLite support `ALTER TABLE ... ADD COLUMN`.
    """
    if not engine:
        return
    inspector = inspect(engine)
    tables = set(inspector.get_table_names())

    def _alter(table: str, additions: dict[str, str]):
        if table not in tables:
            return
        existing = {col["name"] for col in inspector.get_columns(table)}
        sqls = [
            f"ALTER TABLE {table} ADD COLUMN {name} {ddl}"
            for name, ddl in additions.items()
            if name not in existing
        ]
        if not sqls:
            return
        with engine.begin() as conn:
            for sql in sqls:
                conn.execute(text(sql))

    _alter(
        "media_items",
        {
            "r2_key": "VARCHAR(500)",
            "content_type": "VARCHAR(100)",
            "size_bytes": "INTEGER",
        },
    )
    _alter(
        "events",
        {
            "external_uid": "VARCHAR(255)",
            "source": "VARCHAR(20) DEFAULT 'manual'",
            "last_synced_at": "TIMESTAMP",
        },
    )


# ─── Auto-create tables on startup if engine is available ────────────────────
if engine:
    Base.metadata.create_all(bind=engine)
    _ensure_extra_columns()

# ─── App Initialization ───────────────────────────────────────────────────────
app = FastAPI(
    title="Kurdistan Go API",
    description="""
    Kurdistan Go - Tourism backend API.

    Provides endpoints for:
    - Cities (with image gallery)
    - Places (with image gallery, MALL category supported)
    - Events
    - Users (registration, trips, saved places)
    - AI Search (Mercury 2)
    - Media library (Cloudflare R2)
    - Site settings
    """,
    version="1.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ─── CORS ────────────────────────────────────────────────────────────────────
# Browsers only talk to this API over HTTPS — never to Postgres directly.
# Vercel dashboard (and *.vercel.app previews) need either:
#   - empty CORS_ORIGINS → allow_origins ["*"] below, or
#   - list your prod URL in CORS_ORIGINS *and* rely on allow_origin_regex for previews.
_extra_origins = [
    o.strip() for o in os.environ.get("CORS_ORIGINS", "").split(",") if o.strip()
]
_default_origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:5000",
    "http://127.0.0.1:5000",
    "http://localhost:5173",
    "http://localhost:5174",
    "http://localhost:5175",
    "https://kurdistan-go.vercel.app",
]
_disable_vercel_regex = os.getenv("CORS_DISABLE_VERCEL_REGEX", "").lower() in ("1", "true", "yes")
_vercel_regex = os.getenv(
    "CORS_VERCEL_REGEX",
    r"https://([a-zA-Z0-9\-]+\.)*vercel\.app",
)
# Flutter web uses an ephemeral port (e.g. localhost:54112). When CORS_ORIGINS is set,
# allow_origins is not "*", so we also match any localhost / 127.0.0.1 dev origin.
_local_dev_origin_regex = r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$"

if _extra_origins:
    _allow_origins = _extra_origins + _default_origins
    if _disable_vercel_regex:
        _origin_regex = _local_dev_origin_regex
    else:
        _origin_regex = f"(?:{_vercel_regex})|(?:{_local_dev_origin_regex})"
else:
    _allow_origins = ["*"]
    _origin_regex = None

app.add_middleware(
    CORSMiddleware,
    allow_origins=_allow_origins,
    allow_origin_regex=_origin_regex,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Include Routers ──────────────────────────────────────────────────────────
app.include_router(cities.router)
app.include_router(places.router)
app.include_router(events.router)
app.include_router(events_sync.router)
app.include_router(users.router)
app.include_router(ai.router)
app.include_router(media.router)
app.include_router(settings_router.router)
app.include_router(weather.router)


# ─── Health & DB Check Endpoints ──────────────────────────────────────────────
@app.get("/", tags=["Health"])
def root():
    return {
        "status": "ok",
        "message": "Kurdistan Go API is live!",
        "docs": "/docs",
    }


@app.get("/api/health", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "service": "Kurdistan Go Backend",
        "r2_configured": r2_client.is_configured(),
        "r2_public_url": bool(r2_client.R2_PUBLIC_URL),
        "admin_configured": bool((os.environ.get("ADMIN_KEY") or "").strip()),
        "database_configured": bool((os.environ.get("DATABASE_URL") or "").strip()),
    }


@app.get("/api/db-check", tags=["Health"])
def db_check(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
        return {"status": "connected", "message": "Database connection successful"}
    except Exception as e:
        return {"status": "error", "message": f"Database connection failed: {str(e)}"}


@app.post(
    "/api/seed",
    tags=["Admin"],
    dependencies=[Depends(require_admin)],
)
def seed_database():
    """Populate the database with initial data. Requires X-Admin-Key header."""
    try:
        import seed
        seed.run_seed()
        return {"status": "success", "message": "Database seeded successfully!"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to seed: {str(e)}")


# ─── Nightly ICS sync ─────────────────────────────────────────────────────────
_log = logging.getLogger("kg.events_cron")


def _seconds_until(target: dtime, *, now: datetime | None = None) -> float:
    now = now or datetime.now(timezone.utc)
    today = datetime.combine(now.date(), target, tzinfo=timezone.utc)
    if today <= now:
        today = today + timedelta(days=1)
    return (today - now).total_seconds()


async def _ics_nightly_loop():
    """Run /api/events/sync at ~03:00 UTC every night when configured."""
    while True:
        sleep_s = _seconds_until(dtime(hour=3, minute=0))
        try:
            await asyncio.sleep(sleep_s)
        except asyncio.CancelledError:
            return

        if SessionLocal is None:
            continue
        if not (os.getenv("EVENTS_ICS_URL") or "").strip():
            continue

        try:
            from routers.events_sync import sync_events  # local import for reload safety

            db = SessionLocal()
            try:
                result = sync_events(db=db)
            finally:
                db.close()
            _log.info("nightly ICS sync result: %s", result)
        except Exception as exc:  # noqa: BLE001 - log & keep loop alive
            _log.warning("nightly ICS sync failed: %s", exc)


@app.on_event("startup")
async def _start_jobs():
    if (os.getenv("EVENTS_ICS_URL") or "").strip():
        app.state.ics_task = asyncio.create_task(_ics_nightly_loop())


@app.on_event("shutdown")
async def _stop_jobs():
    task = getattr(app.state, "ics_task", None)
    if task:
        task.cancel()
