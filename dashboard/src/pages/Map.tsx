import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { Filter, Pencil, Plus, MapPin } from 'lucide-react';
import {
  apiFetch,
  apiPost,
  apiPatch,
  ApiError,
  placeCover,
  PLACE_CATEGORIES,
  type Place,
  type City,
  type PlaceCreate,
  type PlaceImage,
} from '@/src/lib/api';
import { cn } from '@/src/lib/utils';
import { useToast } from '@/src/components/Toast';
import { Modal } from '@/src/components/Modal';
import { MapPicker } from '@/src/components/MapPicker';
import { ImageUploader, flushPendingFiles } from '@/src/components/ImageUploader';

const CATEGORY_COLOR: Record<string, string> = {
  CULTURE: '#a855f7',
  NATURE: '#10b981',
  FOOD: '#f59e0b',
  ADVENTURE: '#3b82f6',
  MALL: '#d946ef',
  DEFAULT: '#64748b',
};

interface FormState {
  name: string;
  description: string;
  category: string;
  rating: number;
  is_premium: boolean;
  city_id: number;
  latitude: number | null;
  longitude: number | null;
}

const emptyForm = (cityId: number, lat?: number | null, lng?: number | null): FormState => ({
  name: '',
  description: '',
  category: 'NATURE',
  rating: 0,
  is_premium: false,
  city_id: cityId,
  latitude: lat ?? null,
  longitude: lng ?? null,
});

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

/** Crosshair cursor when placing a new point. */
function PlacementCursor({ active }: { active: boolean }) {
  const map = useMap();
  useEffect(() => {
    const el = map.getContainer();
    el.style.cursor = active ? 'crosshair' : '';
    return () => {
      el.style.cursor = '';
    };
  }, [active, map]);
  return null;
}

