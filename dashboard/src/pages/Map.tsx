import { useEffect, useMemo, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { Filter, Pencil } from 'lucide-react';
import {
  apiFetch, apiPatch, ApiError, placeCover, PLACE_CATEGORIES,
  type Place, type City,
} from '@/src/lib/api';
import { cn } from '@/src/lib/utils';
import { useToast } from '@/src/components/Toast';

const CATEGORY_COLOR: Record<string, string> = {
  CULTURE: '#a855f7',
  NATURE: '#10b981',
  FOOD: '#f59e0b',
  ADVENTURE: '#3b82f6',
  MALL: '#d946ef',
  DEFAULT: '#64748b',
};

function pinIcon(color: string): L.DivIcon {
  return L.divIcon({
    className: 'kg-pin',
    iconSize: [28, 36],
    iconAnchor: [14, 34],
    popupAnchor: [0, -28],
    html: `
      <svg width="28" height="36" viewBox="0 0 28 36" xmlns="http://www.w3.org/2000/svg">
        <path d="M14 0c7.7 0 14 6.3 14 14 0 9.5-14 22-14 22S0 23.5 0 14C0 6.3 6.3 0 14 0z" fill="${color}"/>
        <circle cx="14" cy="14" r="5" fill="white" />
      </svg>
    `,
  });
}

function FitBounds({ points }: { points: [number, number][] }) {
  const map = useMap();
  useEffect(() => {
    if (points.length === 0) return;
    const bounds = L.latLngBounds(points);
    map.fitBounds(bounds.pad(0.2));
  }, [points, map]);
  return null;
}

export default function MapPage({
  onEditPlace,
}: {
  onEditPlace?: (placeId: number) => void;
}) {
  const toast = useToast();
  const [places, setPlaces] = useState<Place[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeCategories, setActiveCategories] = useState<Set<string>>(
    new Set(PLACE_CATEGORIES),
  );
  const [activeCity, setActiveCity] = useState<'All' | number>('All');

  const refresh = async () => {
    setLoading(true);
    try {
      const [p, c] = await Promise.all([
        apiFetch<Place[]>('/api/places/?limit=500&has_coords=true'),
        apiFetch<City[]>('/api/cities/'),
      ]);
      setPlaces(p);
      setCities(c);
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const visible = useMemo(
    () =>
      places.filter(
        (p) =>
          p.latitude != null &&
          p.longitude != null &&
          (activeCategories.has(p.category ?? '') ||
            activeCategories.size === 0) &&
          (activeCity === 'All' || p.city_id === activeCity),
      ),
    [places, activeCategories, activeCity],
  );

  const points = visible.map(
    (p) => [p.latitude!, p.longitude!] as [number, number],
  );

  const toggleCategory = (cat: string) => {
    const next = new Set(activeCategories);
    if (next.has(cat)) next.delete(cat);
    else next.add(cat);
    setActiveCategories(next);
  };

  const handleDragMove = async (place: Place, lat: number, lng: number) => {
    try {
      const updated = await apiPatch<Place>(`/api/places/${place.id}`, {
        latitude: lat,
        longitude: lng,
      });
      setPlaces((prev) =>
        prev.map((p) => (p.id === updated.id ? { ...p, ...updated } : p)),
      );
      toast.success(`"${place.name}" moved.`);
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
      // Revert by refetching.
      refresh();
    }
  };

  const center: [number, number] = visible.length
    ? [visible[0].latitude!, visible[0].longitude!]
    : [36.1911, 44.0092];

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-stone-900">Map</h1>
        <p className="text-sm text-stone-500">
          {loading
            ? 'Loading...'
            : `${visible.length} places on the map. Drag a marker to move it.`}
        </p>
      </div>

      <div className="rounded-2xl border border-stone-200 bg-white p-4 shadow-sm">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-1.5 text-xs font-semibold text-stone-500 uppercase tracking-wider">
            <Filter className="h-3.5 w-3.5" /> Filters
          </div>
          <select
            value={activeCity}
            onChange={(e) =>
              setActiveCity(
                e.target.value === 'All' ? 'All' : parseInt(e.target.value),
              )
            }
            className="cursor-pointer rounded-xl bg-stone-50 px-3 py-1.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
          >
            <option value="All">All cities</option>
            {cities.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
          <div className="ml-auto flex flex-wrap items-center gap-1.5">
            {PLACE_CATEGORIES.map((cat) => {
              const active = activeCategories.has(cat);
              return (
                <button
                  key={cat}
                  onClick={() => toggleCategory(cat)}
                  className={cn(
                    'inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider transition',
                    active
                      ? 'border-transparent text-white shadow-sm'
                      : 'border-stone-200 bg-white text-stone-400 hover:bg-stone-50',
                  )}
                  style={
                    active
                      ? { backgroundColor: CATEGORY_COLOR[cat] }
                      : undefined
                  }
                >
                  <span
                    className="h-2 w-2 rounded-full"
                    style={{ backgroundColor: CATEGORY_COLOR[cat] }}
                  />
                  {cat}
                </button>
              );
            })}
          </div>
        </div>
      </div>

      <div className="overflow-hidden rounded-2xl border border-stone-200 bg-white shadow-sm">
        <MapContainer
          center={center}
          zoom={7}
          style={{ height: 600, width: '100%' }}
          scrollWheelZoom
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <FitBounds points={points} />
          {visible.map((p) => {
            const color = CATEGORY_COLOR[p.category ?? ''] ?? CATEGORY_COLOR.DEFAULT;
            const cover = placeCover(p);
            return (
              <Marker
                key={p.id}
                position={[p.latitude!, p.longitude!]}
                icon={pinIcon(color)}
                draggable
                eventHandlers={{
                  dragend: (e) => {
                    const m = e.target as L.Marker;
                    const ll = m.getLatLng();
                    handleDragMove(p, ll.lat, ll.lng);
                  },
                }}
              >
                <Popup>
                  <div className="w-56">
                    {cover && (
                      <img
                        src={cover}
                        alt={p.name}
                        className="mb-2 h-28 w-full rounded-md object-cover"
                      />
                    )}
                    <div className="text-sm font-semibold text-stone-900">{p.name}</div>
                    <div className="mt-0.5 text-xs text-stone-500">
                      {p.category ?? '—'} ·{' '}
                      {cities.find((c) => c.id === p.city_id)?.name ?? '—'}
                    </div>
                    {p.description && (
                      <p className="mt-1 line-clamp-3 text-xs text-stone-600">
                        {p.description}
                      </p>
                    )}
                    <button
                      onClick={() => onEditPlace?.(p.id)}
                      className="mt-2 inline-flex items-center gap-1.5 rounded-md bg-emerald-700 px-2.5 py-1 text-xs font-semibold text-white hover:bg-emerald-800"
                    >
                      <Pencil className="h-3 w-3" /> Edit
                    </button>
                  </div>
                </Popup>
              </Marker>
            );
          })}
        </MapContainer>
      </div>
    </div>
  );
}
