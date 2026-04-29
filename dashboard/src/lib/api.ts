export const API_URL =
  import.meta.env.VITE_API_URL ?? 'https://termproject-production.up.railway.app';

export async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_URL}${path}`, options);
  if (!res.ok) throw new Error(`API ${res.status}: ${res.statusText}`);
  if (res.status === 204) return undefined as T;
  return res.json() as Promise<T>;
}

export async function apiPost<T>(path: string, body: unknown): Promise<T> {
  return apiFetch<T>(path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

export async function apiDelete(path: string): Promise<void> {
  await apiFetch<void>(path, { method: 'DELETE' });
}

// ─── Types matching the Railway backend ──────────────────────────────────────

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
}

export interface PlaceCreate {
  name: string;
  description?: string;
  image_url?: string;
  category?: string;
  rating?: number;
  latitude?: number;
  longitude?: number;
  is_premium: boolean;
  city_id: number;
}

export interface City {
  id: number;
  name: string;
  description: string | null;
  image_url: string | null;
  latitude: number | null;
  longitude: number | null;
}

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