/** Map click → add place at coordinates (only when placementMode). */
function MapPlacementClick({
  active,
  onPlaceClick,
}: {
  active: boolean;
  onPlaceClick: (lat: number, lng: number) => void;
}) {
  useMapEvents({
    click(e) {
      if (active) onPlaceClick(e.latlng.lat, e.latlng.lng);
    },
  });
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

  const [placementMode, setPlacementMode] = useState(false);
  const [showCreate, setShowCreate] = useState(false);
  const [form, setForm] = useState<FormState>(emptyForm(0));
  const [images, setImages] = useState<PlaceImage[]>([]);
  const [pendingFiles, setPendingFiles] = useState<File[]>([]);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState('');

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

  const defaultCityId = useMemo(() => {
    if (activeCity !== 'All') return activeCity as number;
    return cities[0]?.id ?? 0;
  }, [activeCity, cities]);

  const openAddModal = (lat?: number | null, lng?: number | null) => {
    setForm(emptyForm(defaultCityId, lat ?? 36.1911, lng ?? 44.0092));
    setImages([]);
    setPendingFiles([]);
    setFormError('');
    setPlacementMode(false);
    setShowCreate(true);
  };

  const handleMapClickAdd = (lat: number, lng: number) => {
    setForm(emptyForm(defaultCityId, lat, lng));
    setImages([]);
    setPendingFiles([]);
    setFormError('');
    setPlacementMode(false);
    setShowCreate(true);
    toast.success('Location set — fill in details and save.');
  };

  const handleCreateSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setFormError('');
    if (!form.name.trim()) {
      setFormError('Name is required.');
      return;
    }
    if (!form.city_id) {
      setFormError('Please pick a city.');
      return;
    }
    if (form.latitude == null || form.longitude == null) {
      setFormError('Pick a location on the mini-map below.');
      return;
    }
    setSaving(true);
    try {
      const payload: PlaceCreate = {
        name: form.name.trim(),
        description: form.description.trim() || null,
        category: form.category || null,
        rating: form.rating,
        is_premium: form.is_premium,
        city_id: form.city_id,
        latitude: form.latitude,
        longitude: form.longitude,
      };
      const created = await apiPost<Place>('/api/places/', payload);
      if (pendingFiles.length) {
        await flushPendingFiles('places', created.id, pendingFiles);
      }
      const fresh = await apiFetch<Place>(`/api/places/${created.id}`);
      setPlaces((prev) => [...prev.filter((p) => p.id !== fresh.id), fresh]);
      toast.success(`"${fresh.name}" added to the map.`);
      setShowCreate(false);
      setPendingFiles([]);
      await refresh();
    } catch (err) {
      const msg = err instanceof ApiError ? err.detail ?? err.message : String(err);
      setFormError(msg);
      toast.error(msg);
    } finally {
      setSaving(false);
    }
  };

  const visible = useMemo(
    () =>
      places.filter(
        (p) =>
          p.latitude != null &&
          p.longitude != null &&
          (activeCategories.has(p.category ?? '') || activeCategories.size === 0) &&
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
      refresh();
    }
  };

  const center: [number, number] = visible.length
    ? [visible[0].latitude!, visible[0].longitude!]
    : [36.1911, 44.0092];

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Map</h1>
          <p className="text-sm text-stone-500">
            {loading
              ? 'Loading...'
              : `${visible.length} places on the map. Drag a marker to move it.`}
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <button
            type="button"
            onClick={() => openAddModal()}
            className="inline-flex items-center gap-2 rounded-xl bg-emerald-700 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-emerald-800"
          >
            <Plus className="h-4 w-4" />
            Add place
          </button>
          <button
            type="button"
            onClick={() => {
              const next = !placementMode;
              setPlacementMode(next);
              if (next) {
                toast.info('Click the map where the new place should go.');
              }
            }}
            className={cn(
              'inline-flex items-center gap-2 rounded-xl border px-4 py-2 text-sm font-semibold transition',
              placementMode
                ? 'border-amber-500 bg-amber-50 text-amber-950'
                : 'border-stone-200 bg-white text-stone-700 hover:bg-stone-50',
            )}
          >
            <MapPin className="h-4 w-4" />
            {placementMode ? 'Cancel click-to-add' : 'Click map to add'}
          </button>
        </div>
      </div>

      {placementMode && (
        <div className="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-950">
          <strong>Click-to-add mode:</strong> choose a spot on the map. The new-place form will open with those coordinates.
        </div>
      )}

      <div className="rounded-2xl border border-stone-200 bg-white p-4 shadow-sm">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-1.5 text-xs font-semibold text-stone-500 uppercase tracking-wider">
            <Filter className="h-3.5 w-3.5" /> Filters
          </div>
          <select
            value={activeCity}
            onChange={(e) =>
              setActiveCity(
                e.target.value === 'All' ? 'All' : parseInt(e.target.value, 10),
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
                  type="button"
                  onClick={() => toggleCategory(cat)}
                  className={cn(
                    'inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider transition',
                    active
                      ? 'border-transparent text-white shadow-sm'
                      : 'border-stone-200 bg-white text-stone-400 hover:bg-stone-50',
                  )}
                  style={
                    active ? { backgroundColor: CATEGORY_COLOR[cat] } : undefined
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
          <PlacementCursor active={placementMode} />
          <MapPlacementClick active={placementMode} onPlaceClick={handleMapClickAdd} />
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
                      type="button"
                      onClick={() => onEditPlace?.(p.id)}
                      className="mt-2 inline-flex items-center gap-1.5 rounded-md bg-emerald-700 px-2.5 py-1 text-xs font-semibold text-white hover:bg-emerald-800"
                    >
                      <Pencil className="h-3 w-3" /> Edit in Places
                    </button>
                  </div>
                </Popup>
              </Marker>
            );
          })}
        </MapContainer>
      </div>

      <Modal
        open={showCreate}
        onClose={() => {
          setShowCreate(false);
          setPlacementMode(false);
        }}
        title="Add place"
        description="Set name, city, and category. Adjust the pin on the mini-map if needed."
        size="xl"
        footer={
          <div className="flex justify-end gap-2">
            <button
              type="button"
              onClick={() => {
                setShowCreate(false);
                setPlacementMode(false);
              }}
              className="rounded-xl border border-stone-200 px-4 py-2 text-sm font-semibold text-stone-600 hover:bg-stone-50"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={handleCreateSubmit}
              disabled={saving}
              className="inline-flex items-center gap-2 rounded-xl bg-emerald-700 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-800 disabled:opacity-60"
            >
              {saving && (
                <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/40 border-t-white" />
              )}
              Create place
            </button>
          </div>
        }
      >
        <form onSubmit={handleCreateSubmit} className="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <div className="space-y-4">
            {formError && (
              <div className="rounded-xl border border-red-100 bg-red-50 p-3 text-sm text-red-700">
                {formError}
              </div>
            )}
            <div className="space-y-1.5">
              <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                Name *
              </label>
              <input
                value={form.name}
                onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
                className="w-full rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
                placeholder="e.g. Sami Abdulrahman Park"
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                City *
              </label>
              <select
                value={form.city_id || ''}
                onChange={(e) =>
                  setForm((f) => ({ ...f, city_id: parseInt(e.target.value, 10) }))
                }
                className="w-full rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
              >
                <option value="">Select city</option>
                {cities.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                Category
              </label>
              <select
                value={form.category}
                onChange={(e) => setForm((f) => ({ ...f, category: e.target.value }))}
                className="w-full rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
              >
                {PLACE_CATEGORIES.map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                  Rating
                </label>
                <input
                  type="number"
                  step="0.1"
                  min={0}
                  max={5}
                  value={form.rating}
                  onChange={(e) =>
                    setForm((f) => ({ ...f, rating: parseFloat(e.target.value) || 0 }))
                  }
                  className="w-full rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
                />
              </div>
              <div className="flex items-end pb-2">
                <label className="flex cursor-pointer items-center gap-2 text-sm font-medium text-stone-700">
                  <input
                    type="checkbox"
                    checked={form.is_premium}
                    onChange={(e) =>
                      setForm((f) => ({ ...f, is_premium: e.target.checked }))
                    }
                    className="rounded border-stone-300 text-emerald-700 focus:ring-emerald-500"
                  />
                  Premium
                </label>
              </div>
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                Description
              </label>
              <textarea
                rows={3}
                value={form.description}
                onChange={(e) =>
                  setForm((f) => ({ ...f, description: e.target.value }))
                }
                className="w-full resize-none rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
              />
            </div>
          </div>
          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                Location *
              </label>
              <MapPicker
                value={{ lat: form.latitude, lng: form.longitude }}
                onChange={(p) =>
                  setForm((f) => ({ ...f, latitude: p.lat, longitude: p.lng }))
                }
                height={220}
              />
              <p className="text-xs text-stone-500">
                Click or drag the marker. Coordinates:{ ' '}
                <span className="font-mono">
                  {form.latitude?.toFixed(5) ?? '—'}, {form.longitude?.toFixed(5) ?? '—'}
                </span>
              </p>
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                Images
              </label>
              <ImageUploader
                kind="places"
                ownerId={null}
                images={images}
                onChange={setImages}
                pendingFiles={pendingFiles}
                onPendingFilesChange={setPendingFiles}
              />
              <p className="text-xs text-stone-400">
                Images upload after the place is created (same as Places page).
              </p>
            </div>
          </div>
        </form>
      </Modal>
    </div>
  );
}
