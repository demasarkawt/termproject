# Deployment: R2, Railway, GitHub, Flutter & Dashboard

**Secrets:** Never commit `DATABASE_URL`, `ADMIN_KEY`, API keys, or Postgres passwords to Git. If any credential was shared publicly, **rotate** it in Railway / Cloudflare / Vercel immediately.

This doc ties together **Cloudflare R2** (object storage), the **FastAPI** backend on **Railway**, **GitHub** as source of truth, and the **Flutter app** + **Vite dashboard** as API clients.

## Architecture (who talks to R2)

| Component | R2 credentials? | What it does |
|-----------|-------------------|--------------|
| **Backend (Railway)** | Yes — `R2_*` env vars | Uploads/downloads objects; returns **HTTPS URLs** (public bucket URL or presigned URLs) in JSON |
| **Dashboard** | No | Calls REST API only; uses image URLs returned by the API |
| **Flutter** | No | Same — `CachedNetworkImage` / HTTP loads URLs from `/api/places`, `/api/media`, etc. |

Neither the Flutter app nor the dashboard embeds R2 keys. Configure R2 **only** on the server.

---

## 1. Cloudflare R2

1. In [Cloudflare Dashboard](https://dash.cloudflare.com/) → R2 → create a bucket (e.g. `termproject`).
2. **Manage R2 API Tokens** → create token with **Object Read & Write** on that bucket.
3. Note **Account ID**, **Access Key ID**, **Secret Access Key**.
4. Optional **public reads**:
   - R2 → bucket → **Settings** → allow public access **or** attach a **Custom Domain** / **r2.dev** public URL.
   - Put that base URL in `R2_PUBLIC_URL` so the API returns stable `https://…/key` links. If empty, the API falls back to **presigned** URLs (still works for Flutter/web).

Local template: copy `server/.env.example` → `server/.env` and fill `R2_*`.

---

## 2. Railway (backend)

1. Push this repo to **GitHub**.
2. [Railway](https://railway.app) → **New Project** → **Deploy from GitHub** → select the repo.
3. **Settings → Root Directory**: leave empty if you deploy from repo root using the root `Dockerfile`, **or** set to `server` and use **Nixpacks / Procfile** (see `server/README.md`). Match how your service was created.
4. Add **PostgreSQL** plugin; Railway sets `DATABASE_URL`.
5. Set variables (minimum):

| Variable | Purpose |
|----------|---------|
| `DATABASE_URL` | **Railway API service only.** Use the variable **referenced from the Postgres plugin** (`postgres.railway.internal` is normal there — never paste this into Vercel or the Flutter app). |
| `ADMIN_KEY` | Long random string — required for `/api/seed`, admin uploads, `/api/events/sync` |
| `R2_ACCOUNT_ID`, `R2_BUCKET_NAME`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` | R2 access |
| `R2_PUBLIC_URL` | Optional; public base URL for objects |
| `CORS_ORIGINS` | **Production:** comma-separated origins, e.g. `https://your-dashboard.pages.dev,https://your-flutter-web.host` — required if browsers block cross-origin calls |

Optional: `EVENTS_ICS_URL`, `INCEPTION_API_KEY` / `OPENAI_API_KEY` (see `server/.env.example`), `WIKI_SEED_IMAGES`.

6. Redeploy. Check `GET https://<your-service>.up.railway.app/api/health` → `r2_configured` should be `true` after keys are set.

---

## 3. Dashboard (Vite)

The admin UI reads `VITE_API_URL` and `VITE_ADMIN_KEY` at **build time**.

1. Copy `dashboard/.env.example` → `dashboard/.env`.
2. Set:
   - `VITE_API_URL=https://<your-railway-backend>.up.railway.app`
   - `VITE_ADMIN_KEY=<same as ADMIN_KEY on Railway>`
3. Build or dev:
   - `npm run dev` — local dashboard pointing at production API if `.env` says so.
   - Host `dist/` on **Cloudflare Pages**, **Netlify**, **Vercel**, or a static bucket — add that origin to **`CORS_ORIGINS`** on Railway if you use an explicit allow-list (see below).

### Vercel (`termproject-dashboard` etc.)

1. **Do not** put `DATABASE_URL`, `postgresql://…`, or Postgres passwords in Vercel — the browser never connects to Postgres; only your **Railway Python service** uses `DATABASE_URL` (often `postgres.railway.internal`, which only works **inside** Railway’s network).

2. In Vercel → **Project → Settings → Environment Variables** → add for **Production** (and **Preview** if you want previews to hit real API):

   | Name | Value |
   |------|--------|
   | `VITE_API_URL` | Your **public** Railway API URL, e.g. `https://YOUR-SERVICE.up.railway.app` (copy from Railway → your API service → **Networking / domain**). No trailing slash. |
   | `VITE_ADMIN_KEY` | Exactly the same as **`ADMIN_KEY`** on the Railway backend. |

3. **Redeploy** after saving variables — Vite bakes these in at **build** time (`Deployments → … → Redeploy`).

4. Open the deployed dashboard → **Settings → API & Backend**: confirm **PostgreSQL (Railway)** shows OK (means Railway has `DATABASE_URL`) and **Health** is healthy.

5. **CORS:** If you set **`CORS_ORIGINS`** on Railway to a strict list, include your Vercel URL(s), e.g. `https://termproject-dashboard.vercel.app`. Alternatively, when `CORS_ORIGINS` is **non-empty**, the API also allows origins matching `*.vercel.app` via regex unless you set `CORS_DISABLE_VERCEL_REGEX=true`.

### 3b. Vercel (repo root)

Deploy the **dashboard** (`dashboard/`), not the Flutter `client/`. This repo includes a root **`vercel.json`** so Git deployments run `npm ci` / `npm run build` inside **`dashboard`** and publish **`dashboard/dist`**.

In [Vercel](https://vercel.com/) → Project **kurdistan-go** (or your project):

1. **Settings → Git → Root Directory:** use **empty / `.`** (repo root) so the root `vercel.json` runs the dashboard build — **or** set Root Directory to **`dashboard`** (then Vite builds from that folder; do **not** point at `client/`).
2. **Settings → Environment Variables** (Production, and Preview if needed):

   | Name | Value |
   |------|--------|
   | `VITE_API_URL` | `https://termproject-production.up.railway.app` (your Railway API, no trailing slash) |
   | `VITE_ADMIN_KEY` | Same secret as Railway **`ADMIN_KEY`** |

4. Add your **Vercel production URL** to Railway **`CORS_ORIGINS`** only if you restrict origins and this host is missing. The API also whitelists **`https://kurdistan-go.vercel.app`** in `_default_origins` when `CORS_ORIGINS` is non-empty.

---

## 4. Flutter app

The app never opens PostgreSQL directly — it calls **HTTPS to your FastAPI URL on Railway**, and **Railway’s backend** uses `DATABASE_URL` for Postgres.

**Defaults (`client/lib/config/api_config.dart`):** release/profile use Railway; debug uses local FastAPI. To point **debug** at production or another host:

```bash
flutter run --dart-define=API_BASE_URL=https://termproject-production.up.railway.app
```

For **local backend only** (debug):

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

| Build mode | API URL when `API_BASE_URL` dart-define is **not** set |
|------------|---------------------------------------------------------|
| **Debug** (`flutter run`) | `http://127.0.0.1:8000` (local backend) |
| **Release / profile** (`flutter build apk`, Play/TestFlight builds) | `https://termproject-production.up.railway.app` (edit constant if your Railway hostname differs) |

**Optional:** Always pin your backend explicitly:

```bash
cd client
flutter build apk --dart-define=API_BASE_URL=https://YOUR-RAILWAY-URL.up.railway.app
flutter build ipa --dart-define=API_BASE_URL=https://YOUR-RAILWAY-URL.up.railway.app
flutter build web --dart-define=API_BASE_URL=https://YOUR-RAILWAY-URL.up.railway.app
```

**Android emulator** hitting host machine:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

If you ship **Flutter web** on its own domain, add that URL to **`CORS_ORIGINS`** on the backend.

---

## 5. GitHub

- **Source:** Push branches to GitHub; Railway watches the repo for deploys (configure branch in Railway).
- **CI:** `.github/workflows/ci.yml` runs lint/analysis on push/PR for `server`, `dashboard`, and `client`.

---

## 6. Smoke checks after deploy

1. `GET /api/health` — `admin_configured`, `r2_configured` as expected.
2. Dashboard: open Places/Cities — images load if seed/upload populated R2-backed URLs.
3. Flutter: sign-in and browse places — same URLs should render images.
4. If images fail with CORS only in browser — fix `CORS_ORIGINS`; image URLs themselves are normal HTTPS GETs to R2 or presigned links.

---

## 7. Troubleshooting: dashboard / Flutter vs Railway PostgreSQL

If new users or rows appear in the admin UI but **not** in Railway’s Postgres:

1. **`GET /api/health`** on your Railway URL — `database_configured` must be **`true`**. If **`false`**, the service has no `DATABASE_URL` (attach the Railway **PostgreSQL** plugin or paste the plugin’s URL into Variables).
2. **Dashboard origin:** Open DevTools → **Network** → reload Users (or any API call). The request host must be your **`*.up.railway.app`** API, **not** the dashboard dev server (e.g. `localhost:3000`). If requests stay on the dashboard host, `VITE_API_URL` was missing or blank — set `dashboard/.env` to `VITE_API_URL=https://YOUR-SERVICE.up.railway.app` (no trailing slash), restart `npm run dev`, or rebuild static hosting.
3. **Flutter:** In **debug**, the app defaults to **`http://127.0.0.1:8000`** — that DB is **not** Railway’s Postgres. Use **`flutter run --dart-define=API_BASE_URL=https://YOUR-SERVICE.up.railway.app`** to hit Railway while debugging, or use **release/profile** builds which default to Railway unless `API_BASE_URL` is set. Watch the console: **`[Kurdistan Go] API base URL → ...`** on startup (debug mode).
