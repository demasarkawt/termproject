import { useEffect, useState } from 'react';
import {
  Search, Filter, Plus, Eye, Trash2, MapPin,
  ChevronLeft, ChevronRight, ArrowUpDown, Star, X
} from 'lucide-react';
import { cn } from '@/src/lib/utils';
import { apiFetch, apiPost, apiDelete, type Place, type City, type PlaceCreate } from '@/src/lib/api';

const STATUS_COLORS: Record<string, string> = {
  CULTURE: 'bg-purple-100 text-purple-800',
  NATURE: 'bg-emerald-100 text-emerald-800',
  FOOD: 'bg-amber-100 text-amber-800',
  ADVENTURE: 'bg-blue-100 text-blue-800',
};

const CATEGORIES = ['NATURE', 'CULTURE', 'FOOD', 'ADVENTURE'];
const PAGE_SIZE = 10;

const emptyForm: PlaceCreate = {
  name: '',
  description: '',
  image_url: '',
  category: 'NATURE',
  rating: 0,
  latitude: undefined,
  longitude: undefined,
  is_premium: false,
  city_id: 0,
};

export default function Places() {
  const [places, setPlaces] = useState<Place[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedCityId, setSelectedCityId] = useState('All');
  const [page, setPage] = useState(1);

  // Modal state
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState<PlaceCreate>(emptyForm);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState('');

  // Delete state
  const [deletingId, setDeletingId] = useState<number | null>(null);

  useEffect(() => {
    Promise.all([
      apiFetch<Place[]>('/api/places/?limit=100'),
      apiFetch<City[]>('/api/cities/'),
    ])
      .then(([p, c]) => {
        setPlaces(p);
        setCities(c);
        // Set default city_id to first city
        if (c.length > 0) setForm(f => ({ ...f, city_id: c[0].id }));
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const categories = ['All', ...Array.from(new Set(places.map(p => p.category).filter(Boolean) as string[]))];

  const filtered = places.filter(p => {
    const matchSearch = p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (p.description ?? '').toLowerCase().includes(searchQuery.toLowerCase());
    const matchCat = selectedCategory === 'All' || p.category === selectedCategory;
    const matchCity = selectedCityId === 'All' || p.city_id === parseInt(selectedCityId);
    return matchSearch && matchCat && matchCity;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const cityName = (id: number) => cities.find(c => c.id === id)?.name ?? '—';

  const openModal = () => {
    setForm({ ...emptyForm, city_id: cities[0]?.id ?? 0 });
    setFormError('');
    setShowModal(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name.trim()) { setFormError('Name is required.'); return; }
    if (!form.city_id) { setFormError('Please select a city.'); return; }
    setSaving(true);
    setFormError('');
    try {
      const created = await apiPost<Place>('/api/places/', form);
      setPlaces(prev => [created, ...prev]);
      setShowModal(false);
    } catch (err: any) {
      setFormError(err.message ?? 'Failed to create place.');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this place? This cannot be undone.')) return;
    setDeletingId(id);
    try {
      await apiDelete(`/api/places/${id}`);
      setPlaces(prev => prev.filter(p => p.id !== id));
    } catch (err) {
      alert('Failed to delete place.');
    } finally {
      setDeletingId(null);
    }
  };

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Places Management</h1>
          <p className="text-sm text-stone-500">
            {loading ? 'Loading...' : `${filtered.length} places found in your database`}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button className="bg-white text-stone-700 border border-stone-200 px-4 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-stone-50 transition-all">
            <ArrowUpDown className="w-4 h-4" /> Export CSV
          </button>
          <button
            onClick={openModal}
            className="bg-emerald-800 text-white px-5 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/10"
          >
            <Plus className="w-5 h-5" /> Add New Place
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-2xl border border-stone-200 shadow-sm flex flex-wrap items-center gap-4">
        <div className="flex-1 min-w-[260px] relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
          <input
            type="text"
            placeholder="Search by name or description..."
            className="w-full pl-10 pr-4 py-2 bg-stone-50 border-none rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 transition-all outline-none"
            value={searchQuery}
            onChange={(e) => { setSearchQuery(e.target.value); setPage(1); }}
          />
        </div>
        <select
          className="bg-stone-50 border-none rounded-xl text-sm px-4 py-2 focus:ring-2 focus:ring-emerald-500/20 transition-all cursor-pointer outline-none"
          value={selectedCategory}
          onChange={(e) => { setSelectedCategory(e.target.value); setPage(1); }}
        >
          {categories.map(c => <option key={c}>{c}</option>)}
        </select>
        <select
          className="bg-stone-50 border-none rounded-xl text-sm px-4 py-2 focus:ring-2 focus:ring-emerald-500/20 transition-all cursor-pointer outline-none"
          value={selectedCityId}
          onChange={(e) => { setSelectedCityId(e.target.value); setPage(1); }}
        >
          <option value="All">All Cities</option>
          {cities.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
        </select>
        <button className="p-2 bg-stone-50 rounded-xl hover:bg-stone-100 transition-all">
          <Filter className="w-5 h-5 text-stone-500" />
        </button>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl border border-stone-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-stone-50/50 border-b border-stone-200">
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Place</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Category</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">City</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Rating</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Premium</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-100">
              {loading ? (
                [...Array(6)].map((_, i) => (
                  <tr key={i}>
                    {[...Array(6)].map((_, j) => (
                      <td key={j} className="px-6 py-4">
                        <div className="h-4 bg-stone-100 rounded animate-pulse" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : paginated.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-stone-400 text-sm">
                    No places match your filters.
                  </td>
                </tr>
              ) : (
                paginated.map((place) => (
                  <tr key={place.id} className="hover:bg-stone-50/50 transition-colors group">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        {place.image_url && (
                          <img src={place.image_url} alt={place.name}
                            className="w-9 h-9 rounded-lg object-cover bg-stone-100 shrink-0"
                            onError={e => { (e.target as HTMLImageElement).style.display = 'none'; }} />
                        )}
                        <div>
                          <p className="text-sm font-semibold text-stone-900">{place.name}</p>
                          <p className="text-[10px] text-stone-400 font-medium line-clamp-1 max-w-[260px]">
                            {place.description ?? '—'}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={cn(
                        "text-[10px] font-bold uppercase px-2 py-1 rounded-md",
                        STATUS_COLORS[place.category ?? ''] ?? 'bg-stone-100 text-stone-500'
                      )}>
                        {place.category ?? '—'}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-1.5 text-xs text-stone-600 font-medium">
                        <MapPin className="w-3 h-3" />{cityName(place.city_id)}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-1 text-xs font-bold text-amber-600">
                        <Star className="w-3 h-3 fill-amber-400 text-amber-400" />
                        {place.rating?.toFixed(1) ?? '—'}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      {place.is_premium ? (
                        <span className="text-[10px] font-bold uppercase px-2 py-1 rounded-md bg-purple-100 text-purple-800">Premium</span>
                      ) : (
                        <span className="text-[10px] font-bold uppercase px-2 py-1 rounded-md bg-stone-100 text-stone-400">Free</span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button className="p-2 hover:bg-stone-100 rounded-lg transition-all text-stone-400" title="View">
                          <Eye className="w-4 h-4" />
                        </button>
                        <button
                          className="p-2 hover:bg-red-50 text-red-400 rounded-lg transition-all disabled:opacity-50"
                          title="Delete"
                          disabled={deletingId === place.id}
                          onClick={() => handleDelete(place.id)}
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="px-6 py-4 bg-stone-50/50 border-t border-stone-200 flex items-center justify-between">
          <p className="text-xs text-stone-500 font-medium">
            Showing <span className="text-stone-900">{Math.min((page - 1) * PAGE_SIZE + 1, filtered.length)}–{Math.min(page * PAGE_SIZE, filtered.length)}</span> of <span className="text-stone-900">{filtered.length}</span> places
          </p>
          <div className="flex items-center gap-2">
            <button
              className="p-2 border border-stone-200 rounded-lg text-stone-400 hover:bg-white disabled:opacity-30"
              disabled={page === 1}
              onClick={() => setPage(p => p - 1)}
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="text-xs font-bold text-stone-600 px-2">Page {page} of {totalPages || 1}</span>
            <button
              className="p-2 border border-stone-200 rounded-lg text-stone-400 hover:bg-white disabled:opacity-30"
              disabled={page >= totalPages}
              onClick={() => setPage(p => p + 1)}
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Add Place Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between p-6 border-b border-stone-200">
              <h2 className="text-lg font-bold">Add New Place</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-stone-100 rounded-lg transition-all">
                <X className="w-5 h-5 text-stone-400" />
              </button>
            </div>
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              {formError && (
                <div className="p-3 bg-red-50 border border-red-100 rounded-xl text-sm text-red-700">{formError}</div>
              )}
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Name *</label>
                <input type="text" required value={form.name}
                  onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
                  className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20" />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Description</label>
                <textarea rows={3} value={form.description ?? ''}
                  onChange={e => setForm(f => ({ ...f, description: e.target.value }))}
                  className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20 resize-none" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Category</label>
                  <select value={form.category ?? 'NATURE'}
                    onChange={e => setForm(f => ({ ...f, category: e.target.value }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20 cursor-pointer">
                    {CATEGORIES.map(c => <option key={c}>{c}</option>)}
                  </select>
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">City *</label>
                  <select value={form.city_id}
                    onChange={e => setForm(f => ({ ...f, city_id: parseInt(e.target.value) }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20 cursor-pointer">
                    {cities.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                  </select>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Rating (0–5)</label>
                  <input type="number" min={0} max={5} step={0.1} value={form.rating ?? 0}
                    onChange={e => setForm(f => ({ ...f, rating: parseFloat(e.target.value) }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20" />
                </div>
                <div className="space-y-1.5 flex flex-col justify-end">
                  <label className="flex items-center gap-3 cursor-pointer">
                    <div
                      onClick={() => setForm(f => ({ ...f, is_premium: !f.is_premium }))}
                      className={cn('w-10 h-6 rounded-full relative transition-colors', form.is_premium ? 'bg-emerald-600' : 'bg-stone-200')}
                    >
                      <div className={cn('absolute top-1 w-4 h-4 bg-white rounded-full shadow-sm transition-all', form.is_premium ? 'left-5' : 'left-1')} />
                    </div>
                    <span className="text-sm font-medium text-stone-700">Premium</span>
                  </label>
                </div>
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Image URL</label>
                <input type="url" value={form.image_url ?? ''}
                  onChange={e => setForm(f => ({ ...f, image_url: e.target.value }))}
                  placeholder="https://..."
                  className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Latitude</label>
                  <input type="number" step="any" value={form.latitude ?? ''}
                    onChange={e => setForm(f => ({ ...f, latitude: e.target.value ? parseFloat(e.target.value) : undefined }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20" />
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Longitude</label>
                  <input type="number" step="any" value={form.longitude ?? ''}
                    onChange={e => setForm(f => ({ ...f, longitude: e.target.value ? parseFloat(e.target.value) : undefined }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20" />
                </div>
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setShowModal(false)}
                  className="flex-1 py-2.5 text-sm font-bold text-stone-500 border border-stone-200 rounded-xl hover:bg-stone-50 transition-all">
                  Cancel
                </button>
                <button type="submit" disabled={saving}
                  className="flex-1 py-2.5 text-sm font-bold bg-emerald-800 text-white rounded-xl hover:bg-emerald-900 transition-all disabled:opacity-60 flex items-center justify-center gap-2">
                  {saving ? <><div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />Saving...</> : 'Add Place'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
