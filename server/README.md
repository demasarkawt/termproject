# Kurdistan Go — Python Backend

A high-performance **FastAPI** backend with PostgreSQL database, ready for deployment on **Railway**.

---

## Project Structure

```
server/
├── main.py            # App entry point — all routes registered here
├── database.py        # PostgreSQL connection via DATABASE_URL
├── models.py          # SQLAlchemy ORM table definitions
├── schemas.py         # Pydantic request/response schemas
├── seed.py            # Populate DB with initial Kurdistan data
├── requirements.txt   # Python dependencies
├── Procfile           # Railway/Heroku boot command
├── .env.example       # Environment variable template
└── routers/
    ├── cities.py      # GET /api/cities
    ├── places.py      # GET /api/places
    ├── events.py      # GET /api/events
    └── users.py       # POST /api/users/register, trips, saved places
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Health check |
| GET | `/api/health` | Service health check |
| GET | `/api/db-check` | PostgreSQL connection check |
| GET | `/api/cities` | List all cities |
| GET | `/api/cities/{id}` | Get one city |
| GET | `/api/cities/{id}/places` | Get places in a city |
| GET | `/api/places` | List places (filter by category/city) |
| GET | `/api/places/trending` | Top-rated places |
| GET | `/api/places/{id}` | Get one place |
| GET | `/api/events` | List events (filter by type) |
| GET | `/api/events/{id}` | Get one event |
| POST | `/api/users/register` | Register new user |
| GET | `/api/users/{id}` | Get user profile |
| GET | `/api/users/{id}/trips` | Get user trips |
| POST | `/api/users/{id}/trips` | Create a trip |
| POST | `/api/users/{id}/save/{place_id}` | Save a place |
| GET | `/api/users/{id}/saved` | Get saved places |

---

## Running Locally

```bash
# 1. Create virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
source venv/bin/activate     # Mac/Linux

# 2. Install dependencies
pip install -r requirements.txt

# 3. Create .env from template
copy .env.example .env
# Edit .env and fill in your local PostgreSQL credentials

# 4. Start the server
uvicorn main:app --reload

# 5. (Optional) Seed the database with sample data
python seed.py
```

Visit **http://localhost:8000/docs** for the live Swagger UI.

---

## Deploying to Railway

1. Push the repository to GitHub
2. Go to [railway.app](https://railway.app) → New Project → Deploy from GitHub
3. Select your repo
4. In **Settings → General**, set **Root Directory** to `/server`
5. Add a **PostgreSQL** plugin from the Railway dashboard
6. Railway will automatically set `DATABASE_URL` — no manual config needed!
7. Once deployed, visit your Railway URL and navigate to `/docs`
