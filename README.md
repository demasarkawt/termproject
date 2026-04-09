# Kurdistan Go

A Flutter mobile tourism app for exploring Kurdistan — featuring AI-powered destination discovery, interactive maps, cultural events, and a 1-day trip planner backed by the **Mercury 2** model from Inception Labs.

---

## Features

- **AI Mood Search** — Describe how you feel and Mercury 2 finds matching places
- **AI Trip Planner** — Get a personalized 1-day itinerary for any Kurdish city
- **Explore Map** — Browse heritage sites, waterfalls, canyons, and more
- **Cities & Places** — Detailed pages for Erbil, Sulaymaniyah, Duhok, and Halabja
- **Events** — Upcoming cultural festivals and local events
- **Authentication** — Sign up / sign in with JWT-backed user accounts
- **Saved Places** — Bookmark your favourite destinations
- **Trip Management** — Plan and track your trips

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (Dart ≥ 3.0) |
| Routing | GoRouter 14 |
| Maps | flutter_map + latlong2 |
| Backend | FastAPI + Uvicorn |
| Database | PostgreSQL (SQLAlchemy 2) |
| AI | Inception Labs Mercury 2 via OpenAI-compatible SDK |
| Auth | Passlib + bcrypt |
| Deployment | Railway |

---

## Project Structure

```
termproject/
├── client/               # Flutter mobile app
│   └── lib/
│       ├── config/       # API base URL config
│       ├── data/         # Repositories & state
│       └── screens/
│           ├── ai/       # AI Travel Assistant page
│           ├── auth/     # Sign in / Sign up
│           ├── cities/   # City detail
│           ├── events/   # Events listing
│           ├── explore/  # Explore + map tab
│           ├── home/     # Home screen
│           ├── places/   # Place list & detail
│           ├── profile/  # User profile
│           └── shell/    # Bottom navigation shell
└── server/               # FastAPI backend
    ├── main.py
    ├── models.py
    ├── schemas.py
    ├── database.py
    ├── seed.py
    └── routers/
        ├── ai.py         # Mercury 2 endpoints
        ├── cities.py
        ├── places.py
        ├── events.py
        └── users.py
```

---

## API Endpoints

### AI (Mercury 2)
| Method | Path | Description |
|---|---|---|
| POST | `/api/ai/mood-search` | Find places matching a mood/preference prompt |
| POST | `/api/ai/trip-planner` | Generate a 1-day itinerary for a city |

### Cities
| Method | Path | Description |
|---|---|---|
| GET | `/api/cities` | List all cities |
| GET | `/api/cities/{city_id}` | Get a specific city by ID |
| GET | `/api/cities/{city_id}/places` | List all places in a specific city |

### Places
| Method | Path | Description |
|---|---|---|
| GET | `/api/places` | List all places |
| GET | `/api/places/trending` | Top trending places |
| GET | `/api/places/{place_id}` | Get place by ID |
| POST | `/api/places` | Create a new place (admin) |
| DELETE | `/api/places/{place_id}` | Delete a place (admin) |

### Events
| Method | Path | Description |
|---|---|---|
| GET | `/api/events` | List all events |
| GET | `/api/events/{event_id}` | Get event by ID |
| POST | `/api/events` | Create a new event (admin) |
| DELETE | `/api/events/{event_id}` | Delete an event (admin) |

### Media
| Method | Path | Description |
|---|---|---|
| GET | `/api/media` | List all media items |
| POST | `/api/media` | Upload a new media item (admin) |
| DELETE | `/api/media/{item_id}` | Delete a media item (admin) |

### Users & Authentication
| Method | Path | Description |
|---|---|---|
| POST | `/api/users/register` | Register a new user |
| POST | `/api/users/login` | Sign in |
| GET | `/api/users` | List all users (admin) |
| GET | `/api/users/{user_id}` | Get user profile |
| GET | `/api/users/{user_id}/trips` | Get user's planned trips |
| POST | `/api/users/{user_id}/trips` | Create a new trip |
| POST | `/api/users/{user_id}/save/{place_id}` | Save a place to favorites |
| DELETE | `/api/users/{user_id}/save/{place_id}` | Remove a place from favorites |
| GET | `/api/users/{user_id}/saved` | List user's saved places |

Full interactive docs available at `/docs` (Swagger UI).

---

## Getting Started

### Backend

```bash
cd server
cp .env.example .env          # fill in DATABASE_URL and INCEPTION_API_KEY
pip install -r requirements.txt
uvicorn main:app --reload
```

> The `INCEPTION_API_KEY` environment variable is **required**. Get your key at [inceptionlabs.ai](https://inceptionlabs.ai).

Seed the database with sample data:

```
GET /api/seed
```

### Flutter App

```bash
cd client
flutter pub get
flutter run
```

Update `lib/config/api_config.dart` with your backend URL before running:

```dart
const String kBaseUrl = 'https://your-backend.up.railway.app';
```

---

## Deployment

The backend is configured for **Railway** deployment via `railway.json` and `nixpacks.toml`. Set the following environment variables in Railway:

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string (auto-injected by Railway) |
| `INCEPTION_API_KEY` | Your Inception Labs API key |

---

## Resolved Issues

| Issue | Description |
|---|---|
| [#1](https://github.com/demasarkawt/termproject/issues/1) | End-to-end authentication flow |
| [#2](https://github.com/demasarkawt/termproject/issues/2) | AI pages + Mercury 2 integration |
| [#3](https://github.com/demasarkawt/termproject/issues/3) | Database seeding and data extraction |
