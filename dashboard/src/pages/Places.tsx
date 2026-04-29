import { useEffect, useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import {
  Search, Filter, Plus, Eye, Trash2, MapPin, Pencil,
  ChevronLeft, ChevronRight, ArrowDownToLine, Star,
} from 'lucide-react';
import { cn } from '@/src/lib/utils';
import {
  apiFetch, apiPost, apiPatch, apiDelete, ApiError,
  PLACE_CATEGORIES, placeCover,
  type Place, type City, type PlaceCreate, type PlaceImage,
} from '@/src/lib/api';
import { Modal, Drawer } from '@/src/components/Modal';
import { ImageUploader, flushPendingFiles } from '@/src/components/ImageUploader';
import { MapPicker } from '@/src/components/MapPicker';
import { useToast } from '@/src/components/Toast';
import { WeatherChip } from '@/src/components/WeatherChip';

const CATEGORY_COLORS: Record<string, string> = {
  CULTURE: 'bg-purple-100 text-purple-800',
  NATURE: 'bg-emerald-100 text-emerald-800',
  FOOD: 'bg-amber-100 text-amber-800',
  ADVENTURE: 'bg-blue-100 text-blue-800',
  MALL: 'bg-fuchsia-100 text-fuchsia-800',
};

const PAGE_SIZE = 10;

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

const emptyForm = (cityId: number): FormState => ({
  name: '',
  description: '',
  category: 'NATURE',
  rating: 0,
  is_premium: false,
  city_id: cityId,
  latitude: null,
  longitude: null,
});

export default function Places() {
  const toast = useToast();
  const [places, setPlaces] = useState<Place[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<'All' | string>('All');
  const [selectedCityId, setSelectedCityId] = useState<'All' | string>('All');
  const [premiumOnly, setPremiumOnly] = useState(false);
  const [hasImagesOnly, setHasImagesOnly] = useState(false);
  const [showFilter, setShowFilter] = useState(false);
  const [page, setPage] = useState(1);

  // Modal state
  const [editing, setEditing] = useState<Place | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [form, setForm] = useState<FormState>(emptyForm(0));
  const [images, setImages] = useState<PlaceImage[]>([]);
  const [pendingFiles, setPendingFiles] = useState<File[]>([]);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState('');

  // View drawer
  const [viewing, setViewing] = useState<Place | null>(null);

  const refresh = async () => {
    setLoading(true);
    try {
      const [p, c] = await Promise.all([
        apiFetch<Place[]>('/api/places/?limit=500'),
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

  const filtered = useMemo(() => {
    return places.filter((p) => {
      const q = searchQuery.toLowerCase();
      const matchSearch =
        !q ||
        p.name.toLowerCase().includes(q) ||
        (p.description ?? '').toLowerCase().includes(q);
      const matchCat = selectedCategory === 'All' || p.category === selectedCategory;
      const matchCity = selectedCityId === 'All' || p.city_id === parseInt(selectedCityId);
      const matchPremium = !premiumOnly || p.is_premium;
      const matchImages = !hasImagesOnly || (p.images?.length ?? 0) > 0;
      return matchSearch && matchCat && matchCity && matchPremium && matchImages;
    });
  }, [places, searchQuery, selectedCategory, selectedCityId, premiumOnly, hasImagesOnly]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);
  const cityName = (id: number) => cities.find((c) => c.id === id)?.name ?? '—';

  const openCreate = () => {
    setEditing(null);
    setForm(emptyForm(cities[0]?.id ?? 0));
    setImages([]);
    setPendingFiles([]);
    setFormError('');
    setShowCreate(true);
  };

  const openEdit = (place: Place) => {
    setEditing(place);
    setForm({
      name: place.name,
      description: place.description ?? '',
      category: place.category ?? 'NATURE',
      rating: place.rating ?? 0,
      is_premium: place.is_premium,
      city_id: place.city_id,
      latitude: place.latitude,
      longitude: place.longitude,
    });
    setImages(place.images ?? []);
    setPendingFiles([]);
    setFormError('');
    setShowCreate(true);
  };

  const closeForm = () => {
    setShowCreate(false);
    setEditing(null);
  };

  const handleSubmit = async (e: FormEvent) => {
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
      if (editing) {
        const updated = await apiPatch<Place>(`/api/places/${editing.id}`, payload);
        // Flush any pending files attached after the row already exists.
        if (pendingFiles.length) {
          const created = await flushPendingFiles('places', editing.id, pendingFiles);
          updated.images = [...(updated.images ?? []), ...created];
        }
        setPlaces((prev) => prev.map((p) => (p.id === updated.id ? updated : p)));
        toast.success(`"${updated.name}" updated.`);
      } else {
        const created = await apiPost<Place>('/api/places/', payload);
        if (pendingFiles.length) {
          const newImgs = await flushPendingFiles('places', created.id, pendingFiles);
          created.images = newImgs;
        }
        setPlaces((prev) => [created, ...prev]);
        toast.success(`"${created.name}" created.`);
      }
      closeForm();
    } catch (err) {
      const msg = err instanceof ApiError ? err.detail ?? err.message : String(err);
      setFormError(msg);
      toast.error(msg);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (place: Place) => {
    if (!confirm(`Delete "${place.name}"? This also removes all uploaded images.`)) return;
    try {
      await apiDelete(`/api/places/${place.id}`);
      setPlaces((prev) => prev.filter((p) => p.id !== place.id));
      toast.success('Place deleted.');
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    }
  };

  const exportCsv = () => {
    const rows = [
      ['id', 'name', 'category', 'city', 'rating', 'premium', 'lat', 'lng', 'image_count'],
      ...filtered.map((p) => [
        p.id,
        p.name,
        p.category ?? '',
        cityName(p.city_id),
        p.rating ?? '',
        p.is_premium ? 'true' : 'false',
        p.latitude ?? '',
        p.longitude ?? '',
        p.images?.length ?? 0,
      ]),
    ];
    const csv = rows
      .map((r) => r.map((v) => `"${String(v).replace(/"/g, '""')}"`).join(','))
      .join('\r\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `places-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
    toast.success(`Exported ${filtered.length} places.`);
  };

  const filtersActive =
    searchQuery !== '' ||
    selectedCategory !== 'All' ||
    selectedCityId !== 'All' ||
    premiumOnly ||
    hasImagesOnly;

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Places Management</h1>
          <p className="text-sm text-stone-500">
            {loading
              ? 'Loading...'
              : `${filtered.length} of ${places.length} places shown`}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={exportCsv}
            className="bg-white text-stone-700 border border-stone-200 px-4 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-stone-50 transition-all"
          >
            <ArrowDownToLine className="w-4 h-4" /> Export CSV
          </button>
          <button
            onClick={openCreate}
            className="bg-emerald-800 text-white px-5 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/10"
          >
            <Plus className="w-5 h-5" /> Add New Place
          </button>
        </div>
      </div>

      <div className="bg-white p-4 rounded-2xl border border-stone-200 shadow-sm">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex-1 min-w-[260px] relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
            <input
              type="text"
              placeholder="Search by name or description..."
              className="w-full pl-10 pr-4 py-2 bg-stone-50 border-none rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 transition-all outline-none"
              value={searchQuery}
              onChange={(e) => {
                setSearchQuery(e.target.value);
                setPage(1);
              }}
            />
          </div>
          <select
            className="bg-stone-50 border-none rounded-xl text-sm px-4 py-2 focus:ring-2 focus:ring-emerald-500/20 transition-all cursor-pointer outline-none"
            value={selectedCategory}
            onChange={(e) => {
              setSelectedCategory(e.target.value);
              setPage(1);
            }}
          >
            <option value="All">All categories</option>
            {PLACE_CATEGORIES.map((c) => (
              <option key={c}>{c}</option>
            ))}
          </select>
          <select
            className="bg-stone-50 border-none rounded-xl text-sm px-4 py-2 focus:ring-2 focus:ring-emerald-500/20 transition-all cursor-pointer outline-none"
            value={selectedCityId}
            onChange={(e) => {
              setSelectedCityId(e.target.value);
              setPage(1);
            }}
          >
            <option value="All">All cities</option>
            {cities.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
          <button
            onClick={() => setShowFilter((v) => !v)}
            className={cn(
              'p-2 rounded-xl transition-all',
              showFilter || filtersActive
                ? 'bg-emerald-50 text-emerald-700'
                : 'bg-stone-50 hover:bg-stone-100 text-stone-500',
            )}
            title="More filters"
          >
            <Filter className="w-5 h-5" />
          </button>
        </div>
        {showFilter && (
          <div className="mt-3 flex flex-wrap items-center gap-4 border-t border-stone-100 pt-3">
            <label className="flex items-center gap-2 text-sm text-stone-600">
              <input
                type="checkbox"
                checked={premiumOnly}
                onChange={(e) => {
                  setPremiumOnly(e.target.checked);
                  setPage(1);
                }}
              />
              Premium only
            </label>
            <label className="flex items-center gap-2 text-sm text-stone-600">
              <input
                type="checkbox"
                checked={hasImagesOnly}
                onChange={(e) => {
                  setHasImagesOnly(e.target.checked);
                  setPage(1);
                }}
              />
              Has images
            </label>
            {filtersActive && (
              <button
                onClick={() => {
                  setSearchQuery('');
                  setSelectedCategory('All');
                  setSelectedCityId('All');
                  setPremiumOnly(false);
                  setHasImagesOnly(false);
                  setPage(1);
                }}
                className="ml-auto text-xs font-semibold text-emerald-700 hover:underline"
              >
                Clear all filters
              </button>
            )}
          </div>
        )}
      </div>

      <div className="bg-white rounded-2xl border border-stone-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-stone-50/50 border-b border-stone-200">
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Place</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Category</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">City</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Rating</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Images</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Premium</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-100">
              {loading ? (
                [...Array(6)].map((_, i) => (
                  <tr key={i}>
                    {[...Array(7)].map((__, j) => (
                      <td key={j} className="px-6 py-4">
                        <div className="h-4 bg-stone-100 rounded animate-pulse" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : paginated.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center text-stone-400 text-sm">
                    No places match your filters.
                  </td>
                </tr>
              ) : (
                paginated.map((place) => {
                  const cover = placeCover(place);
                  return (
                    <tr key={place.id} className="hover:bg-stone-50/50 transition-colors group">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          {cover ? (
                            <img
                              src={cover}
                              alt={place.name}
                              className="w-9 h-9 rounded-lg object-cover bg-stone-100 shrink-0"
                              onError={(e) => {
                                (e.target as HTMLImageElement).style.display = 'none';
                              }}
                            />
                          ) : (
                            <div className="w-9 h-9 rounded-lg bg-stone-100 flex items-center justify-center text-stone-400 shrink-0">
                              <MapPin className="w-4 h-4" />
                            </div>
                          )}
                          <div className="min-w-0">
                            <p className="text-sm font-semibold text-stone-900">{place.name}</p>
                            <p className="text-[10px] text-stone-400 font-medium line-clamp-1 max-w-[260px]">
                              {place.description ?? '—'}
                            </p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span
                          className={cn(
                            'text-[10px] font-bold uppercase px-2 py-1 rounded-md',
                            CATEGORY_COLORS[place.category ?? ''] ?? 'bg-stone-100 text-stone-500',
                          )}
                        >
                          {place.category ?? '—'}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2 text-xs text-stone-600 font-medium">
                          <span className="inline-flex items-center gap-1">
                            <MapPin className="w-3 h-3" />
                            {cityName(place.city_id)}
                          </span>
                          <WeatherChip cityId={place.city_id} />
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-1 text-xs font-bold text-amber-600">
                          <Star className="w-3 h-3 fill-amber-400 text-amber-400" />
                          {place.rating?.toFixed(1) ?? '—'}
                        </div>
                      </td>
                      <td className="px-6 py-4 text-xs font-semibold text-stone-600">
                        {place.images?.length ?? 0}
                      </td>
                      <td className="px-6 py-4">
                        {place.is_premium ? (
                          <span className="text-[10px] font-bold uppercase px-2 py-1 rounded-md bg-purple-100 text-purple-800">
                            Premium
                          </span>
                        ) : (
                          <span className="text-[10px] font-bold uppercase px-2 py-1 rounded-md bg-stone-100 text-stone-400">
                            Free
                          </span>
                        )}
                      </td>
                      <td className="px-6 py-4 text-right">
                        <div className="flex items-center justify-end gap-1 opacity-60 group-hover:opacity-100 transition-opacity">
                          <button
                            onClick={() => setViewing(place)}
                            className="p-2 hover:bg-stone-100 rounded-lg transition-all text-stone-500"
                            title="View"
                          >
                            <Eye className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => openEdit(place)}
                            className="p-2 hover:bg-emerald-50 text-emerald-700 rounded-lg transition-all"
                            title="Edit"
                          >
                            <Pencil className="w-4 h-4" />
                          </button>
                          <button
                            className="p-2 hover:bg-red-50 text-red-500 rounded-lg transition-all"
                            title="Delete"
                            onClick={() => handleDelete(place)}
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        <div className="px-6 py-4 bg-stone-50/50 border-t border-stone-200 flex items-center justify-between">
          <p className="text-xs text-stone-500 font-medium">
            Showing{' '}
            <span className="text-stone-900">
              {filtered.length === 0 ? 0 : (page - 1) * PAGE_SIZE + 1}–
              {Math.min(page * PAGE_SIZE, filtered.length)}
            </span>{' '}
            of <span className="text-stone-900">{filtered.length}</span> places
          </p>
          <div className="flex items-center gap-2">
            <button
              className="p-2 border border-stone-200 rounded-lg text-stone-400 hover:bg-white disabled:opacity-30"
              disabled={page === 1}
              onClick={() => setPage((p) => p - 1)}
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="text-xs font-bold text-stone-600 px-2">
              Page {page} of {totalPages}
            </span>
            <button
              className="p-2 border border-stone-200 rounded-lg text-stone-400 hover:bg-white disabled:opacity-30"
              disabled={page >= totalPages}
              onClick={() => setPage((p) => p + 1)}
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Create / Edit modal */}
      <Modal
        open={showCreate}
        onClose={closeForm}
        title={editing ? `Edit "${editing.name}"` : 'Add New Place'}
        description={
          editing
            ? 'Update details, manage images, or move the marker on the map.'
            : 'Fill in the details, drop images and pick the location on the map.'
        }
        size="xl"
        footer={
          <div className="flex justify-end gap-2">
            <button
              onClick={closeForm}
              className="rounded-xl border border-stone-200 px-4 py-2 text-sm font-semibold text-stone-600 hover:bg-stone-50"
            >
              Cancel
            </button>
            <button
              onClick={handleSubmit}
              disabled={saving}
              className="inline-flex items-center gap-2 rounded-xl bg-emerald-700 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-800 disabled:opacity-60"
            >
              {saving && (
                <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/40 border-t-white" />
              )}
              {editing ? 'Save changes' : 'Create place'}
            </button>
          </div>
        }
      >
        <form onSubmit={handleSubmit} className="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <div className="space-y-4">
            {formError && (
              <div className="rounded-xl border border-red-100 bg-red-50 p-3 text-sm text-red-700">
                {formError}
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
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Category</label>
                <select
                  value={form.category}
                  onChange={(e) => setForm((f) => ({ ...f, category: e.target.value }))}
                  className="w-full cursor-pointer rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
                >
                  {PLACE_CATEGORIES.map((c) => (
                    <option key={c}>{c}</option>
                  ))}
                </select>
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">City *</label>
                <select
                  value={form.city_id}
                  onChange={(e) => setForm((f) => ({ ...f, city_id: parseInt(e.target.value) }))}
                  className="w-full cursor-pointer rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
                >
                  {cities.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Rating (0–5)</label>
                <input
                  type="number"
                  min={0}
                  max={5}
                  step={0.1}
                  value={form.rating}
                  onChange={(e) => setForm((f) => ({ ...f, rating: parseFloat(e.target.value) || 0 }))}
                  className="w-full rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
                />
              </div>
              <label className="flex items-end gap-3 cursor-pointer pb-2">
                <div
                  onClick={() => setForm((f) => ({ ...f, is_premium: !f.is_premium }))}
                  className={cn(
                    'relative h-6 w-10 rounded-full transition-colors',
                    form.is_premium ? 'bg-emerald-600' : 'bg-stone-200',
                  )}
                >
                  <div
                    className={cn(
                      'absolute top-1 h-4 w-4 rounded-full bg-white shadow-sm transition-all',
                      form.is_premium ? 'left-5' : 'left-1',
                    )}
                  />
                </div>
                <span className="text-sm font-medium text-stone-700">Premium</span>
              </label>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Location</label>
              <MapPicker
                value={{ lat: form.latitude, lng: form.longitude }}
                onChange={(p) => setForm((f) => ({ ...f, latitude: p.lat, longitude: p.lng }))}
                fallbackCenter={(() => {
                  const c = cities.find((x) => x.id === form.city_id);
                  return c?.latitude && c?.longitude
                    ? { lat: c.latitude, lng: c.longitude }
                    : { lat: 36.1911, lng: 44.0092 };
                })()}
              />
            </div>
          </div>

          <div className="space-y-3">
            <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Images</label>
            <ImageUploader
              kind="places"
              ownerId={editing?.id ?? null}
              images={images}
              onChange={(next) => {
                setImages(next);
                if (editing) {
                  setPlaces((prev) =>
                    prev.map((p) => (p.id === editing.id ? { ...p, images: next } : p)),
                  );
                }
              }}
              pendingFiles={pendingFiles}
              onPendingFilesChange={setPendingFiles}
            />
            {!editing && pendingFiles.length > 0 && (
              <p className="text-xs text-amber-700">
                {pendingFiles.length} image{pendingFiles.length === 1 ? '' : 's'} will upload to
                Cloudflare R2 right after the place is created.
              </p>
            )}
          </div>
        </form>
      </Modal>

      {/* View drawer */}
      <Drawer
        open={viewing != null}
        onClose={() => setViewing(null)}
        title={viewing?.name ?? ''}
        description={viewing?.category ?? undefined}
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
                    className="aspect-square w-full rounded-lg object-cover"
                  />
                ))}
              </div>
            ) : (
              <div className="rounded-xl border border-dashed border-stone-200 bg-stone-50 p-6 text-center text-sm text-stone-500">
                No images yet.
              </div>
            )}
            <p className="text-sm text-stone-700 leading-relaxed">
              {viewing.description ?? 'No description provided.'}
            </p>
            <dl className="grid grid-cols-2 gap-3 text-sm">
              <div>
                <dt className="text-xs uppercase text-stone-400">City</dt>
                <dd className="text-stone-700">{cityName(viewing.city_id)}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-stone-400">Rating</dt>
                <dd className="text-stone-700">{viewing.rating?.toFixed(1) ?? '—'}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-stone-400">Latitude</dt>
                <dd className="text-stone-700 font-mono text-xs">
                  {viewing.latitude ?? '—'}
                </dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-stone-400">Longitude</dt>
                <dd className="text-stone-700 font-mono text-xs">
                  {viewing.longitude ?? '—'}
                </dd>
              </div>
            </dl>
            <div className="flex justify-end gap-2 pt-2">
              <button
                onClick={() => {
                  setViewing(null);
                  if (viewing) openEdit(viewing);
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
