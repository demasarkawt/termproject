import { useEffect, useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import {
  Search, Plus, Pencil, Trash2, Eye, MapPin, ImageIcon,
} from 'lucide-react';
import { cn } from '@/src/lib/utils';
import {
  apiFetch, apiPost, apiPatch, apiDelete, ApiError, placeCover, fetchHealth,
  ADMIN_KEY, attachGalleryFromMedia,
  type City, type CityCreate, type Place, type PlaceImage, type HealthInfo, type LibraryImagePick,
} from '@/src/lib/api';
import { Modal, Drawer } from '@/src/components/Modal';
import { ImageUploader, flushPendingFiles } from '@/src/components/ImageUploader';
import { MapPicker } from '@/src/components/MapPicker';
import { useToast } from '@/src/components/Toast';
import { WeatherChip } from '@/src/components/WeatherChip';

interface FormState {
  name: string;
  description: string;
  latitude: number | null;
  longitude: number | null;
}

const empty: FormState = {
  name: '',
  description: '',
  latitude: null,
  longitude: null,
};

export default function Cities() {
  const toast = useToast();
  const [cities, setCities] = useState<City[]>([]);
  const [places, setPlaces] = useState<Place[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  const [editing, setEditing] = useState<City | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState<FormState>(empty);
  const [images, setImages] = useState<PlaceImage[]>([]);
  const [pendingFiles, setPendingFiles] = useState<File[]>([]);
  const [pendingLibrary, setPendingLibrary] = useState<LibraryImagePick[]>([]);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [health, setHealth] = useState<HealthInfo | null>(null);

  const [viewing, setViewing] = useState<City | null>(null);

  const refresh = async () => {
    setLoading(true);
    try {
      const [c, p] = await Promise.all([
        apiFetch<City[]>('/api/cities/'),
        apiFetch<Place[]>('/api/places/?limit=500'),
      ]);
      setCities(c);
      setPlaces(p);
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
    void fetchHealth()
      .then(setHealth)
      .catch(() => setHealth(null));
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const filtered = useMemo(() => {
    const q = search.toLowerCase();
    return cities.filter(
      (c) =>
        !q ||
        c.name.toLowerCase().includes(q) ||
        (c.description ?? '').toLowerCase().includes(q),
    );
  }, [cities, search]);

  const placesByCity = useMemo(() => {
    const map = new Map<number, number>();
    for (const p of places) {
      map.set(p.city_id, (map.get(p.city_id) ?? 0) + 1);
    }
    return map;
  }, [places]);

  const openCreate = () => {
    setEditing(null);
    setForm(empty);
    setImages([]);
    setPendingFiles([]);
    setPendingLibrary([]);
    setError('');
    setShowForm(true);
  };

  const openEdit = (city: City) => {
    setEditing(city);
    setForm({
      name: city.name,
      description: city.description ?? '',
      latitude: city.latitude,
      longitude: city.longitude,
    });
    setImages(city.images ?? []);
    setPendingFiles([]);
    setPendingLibrary([]);
    setError('');
    setShowForm(true);
  };

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    if (!form.name.trim()) {
      setError('Name is required.');
      return;
    }
    setSaving(true);
    try {
      const payload: CityCreate = {
        name: form.name.trim(),
        description: form.description.trim() || null,
        latitude: form.latitude,
        longitude: form.longitude,
      };
      let resolvedId: number;
      if (editing) {
        await apiPatch<City>(`/api/cities/${editing.id}`, payload);
        if (pendingFiles.length) {
          await flushPendingFiles('cities', editing.id, pendingFiles);
        }
        if (pendingLibrary.length) {
          await attachGalleryFromMedia(
            'cities',
            editing.id,
            pendingLibrary.map((p) => p.id),
          );
        }
        resolvedId = editing.id;
        toast.success(`"${payload.name}" updated.`);
      } else {
        const created = await apiPost<City>('/api/cities/', payload);
        if (pendingFiles.length) {
          await flushPendingFiles('cities', created.id, pendingFiles);
        }
        if (pendingLibrary.length) {
          await attachGalleryFromMedia(
            'cities',
            created.id,
            pendingLibrary.map((p) => p.id),
          );
        }
        resolvedId = created.id;
        toast.success(`"${created.name}" created.`);
      }

      const fresh = await apiFetch<City>(`/api/cities/${resolvedId}`);
      setCities((prev) =>
        [...prev.filter((c) => c.id !== fresh.id), fresh].sort((a, b) => a.id - b.id),
      );
      setViewing((v) => (v?.id === fresh.id ? fresh : v));
      setPendingFiles([]);
      setPendingLibrary([]);
      setShowForm(false);
    } catch (err) {
      const msg = err instanceof ApiError ? err.detail ?? err.message : String(err);
      setError(msg);
      toast.error(msg);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (city: City) => {
    if (
      !confirm(
        `Delete "${city.name}"? This will fail if the city still contains places.`,
      )
    )
      return;
    try {
      await apiDelete(`/api/cities/${city.id}`);
      setCities((prev) => prev.filter((c) => c.id !== city.id));
      toast.success('City deleted.');
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    }
  };

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Cities</h1>
          <p className="text-sm text-stone-500">
            {loading ? 'Loading...' : `${filtered.length} cities`}
          </p>
        </div>
        <button
          onClick={openCreate}
          className="bg-emerald-800 text-white px-5 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/10"
        >
          <Plus className="w-5 h-5" /> Add City
        </button>
      </div>

      {health && (!health.r2_configured || !health.admin_configured) && (
        <div className="rounded-xl border border-amber-300 bg-amber-50 px-4 py-3 text-sm text-amber-950 shadow-sm">
          <p className="font-semibold">Image uploads need API configuration</p>
          <ul className="mt-2 list-disc space-y-1 pl-5 text-amber-900/90">
            {!health.admin_configured && (
              <li>Set <code className="rounded bg-amber-100 px-1">ADMIN_KEY</code> on the server (Railway/Render env).</li>
            )}
            {!health.r2_configured && (
              <li>
                Configure Cloudflare <strong>R2</strong> env vars on the API (bucket + keys + public URL). Without R2,
                uploads return 503.
              </li>
            )}
          </ul>
        </div>
      )}
      {!ADMIN_KEY && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-900">
          <strong>Dashboard missing key.</strong> Create <code className="rounded bg-red-100 px-1">dashboard/.env</code> with{' '}
          <code className="rounded bg-red-100 px-1">VITE_ADMIN_KEY=…</code> matching the API <code className="rounded bg-red-100 px-1">ADMIN_KEY</code>, then restart Vite—otherwise saves and uploads are rejected.
        </div>
      )}

      <div className="bg-white p-4 rounded-2xl border border-stone-200 shadow-sm">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search cities..."
            className="w-full pl-10 pr-4 py-2 bg-stone-50 border-none rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 transition-all outline-none"
          />
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {loading ? (
          [...Array(6)].map((_, i) => (
            <div
              key={i}
              className="rounded-2xl border border-stone-200 bg-white shadow-sm overflow-hidden"
            >
              <div className="h-40 bg-stone-100 animate-pulse" />
              <div className="space-y-2 p-4">
                <div className="h-4 w-1/2 bg-stone-100 rounded animate-pulse" />
                <div className="h-3 bg-stone-100 rounded animate-pulse" />
              </div>
            </div>
          ))
        ) : filtered.length === 0 ? (
          <div className="col-span-full rounded-2xl border border-dashed border-stone-200 bg-white p-12 text-center text-sm text-stone-500">
            No cities yet. Click <span className="font-semibold">Add City</span> to create one.
          </div>
        ) : (
          filtered.map((city) => {
            const cover = placeCover(city);
            return (
              <div
                key={city.id}
                className="group overflow-hidden rounded-2xl border border-stone-200 bg-white shadow-sm transition hover:shadow-md"
              >
                <div className="relative h-44 bg-stone-100">
                  {cover ? (
                    <img
                      src={cover}
                      alt={city.name}
                      className="h-full w-full object-cover"
                      onError={(e) => {
                        (e.target as HTMLImageElement).style.display = 'none';
                      }}
                    />
                  ) : (
                    <div className="flex h-full items-center justify-center text-stone-400">
                      <ImageIcon className="h-8 w-8" />
                    </div>
                  )}
                  <div className="absolute right-2 top-2 flex gap-1">
                    <button
                      onClick={() => setViewing(city)}
                      className="rounded-full bg-white/90 p-1.5 text-stone-600 shadow-sm transition hover:bg-white"
                      title="View"
                    >
                      <Eye className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => openEdit(city)}
                      className="rounded-full bg-white/90 p-1.5 text-emerald-700 shadow-sm transition hover:bg-white"
                      title="Edit"
                    >
                      <Pencil className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(city)}
                      className="rounded-full bg-white/90 p-1.5 text-red-600 shadow-sm transition hover:bg-white"
                      title="Delete"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </div>
                <div className="space-y-2 p-4">
                  <div className="flex items-center justify-between">
                    <h3 className="text-base font-semibold text-stone-900">{city.name}</h3>
                    <span className="rounded-md bg-emerald-50 px-2 py-0.5 text-[10px] font-bold uppercase text-emerald-700">
                      {placesByCity.get(city.id) ?? 0} places
                    </span>
                  </div>
                  <p className="line-clamp-2 text-xs text-stone-500">
                    {city.description ?? 'No description.'}
                  </p>
                  <div className="flex items-center justify-between gap-2 text-[10px] text-stone-400">
                    <div className="flex items-center gap-1">
                      <MapPin className="h-3 w-3" />
                      <span className="font-mono">
                        {city.latitude && city.longitude
                          ? `${city.latitude.toFixed(4)}, ${city.longitude.toFixed(4)}`
                          : 'no location'}
                      </span>
                    </div>
                    <WeatherChip cityId={city.id} />
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>

      <Modal
        open={showForm}
        onClose={() => setShowForm(false)}
        title={editing ? `Edit "${editing.name}"` : 'Add City'}
        description={
          editing
            ? 'Update details, manage city gallery and pin location.'
            : 'Create a city, drop images and pin its location on the map.'
        }
        size="xl"
        footer={
          <div className="flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setShowForm(false)}
              className="rounded-xl border border-stone-200 px-4 py-2 text-sm font-semibold text-stone-600 hover:bg-stone-50"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={submit}
              disabled={saving}
              className={cn(
                'inline-flex items-center gap-2 rounded-xl bg-emerald-700 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-800 disabled:opacity-60',
              )}
            >
              {saving && (
                <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/40 border-t-white" />
              )}
              {editing ? 'Save changes' : 'Create city'}
            </button>
          </div>
        }
      >
        <form onSubmit={submit} className="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <div className="space-y-4">
            {error && (
              <div className="rounded-xl border border-red-100 bg-red-50 p-3 text-sm text-red-700">
                {error}
              </div>
            )}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Name *</label>
              <input
                value={form.name}
                onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
                className="w-full rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Description</label>
              <textarea
                rows={4}
                value={form.description}
                onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))}
                className="w-full resize-none rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Location</label>
              <MapPicker
                value={{ lat: form.latitude, lng: form.longitude }}
                onChange={(p) => setForm((f) => ({ ...f, latitude: p.lat, longitude: p.lng }))}
              />
            </div>
          </div>
          <div className="space-y-3">
            <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Images</label>
            <ImageUploader
              kind="cities"
              ownerId={editing?.id ?? null}
              images={images}
              onChange={(next) => {
                setImages(next);
                if (editing) {
                  setCities((prev) =>
                    prev.map((c) => (c.id === editing.id ? { ...c, images: next } : c)),
                  );
                }
              }}
              pendingFiles={pendingFiles}
              onPendingFilesChange={setPendingFiles}
              pendingLibrary={pendingLibrary}
              onPendingLibraryChange={setPendingLibrary}
            />
          </div>
        </form>
      </Modal>

      <Drawer
        open={viewing != null}
        onClose={() => setViewing(null)}
        title={viewing?.name ?? ''}
        width="max-w-xl"
      >
        {viewing && (
          <div className="space-y-4">
            {viewing.images?.length ? (
              <div className="grid grid-cols-2 gap-2">
                {viewing.images.map((img) => (
                  <img
                    key={img.id}
                    src={img.url}
                    alt=""
                    className="aspect-video w-full rounded-lg object-cover"
                  />
                ))}
              </div>
            ) : (
              <div className="space-y-3 rounded-xl border border-dashed border-stone-200 bg-stone-50 p-6 text-center text-sm text-stone-500">
                <p>No images uploaded yet.</p>
                <p className="text-xs text-stone-400">
                  Tap <span className="font-semibold text-emerald-700">Edit</span> on the city card, then use the Images panel to upload. Photos are stored on the API (R2); the mobile app refreshes city art from the same API.
                </p>
              </div>
            )}
            <p className="text-sm leading-relaxed text-stone-700">
              {viewing.description ?? 'No description provided.'}
            </p>
            <dl className="grid grid-cols-2 gap-3 text-sm">
              <div>
                <dt className="text-xs uppercase text-stone-400">Places</dt>
                <dd className="text-stone-700">{placesByCity.get(viewing.id) ?? 0}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-stone-400">Location</dt>
                <dd className="font-mono text-xs text-stone-700">
                  {viewing.latitude && viewing.longitude
                    ? `${viewing.latitude.toFixed(4)}, ${viewing.longitude.toFixed(4)}`
                    : '—'}
                </dd>
              </div>
            </dl>
            <div className="flex justify-end gap-2 pt-2">
              <button
                onClick={() => {
                  if (viewing) openEdit(viewing);
                  setViewing(null);
                }}
                className="rounded-xl bg-emerald-700 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-800"
              >
                Edit
              </button>
            </div>
          </div>
        )}
      </Drawer>
    </div>
  );
}
