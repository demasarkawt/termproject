# Deployment: R2, Railway, GitHub, Flutter & Dashboard

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
| `DATABASE_URL` | Usually auto-set by PostgreSQL plugin |
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
   - Host `dist/` on **Cloudflare Pages**, **Netlify**, **Vercel**, or a static bucket — add that origin to **`CORS_ORIGINS`** on Railway.

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

The API base URL is compile-time configurable (no R2 secrets in the app).

**Default (matches production):** Railway URL from `client/lib/config/api_config.dart`. For **local backend only**:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

**Production build** (recommended):

```bash
cd client
flutter build apk --dart-define=API_BASE_URL=https://YOUR-RAILWAY-URL.up.railway.app
# iOS
flutter build ipa --dart-define=API_BASE_URL=https://YOUR-RAILWAY-URL.up.railway.app
# Web
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
3. **Flutter sign-ups:** Ship builds with `--dart-define=API_BASE_URL=https://YOUR-SERVICE.up.railway.app`. Otherwise registrations can hit your dev API instead of Railway.
