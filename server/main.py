import os
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import text

import models
from database import engine, get_db, Base
from routers import cities, places, events, users, ai

# ─── Auto-create tables on startup if engine is available ────────────────────
if engine:
    Base.metadata.create_all(bind=engine)

# ─── App Initialization ───────────────────────────────────────────────────────
app = FastAPI(
    title="Kurdistan Go API",
    description="""
    🌿 **Kurdistan Go** – Tourism backend API.

    Provides endpoints for:
    - **Cities** – Erbil, Sulaymaniyah, Duhok, Halabja
    - **Places** – Historical sites, nature spots, restaurants
    - **Events** – Upcoming festivals and cultural events
    - **Users** – Registration, trips, and saved places
    - **AI Search** – Mood-based intelligent destination matching
    """,
    version="1.0.0",
    docs_url="/docs",          # Swagger UI at /docs
    redoc_url="/redoc",        # ReDoc at /redoc
)

# ─── CORS (allow Flutter Web + Mobile) ───────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Include Routers ──────────────────────────────────────────────────────────
app.include_router(cities.router)
app.include_router(places.router)
app.include_router(events.router)
app.include_router(users.router)
app.include_router(ai.router)


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
    return {"status": "healthy", "service": "Kurdistan Go Backend"}


@app.get("/api/db-check", tags=["Health"])
def db_check(db: Session = Depends(get_db)):
    """
    Check whether the PostgreSQL connection is established.
    Run a simple SQL ping and return the result.
    """
    try:
        db.execute(text("SELECT 1"))
        return {
            "status": "connected",
            "database": "PostgreSQL",
            "message": "Database connection successful ✅",
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Database connection failed ❌: {str(e)}",
        }

@app.get("/api/seed", tags=["Admin"])
def seed_database():
    """
    Populates the PostgreSQL database with initial data.
    """
    try:
        import seed
        seed.run_seed()
        return {"status": "success", "message": "Database seeded successfully! 🌱"}
    except Exception as e:
        return {"status": "error", "message": f"Failed to seed database ❌: {str(e)}"}
