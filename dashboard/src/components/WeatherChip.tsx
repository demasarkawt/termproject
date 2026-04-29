import { useEffect, useState } from 'react';
import { Cloud, CloudRain, CloudSnow, Sun, CloudLightning, CloudDrizzle, Wind } from 'lucide-react';
import { API_URL } from '@/src/lib/api';

interface WeatherPayload {
  city_id: number | null;
  temperature_c: number | null;
  weather_code: number | null;
  description: string;
  wind_kmh: number | null;
  humidity: number | null;
  fetched_at: number;
}

interface Props {
  cityId?: number;
  lat?: number;
  lng?: number;
  size?: 'sm' | 'md';
  showDescription?: boolean;
}

const cache = new Map<string, { ts: number; data: WeatherPayload }>();
const TTL_MS = 8 * 60 * 1000;

function pickIcon(code: number | null) {
  const c = code ?? 0;
  if (c === 0 || c === 1) return Sun;
  if (c === 2 || c === 3) return Cloud;
  if (c === 45 || c === 48) return Wind;
  if (c >= 51 && c <= 57) return CloudDrizzle;
  if (c >= 61 && c <= 67) return CloudRain;
  if (c >= 71 && c <= 77) return CloudSnow;
  if (c >= 80 && c <= 86) return CloudRain;
  if (c >= 95) return CloudLightning;
  return Cloud;
}

export function WeatherChip({
  cityId,
  lat,
  lng,
  size = 'sm',
  showDescription = false,
}: Props) {
  const [data, setData] = useState<WeatherPayload | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    let cancelled = false;
    const key =
      cityId !== undefined
        ? `c:${cityId}`
        : lat !== undefined && lng !== undefined
          ? `g:${lat.toFixed(3)},${lng.toFixed(3)}`
          : null;
    if (!key) return;

    const hit = cache.get(key);
    if (hit && Date.now() - hit.ts < TTL_MS) {
      setData(hit.data);
      return;
    }

    const params = new URLSearchParams();
    if (cityId !== undefined) params.set('city_id', String(cityId));
    if (cityId === undefined && lat !== undefined && lng !== undefined) {
      params.set('lat', String(lat));
      params.set('lng', String(lng));
    }

    fetch(`${API_URL}/api/weather?${params.toString()}`)
      .then((r) => {
        if (!r.ok) throw new Error('weather fail');
        return r.json();
      })
      .then((d: WeatherPayload) => {
        if (cancelled) return;
        cache.set(key, { ts: Date.now(), data: d });
        setData(d);
      })
      .catch(() => !cancelled && setError(true));

    return () => {
      cancelled = true;
    };
  }, [cityId, lat, lng]);

  if (error || !data || data.temperature_c === null) {
    return null;
  }

  const Icon = pickIcon(data.weather_code);
  const padding = size === 'sm' ? 'px-2 py-0.5' : 'px-3 py-1';
  const text = size === 'sm' ? 'text-xs' : 'text-sm';
  const iconSize = size === 'sm' ? 'h-3 w-3' : 'h-4 w-4';

  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full font-semibold ${padding} ${text}`}
      style={{
        backgroundColor: 'var(--color-zer-soft)',
        color: 'var(--color-zer)',
      }}
      title={`${data.description} · ${data.wind_kmh ?? 0} km/h · ${data.humidity ?? 0}% humidity`}
    >
      <Icon className={iconSize} />
      {Math.round(data.temperature_c)}°C
      {showDescription && <span className="font-normal opacity-80">· {data.description}</span>}
    </span>
  );
}
