import { useEffect, useState } from 'react';
import { Calendar, MapPin, Search, Plus, Eye, Trash2, ChevronLeft, ChevronRight, X } from 'lucide-react';
import { cn } from '@/src/lib/utils';
import { apiFetch, apiPost, apiDelete, type Event, type EventCreate } from '@/src/lib/api';

const TYPE_COLORS: Record<string, string> = {
  CULTURAL: 'bg-purple-100 text-purple-800',
  MUSIC: 'bg-pink-100 text-pink-800',
  FOOD: 'bg-amber-100 text-amber-800',
  SPORT: 'bg-blue-100 text-blue-800',
  ART: 'bg-rose-100 text-rose-800',
};

const EVENT_TYPES = ['CULTURAL', 'MUSIC', 'FOOD', 'SPORT', 'ART'];
const PAGE_SIZE = 8;

const emptyForm: EventCreate = {
  title: '',
  description: '',
  image_url: '',
  event_type: 'CULTURAL',
  location: '',
  start_date: '',
  end_date: '',
};

function formatDate(dateStr: string | null | undefined) {
  if (!dateStr) return '—';
  const parts = dateStr.split('-');
  const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const month = parts[1] ? monthNames[parseInt(parts[1]) - 1] : '—';
  return `${month} ${parts[2]}, ${parts[0]}`;
}

