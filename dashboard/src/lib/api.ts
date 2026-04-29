// Centralised API client for the admin dashboard.
//
// Reads VITE_API_URL and VITE_ADMIN_KEY from `.env`. The admin key is
// attached as the `X-Admin-Key` header on every write call so the backend's
// `require_admin` dependency lets us through.
//
// Important: `??` does NOT fall back when VITE_API_URL is "" (empty string).
// An empty value makes fetch("/api/...") relative — requests hit the dashboard
// host, not Railway — so data never reaches PostgreSQL. We normalize empty → fallback.

const DEFAULT_API_URL = 'https://termproject-production.up.railway.app';

function resolveApiUrl(): string {
  const raw = import.meta.env.VITE_API_URL as string | undefined;
  const trimmed = typeof raw === 'string' ? raw.trim() : '';
  const base = trimmed.length > 0 ? trimmed : DEFAULT_API_URL;
  return base.replace(/\/+$/, '');
}

export const API_URL: string = resolveApiUrl();

export const ADMIN_KEY: string =
  (import.meta.env.VITE_ADMIN_KEY as string | undefined)?.trim() ?? '';

if (import.meta.env.DEV) {
  console.info('[dashboard] API_URL →', API_URL);
}

export const PLACE_CATEGORIES = ['CULTURE', 'NATURE', 'ADVENTURE', 'FOOD', 'MALL'] as const;
export type PlaceCategory = (typeof PLACE_CATEGORIES)[number];

export class ApiError extends Error {
  status: number;
  detail?: string;
  constructor(status: number, detail: string | undefined, message: string) {
    super(message);
    this.status = status;
    this.detail = detail;
    this.name = 'ApiError';
  }
}

async function rawFetch(path: string, options: RequestInit = {}): Promise<Response> {
  if (!API_URL) {
    throw new ApiError(
      500,
      'VITE_API_URL is missing',
      'Set VITE_API_URL in dashboard/.env to your Railway API URL',
    );
  }
  const res = await fetch(`${API_URL}${path}`, options);
  if (!res.ok) {
    let detail: string | undefined;
    try {
      const data = await res.clone().json();
      detail =
        typeof data?.detail === 'string'
          ? data.detail
          : JSON.stringify(data?.detail ?? data);
    } catch {
      detail = await res.clone().text().catch(() => undefined);
    }
    throw new ApiError(
      res.status,
      detail,
      `API ${res.status}: ${detail ?? res.statusText}`,
    );
  }
  return res;
}

export async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await rawFetch(path, options);
  if (res.status === 204) return undefined as T;
  return (await res.json()) as T;
}

const adminHeaders = (json = true): Record<string, string> => {
  const h: Record<string, string> = {};
  if (json) h['Content-Type'] = 'application/json';
  if (ADMIN_KEY) h['X-Admin-Key'] = ADMIN_KEY;
  return h;
};

export async function apiPost<T>(path: string, body: unknown): Promise<T> {
  return apiFetch<T>(path, {
    method: 'POST',
    headers: adminHeaders(),
    body: JSON.stringify(body),
  });
}

export async function apiPatch<T>(path: string, body: unknown): Promise<T> {
  return apiFetch<T>(path, {
    method: 'PATCH',
    headers: adminHeaders(),
    body: JSON.stringify(body),
  });
}

export async function apiDelete(path: string): Promise<void> {
  await rawFetch(path, { method: 'DELETE', headers: adminHeaders(false) });
}

export async function apiUpload<T>(path: string, formData: FormData): Promise<T> {
  return apiFetch<T>(path, {
    method: 'POST',
    headers: adminHeaders(false),
    body: formData,
  });
}

// ─── Types ────────────────────────────────────────────────────────────────────

export interface PlaceImage {
  id: number;
  url: string;
  r2_key?: string | null;
  is_cover: boolean;
  sort_order: number;
  content_type?: string | null;
  size_bytes?: number | null;
  created_at?: string | null;
}

export interface Place {
  id: number;
  name: string;
  description: string | null;
  image_url: string | null;
  category: string | null;
  rating: number | null;
  latitude: number | null;
  longitude: number | null;
  is_premium: boolean;
  city_id: number;
  images: PlaceImage[];
}

export interface PlaceCreate {
  name: string;
  description?: string | null;
  image_url?: string | null;
  category?: string | null;
  rating?: number | null;
  latitude?: number | null;
  longitude?: number | null;
  is_premium: boolean;
  city_id: number;
}

export type PlaceUpdate = Partial<PlaceCreate>;

export interface City {
  id: number;
  name: string;
  description: string | null;
  image_url: string | null;
  latitude: number | null;
  longitude: number | null;
  images: PlaceImage[];
}

export interface CityCreate {
  name: string;
  description?: string | null;
  image_url?: string | null;
  latitude?: number | null;
  longitude?: number | null;
}

export type CityUpdate = Partial<CityCreate>;

export interface Event {
  id: number;
  title: string;
  description: string | null;
  image_url: string | null;
  event_type: string | null;
  location: string | null;
  start_date: string | null;
  end_date: string | null;
}

export interface EventCreate {
  title: string;
  description?: string;
  image_url?: string;
  event_type?: string;
  location?: string;
  start_date?: string;
  end_date?: string;
}

export type EventUpdate = Partial<EventCreate>;

export interface User {
  id: number;
  name: string;
  email: string;
  level: number;
  is_active: boolean;
  created_at: string | null;
}

export interface MediaItem {
  id: number;
  name: string;
  data_url: string;
  folder: string | null;
  r2_key?: string | null;
  content_type?: string | null;
  size_bytes?: number | null;
  created_at: string | null;
}

export interface SiteSettings {
  site_name: string;
  site_description: string | null;
  contact_email: string | null;
  maintenance_mode: boolean;
  seo_keywords: string | null;
  updated_at: string | null;
}

export interface HealthInfo {
  status: string;
  service: string;
  r2_configured: boolean;
  r2_public_url: boolean;
  admin_configured: boolean;
  database_configured?: boolean;
}

// ─── Domain helpers ───────────────────────────────────────────────────────────

export const placeCover = (p: { images?: PlaceImage[]; image_url?: string | null }): string | null => {
  const cover = p.images?.find((i) => i.is_cover) ?? p.images?.[0];
  return cover?.url ?? p.image_url ?? null;
};
