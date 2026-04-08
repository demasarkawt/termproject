import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Load .env file in local development — Railway injects DATABASE_URL automatically
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "")

# Railway sometimes provides postgres:// — SQLAlchemy requires postgresql://
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

if not DATABASE_URL:
    print("⚠️  WARNING: DATABASE_URL not set. Database features will be unavailable.")
    engine = None
    SessionLocal = None
else:
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """Dependency for FastAPI routes to get a DB session."""
    if SessionLocal is None:
        raise RuntimeError("Database not configured. Set DATABASE_URL in environment.")
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