export default function Events() {
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedType, setSelectedType] = useState('All');
  const [page, setPage] = useState(1);

  // Modal
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState<EventCreate>(emptyForm);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState('');

  // Delete
  const [deletingId, setDeletingId] = useState<number | null>(null);

  useEffect(() => {
    apiFetch<Event[]>('/api/events/')
      .then(setEvents)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const types = ['All', ...Array.from(new Set(events.map(e => e.event_type).filter(Boolean) as string[]))];

  const filtered = events.filter(e => {
    const matchSearch = e.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (e.location ?? '').toLowerCase().includes(searchQuery.toLowerCase());
    const matchType = selectedType === 'All' || e.event_type === selectedType;
    return matchSearch && matchType;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.title.trim()) { setFormError('Title is required.'); return; }
    setSaving(true);
    setFormError('');
    try {
      const created = await apiPost<Event>('/api/events/', form);
      setEvents(prev => [created, ...prev]);
      setShowModal(false);
      setForm(emptyForm);
    } catch (err: any) {
      setFormError(err.message ?? 'Failed to create event.');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this event? This cannot be undone.')) return;
    setDeletingId(id);
    try {
      await apiDelete(`/api/events/${id}`);
      setEvents(prev => prev.filter(e => e.id !== id));
    } catch {
      alert('Failed to delete event.');
    } finally {
      setDeletingId(null);
    }
  };

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Events Management</h1>
          <p className="text-sm text-stone-500">
            {loading ? 'Loading...' : `${filtered.length} events in your database`}
          </p>
        </div>
        <button
          onClick={() => { setForm(emptyForm); setFormError(''); setShowModal(true); }}
          className="bg-emerald-800 text-white px-5 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/10 self-start"
        >
          <Plus className="w-5 h-5" /> Add New Event
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-2xl border border-stone-200 shadow-sm flex flex-wrap items-center gap-4">
        <div className="flex-1 min-w-[260px] relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
          <input
            type="text"
            placeholder="Search by title or location..."
            className="w-full pl-10 pr-4 py-2 bg-stone-50 border-none rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 transition-all outline-none"
            value={searchQuery}
            onChange={(e) => { setSearchQuery(e.target.value); setPage(1); }}
          />
        </div>
        <select
          className="bg-stone-50 border-none rounded-xl text-sm px-4 py-2 focus:ring-2 focus:ring-emerald-500/20 transition-all cursor-pointer outline-none"
          value={selectedType}
          onChange={(e) => { setSelectedType(e.target.value); setPage(1); }}
        >
          {types.map(t => <option key={t}>{t}</option>)}
        </select>
      </div>

      {/* Events Grid */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {[...Array(8)].map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-stone-200 shadow-sm overflow-hidden animate-pulse">
              <div className="h-40 bg-stone-100" />
              <div className="p-4 space-y-2">
                <div className="h-4 bg-stone-100 rounded w-3/4" />
                <div className="h-3 bg-stone-100 rounded w-1/2" />
              </div>
            </div>
          ))}
        </div>
      ) : paginated.length === 0 ? (
        <div className="bg-white rounded-2xl border border-stone-200 shadow-sm p-16 text-center">
          <Calendar className="w-12 h-12 text-stone-200 mx-auto mb-4" />
          <p className="text-stone-400 text-sm">No events match your filters.</p>
          <button
            onClick={() => { setForm(emptyForm); setFormError(''); setShowModal(true); }}
            className="mt-4 text-emerald-700 text-sm font-bold hover:underline"
          >
            + Add your first event
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {paginated.map((event) => (
            <div key={event.id} className="bg-white rounded-2xl border border-stone-200 shadow-sm overflow-hidden group hover:shadow-md transition-shadow">
              {event.image_url ? (
                <img src={event.image_url} alt={event.title} className="w-full h-40 object-cover"
                  onError={e => { (e.target as HTMLImageElement).style.display = 'none'; }} />
              ) : (
                <div className="w-full h-40 bg-gradient-to-br from-emerald-50 to-stone-100 flex items-center justify-center">
                  <Calendar className="w-12 h-12 text-emerald-200" />
                </div>
              )}
              <div className="p-4">
                <div className="flex items-start justify-between gap-2 mb-2">
                  <h3 className="text-sm font-semibold text-stone-900 line-clamp-2">{event.title}</h3>
                  {event.event_type && (
                    <span className={`text-[10px] font-bold uppercase px-2 py-0.5 rounded-md shrink-0 ${TYPE_COLORS[event.event_type] ?? 'bg-stone-100 text-stone-500'}`}>
                      {event.event_type}
                    </span>
                  )}
                </div>
                {event.location && (
                  <div className="flex items-center gap-1 text-xs text-stone-400 mb-2">
                    <MapPin className="w-3 h-3" />
                    <span className="truncate">{event.location}</span>
                  </div>
                )}
                <div className="flex items-center gap-1 text-xs text-stone-400 mb-3">
                  <Calendar className="w-3 h-3" />
                  <span>{formatDate(event.start_date)}</span>
                  {event.end_date && event.end_date !== event.start_date && (
                    <span>→ {formatDate(event.end_date)}</span>
                  )}
                </div>
                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button className="flex-1 py-1.5 text-xs font-medium bg-stone-50 hover:bg-stone-100 rounded-lg transition-all flex items-center justify-center gap-1 text-stone-600">
                    <Eye className="w-3 h-3" /> View
                  </button>
                  <button
                    disabled={deletingId === event.id}
                    onClick={() => handleDelete(event.id)}
                    className="py-1.5 px-3 text-xs font-medium bg-red-50 hover:bg-red-100 rounded-lg transition-all text-red-500 disabled:opacity-50"
                  >
                    <Trash2 className="w-3 h-3" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Pagination */}
      {!loading && totalPages > 1 && (
        <div className="flex items-center justify-between bg-white p-4 rounded-2xl border border-stone-200 shadow-sm">
          <p className="text-xs text-stone-500 font-medium">
            Showing <span className="text-stone-900">{Math.min((page - 1) * PAGE_SIZE + 1, filtered.length)}–{Math.min(page * PAGE_SIZE, filtered.length)}</span> of <span className="text-stone-900">{filtered.length}</span> events
          </p>
          <div className="flex items-center gap-2">
            <button className="p-2 border border-stone-200 rounded-lg text-stone-400 hover:bg-stone-50 disabled:opacity-30"
              disabled={page === 1} onClick={() => setPage(p => p - 1)}>
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="text-xs font-bold text-stone-600 px-2">Page {page} of {totalPages}</span>
            <button className="p-2 border border-stone-200 rounded-lg text-stone-400 hover:bg-stone-50 disabled:opacity-30"
              disabled={page >= totalPages} onClick={() => setPage(p => p + 1)}>
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}

      {/* Add Event Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between p-6 border-b border-stone-200">
              <h2 className="text-lg font-bold">Add New Event</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-stone-100 rounded-lg transition-all">
                <X className="w-5 h-5 text-stone-400" />
              </button>
            </div>
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              {formError && (
                <div className="p-3 bg-red-50 border border-red-100 rounded-xl text-sm text-red-700">{formError}</div>
              )}
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Title *</label>
                <input type="text" required value={form.title}
                  onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
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
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Event Type</label>
                  <select value={form.event_type ?? 'CULTURAL'}
                    onChange={e => setForm(f => ({ ...f, event_type: e.target.value }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20 cursor-pointer">
                    {EVENT_TYPES.map(t => <option key={t}>{t}</option>)}
                  </select>
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Location</label>
                  <input type="text" value={form.location ?? ''}
                    onChange={e => setForm(f => ({ ...f, location: e.target.value }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20" />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Start Date</label>
                  <input type="date" value={form.start_date ?? ''}
                    onChange={e => setForm(f => ({ ...f, start_date: e.target.value }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20 cursor-pointer" />
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">End Date</label>
                  <input type="date" value={form.end_date ?? ''}
                    onChange={e => setForm(f => ({ ...f, end_date: e.target.value }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20 cursor-pointer" />
                </div>
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Image URL</label>
                <input type="url" value={form.image_url ?? ''}
                  onChange={e => setForm(f => ({ ...f, image_url: e.target.value }))}
                  placeholder="https://..."
                  className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20" />
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setShowModal(false)}
                  className="flex-1 py-2.5 text-sm font-bold text-stone-500 border border-stone-200 rounded-xl hover:bg-stone-50 transition-all">
                  Cancel
                </button>
                <button type="submit" disabled={saving}
                  className="flex-1 py-2.5 text-sm font-bold bg-emerald-800 text-white rounded-xl hover:bg-emerald-900 transition-all disabled:opacity-60 flex items-center justify-center gap-2">
                  {saving ? <><div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />Saving...</> : 'Add Event'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
