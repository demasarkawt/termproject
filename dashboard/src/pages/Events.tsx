import { useEffect, useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import { Calendar, MapPin, Search, Plus, Eye, Trash2, ChevronLeft, ChevronRight, Pencil, ImagePlus, X, RefreshCw } from 'lucide-react';
import {
  apiFetch,
  apiPost,
  apiPatch,
  apiDelete,
  apiUpload,
  ApiError,
  API_URL,
  ADMIN_KEY,
  describeUploadError,
  type Event,
  type EventCreate,
  type MediaItem,
} from '@/src/lib/api';
import { Modal, Drawer } from '@/src/components/Modal';
import { useToast } from '@/src/components/Toast';

interface SyncStatus {
  configured: boolean;
  ics_event_count: number;
  last_synced_at: string | null;
}

interface SyncResult {
  status: string;
  reason?: string;
  added?: number;
  updated?: number;
  removed?: number;
  total_in_feed?: number;
  synced_at?: string;
}

function formatLastSynced(iso: string | null): string {
  if (!iso) return 'never';
  const dt = new Date(iso);
  if (Number.isNaN(dt.getTime())) return 'never';
  const diff = Date.now() - dt.getTime();
  if (diff < 60_000) return 'just now';
  if (diff < 3600_000) return `${Math.floor(diff / 60_000)}m ago`;
  if (diff < 86400_000) return `${Math.floor(diff / 3600_000)}h ago`;
  return dt.toLocaleString();
}

const TYPE_COLORS: Record<string, string> = {
  CULTURE: 'bg-purple-100 text-purple-800',
  CULTURAL: 'bg-purple-100 text-purple-800',
  MUSIC: 'bg-pink-100 text-pink-800',
  FOOD: 'bg-amber-100 text-amber-800',
  SPORT: 'bg-blue-100 text-blue-800',
  ART: 'bg-rose-100 text-rose-800',
};

const EVENT_TYPES = ['CULTURE', 'MUSIC', 'FOOD', 'SPORT', 'ART'];
const PAGE_SIZE = 8;

const empty: EventCreate = {
  title: '',
  description: '',
  image_url: '',
  event_type: 'CULTURE',
  location: '',
  start_date: '',
  end_date: '',
};

function formatDate(dateStr: string | null | undefined) {
  if (!dateStr) return '—';
  const parts = dateStr.split('-');
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const month = parts[1] ? months[parseInt(parts[1]) - 1] : '—';
  return `${month} ${parts[2]}, ${parts[0]}`;
}

export default function Events() {
  const toast = useToast();
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedType, setSelectedType] = useState<'All' | string>('All');
  const [page, setPage] = useState(1);

  const [editing, setEditing] = useState<Event | null>(null);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState<EventCreate>(empty);
  const [imageFile, setImageFile] = useState<File | null>(null);
  /** When true, save sends `image_url: null` (clears stored cover). */
  const [stripImage, setStripImage] = useState(false);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState('');

  const [viewing, setViewing] = useState<Event | null>(null);
  const [syncStatus, setSyncStatus] = useState<SyncStatus | null>(null);
  const [syncing, setSyncing] = useState(false);

  const loadSyncStatus = async () => {
    try {
      setSyncStatus(await apiFetch<SyncStatus>('/api/events/sync/status'));
    } catch {
      setSyncStatus(null);
    }
  };

  const handleSync = async () => {
    setSyncing(true);
    try {
      const res = await fetch(`${API_URL}/api/events/sync`, {
        method: 'POST',
        headers: ADMIN_KEY ? { 'X-Admin-Key': ADMIN_KEY } : {},
      });
      const body = (await res.json()) as SyncResult;
      if (!res.ok) throw new Error(body?.reason ?? `HTTP ${res.status}`);
      if (body.status === 'skipped') {
        toast.info(body.reason ?? 'Sync skipped');
      } else {
        toast.success(
          `Synced ${body.added ?? 0} new, ${body.updated ?? 0} updated, ${body.removed ?? 0} removed`,
        );
        await refresh();
      }
      await loadSyncStatus();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : String(err));
    } finally {
      setSyncing(false);
    }
  };

  const refresh = async () => {
    setLoading(true);
    try {
      setEvents(await apiFetch<Event[]>('/api/events/'));
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
    loadSyncStatus();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  /** Open create/edit from Dashboard (sessionStorage `kg_events_open`). */
  useEffect(() => {
    if (loading) return;
    const raw = sessionStorage.getItem('kg_events_open');
    if (!raw) return;
    sessionStorage.removeItem('kg_events_open');
    if (raw === 'create') {
      setEditing(null);
      setForm(empty);
      setImageFile(null);
      setStripImage(false);
      setFormError('');
      setShowModal(true);
      return;
    }
    const id = parseInt(raw, 10);
    if (Number.isNaN(id)) return;
    const ev = events.find((e) => e.id === id);
    if (!ev) {
      toast.error('Event not found — it may have been deleted.');
      return;
    }
    setEditing(ev);
    setForm({
      title: ev.title,
      description: ev.description ?? '',
      image_url: ev.image_url ?? '',
      event_type: ev.event_type ?? 'CULTURE',
      location: ev.location ?? '',
      start_date: ev.start_date ?? '',
      end_date: ev.end_date ?? '',
    });
    setImageFile(null);
    setStripImage(false);
    setFormError('');
    setShowModal(true);
  }, [loading, events]); // eslint-disable-line react-hooks/exhaustive-deps

  const types = useMemo(
    () => ['All', ...Array.from(new Set(events.map((e) => e.event_type).filter(Boolean) as string[]))],
    [events],
  );

  const filtered = useMemo(() => {
    const q = searchQuery.toLowerCase();
    return events.filter((e) => {
      const matchSearch =
        !q ||
        e.title.toLowerCase().includes(q) ||
        (e.location ?? '').toLowerCase().includes(q);
      const matchType = selectedType === 'All' || e.event_type === selectedType;
      return matchSearch && matchType;
    });
  }, [events, searchQuery, selectedType]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const openCreate = () => {
    setEditing(null);
    setForm(empty);
    setImageFile(null);
    setStripImage(false);
    setFormError('');
    setShowModal(true);
  };

  const openEdit = (ev: Event) => {
    setEditing(ev);
    setForm({
      title: ev.title,
      description: ev.description ?? '',
      image_url: ev.image_url ?? '',
      event_type: ev.event_type ?? 'CULTURE',
      location: ev.location ?? '',
      start_date: ev.start_date ?? '',
      end_date: ev.end_date ?? '',
    });
    setImageFile(null);
    setStripImage(false);
    setFormError('');
    setShowModal(true);
  };

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setFormError('');
    if (!form.title?.trim()) {
      setFormError('Title is required.');
      return;
    }
    setSaving(true);
    try {
      let image_url: string | null | undefined = form.image_url?.trim() || undefined;
      if (imageFile) {
        try {
          const fd = new FormData();
          fd.append('file', imageFile, imageFile.name);
          fd.append('folder', 'events');
          const item = await apiUpload<MediaItem>('/api/media/upload', fd);
          image_url = item.data_url;
        } catch (upErr) {
          const uploadMsg = describeUploadError(upErr);
          setFormError(uploadMsg);
          toast.error(uploadMsg);
          return;
        }
      } else if (stripImage) {
        image_url = null;
      }

      const payload: EventCreate = {
        title: form.title.trim(),
        description: form.description?.trim() || undefined,
        event_type: form.event_type || undefined,
        location: form.location?.trim() || undefined,
        start_date: form.start_date || undefined,
        end_date: form.end_date || undefined,
        image_url,
      };

      if (editing) {
        const updated = await apiPatch<Event>(`/api/events/${editing.id}`, payload);
        setEvents((prev) => prev.map((x) => (x.id === updated.id ? updated : x)));
        toast.success(`"${updated.title}" updated.`);
      } else {
        const created = await apiPost<Event>('/api/events/', payload);
        setEvents((prev) => [created, ...prev]);
        toast.success(`"${created.title}" created.`);
      }
      setShowModal(false);
    } catch (err) {
      const msg = err instanceof ApiError ? err.detail ?? err.message : String(err);
      setFormError(msg);
      toast.error(msg);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (ev: Event) => {
    if (!confirm(`Delete "${ev.title}"?`)) return;
    try {
      await apiDelete(`/api/events/${ev.id}`);
      setEvents((prev) => prev.filter((x) => x.id !== ev.id));
      toast.success('Event deleted.');
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    }
  };

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Events Management</h1>
          <p className="text-sm text-stone-500">
            {loading ? 'Loading...' : `${filtered.length} events in your database`}
          </p>
          {syncStatus && (
            <div className="mt-2 flex items-center gap-2 text-[11px]">
              <span
                className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 font-semibold"
                style={{
                  backgroundColor: syncStatus.configured
                    ? 'var(--color-kesk-soft)'
                    : 'var(--color-zer-soft)',
                  color: syncStatus.configured ? 'var(--color-kesk)' : 'var(--color-zer)',
                }}
              >
                {syncStatus.configured
                  ? `ICS feed: ${syncStatus.ics_event_count} synced`
                  : 'ICS feed: not configured'}
              </span>
              <span className="text-subtle">
                Last sync: {formatLastSynced(syncStatus.last_synced_at)}
              </span>
            </div>
          )}
        </div>
        <div className="flex items-center gap-2 self-start">
          <button
            onClick={handleSync}
            disabled={syncing}
            title={
              syncStatus?.configured
                ? 'Pull events from EVENTS_ICS_URL now'
                : 'Set EVENTS_ICS_URL in server/.env to enable syncing'
            }
            className="bg-surface-2 text-default px-4 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-surface-3 transition-all border border-token disabled:opacity-60"
          >
            <RefreshCw className={`w-4 h-4 ${syncing ? 'animate-spin' : ''}`} />
            {syncing ? 'Syncing…' : 'Sync events'}
          </button>
          <button
            onClick={openCreate}
            className="bg-emerald-800 text-white px-5 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/10"
          >
            <Plus className="w-5 h-5" /> Add New Event
          </button>
        </div>
      </div>

      <div className="bg-white p-4 rounded-2xl border border-stone-200 shadow-sm flex flex-wrap items-center gap-4">
        <div className="flex-1 min-w-[260px] relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
          <input
            type="text"
            placeholder="Search by title or location..."
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
          value={selectedType}
          onChange={(e) => {
            setSelectedType(e.target.value);
            setPage(1);
          }}
        >
          {types.map((t) => (
            <option key={t}>{t}</option>
          ))}
        </select>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {[...Array(8)].map((_, i) => (
            <div
              key={i}
              className="bg-white rounded-2xl border border-stone-200 shadow-sm overflow-hidden animate-pulse"
            >
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
            onClick={openCreate}
            className="mt-4 text-emerald-700 text-sm font-bold hover:underline"
          >
            + Add your first event
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {paginated.map((event) => (
            <div
              key={event.id}
              className="bg-white rounded-2xl border border-stone-200 shadow-sm overflow-hidden group hover:shadow-md transition-shadow"
            >
              {event.image_url ? (
                <img
                  src={event.image_url}
                  alt={event.title}
                  className="w-full h-40 object-cover"
                  onError={(e) => {
                    (e.target as HTMLImageElement).style.display = 'none';
                  }}
                />
              ) : (
                <div className="w-full h-40 bg-gradient-to-br from-emerald-50 to-stone-100 flex items-center justify-center">
                  <Calendar className="w-12 h-12 text-emerald-200" />
                </div>
              )}
              <div className="p-4">
                <div className="flex items-start justify-between gap-2 mb-2">
                  <h3 className="text-sm font-semibold text-stone-900 line-clamp-2">{event.title}</h3>
                  {event.event_type && (
                    <span
                      className={`text-[10px] font-bold uppercase px-2 py-0.5 rounded-md shrink-0 ${
                        TYPE_COLORS[event.event_type] ?? 'bg-stone-100 text-stone-500'
                      }`}
                    >
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
                <div className="flex items-center gap-1 opacity-60 group-hover:opacity-100 transition-opacity">
                  <button
                    onClick={() => setViewing(event)}
                    className="flex-1 py-1.5 text-xs font-medium bg-stone-50 hover:bg-stone-100 rounded-lg transition-all flex items-center justify-center gap-1 text-stone-600"
                  >
                    <Eye className="w-3 h-3" /> View
                  </button>
                  <button
                    onClick={() => openEdit(event)}
                    className="py-1.5 px-3 text-xs font-medium bg-emerald-50 hover:bg-emerald-100 text-emerald-700 rounded-lg transition-all"
                    title="Edit"
                  >
                    <Pencil className="w-3 h-3" />
                  </button>
                  <button
                    onClick={() => handleDelete(event)}
                    className="py-1.5 px-3 text-xs font-medium bg-red-50 hover:bg-red-100 rounded-lg transition-all text-red-500"
                    title="Delete"
                  >
                    <Trash2 className="w-3 h-3" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {!loading && totalPages > 1 && (
        <div className="flex items-center justify-between bg-white p-4 rounded-2xl border border-stone-200 shadow-sm">
          <p className="text-xs text-stone-500 font-medium">
            Showing{' '}
            <span className="text-stone-900">
              {Math.min((page - 1) * PAGE_SIZE + 1, filtered.length)}–
              {Math.min(page * PAGE_SIZE, filtered.length)}
            </span>{' '}
            of <span className="text-stone-900">{filtered.length}</span> events
          </p>
          <div className="flex items-center gap-2">
            <button
              className="p-2 border border-stone-200 rounded-lg text-stone-400 hover:bg-stone-50 disabled:opacity-30"
              disabled={page === 1}
              onClick={() => setPage((p) => p - 1)}
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="text-xs font-bold text-stone-600 px-2">
              Page {page} of {totalPages}
            </span>
            <button
              className="p-2 border border-stone-200 rounded-lg text-stone-400 hover:bg-stone-50 disabled:opacity-30"
              disabled={page >= totalPages}
              onClick={() => setPage((p) => p + 1)}
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}

      <Modal
        open={showModal}
        onClose={() => setShowModal(false)}
        title={
          editing
            ? form.title.trim()
              ? `Edit: ${form.title.trim()}`
              : 'Edit event'
            : 'Add New Event'
        }
        description={
          editing
            ? 'Change title, dates, type, or replace the cover image. Remove image clears it on save.'
            : 'Add a title and optional cover image (upload goes to R2 when configured).'
        }
        footer={
          <div className="flex justify-end gap-2">
            <button
              onClick={() => setShowModal(false)}
              className="rounded-xl border border-stone-200 px-4 py-2 text-sm font-semibold text-stone-600 hover:bg-stone-50"
            >
              Cancel
            </button>
            <button
              onClick={submit}
              disabled={saving}
              className="inline-flex items-center gap-2 rounded-xl bg-emerald-700 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-800 disabled:opacity-60"
            >
              {saving && (
                <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/40 border-t-white" />
              )}
              {editing ? 'Save changes' : 'Create event'}
            </button>
          </div>
        }
      >
        <form onSubmit={submit} className="space-y-4">
          {formError && (
            <div className="rounded-xl border border-red-100 bg-red-50 p-3 text-sm text-red-700">
              {formError}
            </div>
          )}
          <div className="space-y-1.5">
            <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Title *</label>
            <input
              required
              value={form.title}
              onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))}
              className="w-full rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
            />
          </div>
          <div className="space-y-1.5">
            <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Description</label>
            <textarea
              rows={3}
              value={form.description ?? ''}
              onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))}
              className="w-full resize-none rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Type</label>
              <select
                value={form.event_type ?? 'CULTURE'}
                onChange={(e) => setForm((f) => ({ ...f, event_type: e.target.value }))}
                className="w-full cursor-pointer rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
              >
                {EVENT_TYPES.map((t) => (
                  <option key={t}>{t}</option>
                ))}
              </select>
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Location</label>
              <input
                value={form.location ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, location: e.target.value }))}
                className="w-full rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Start date</label>
              <input
                type="date"
                value={form.start_date ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, start_date: e.target.value }))}
                className="w-full cursor-pointer rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">End date</label>
              <input
                type="date"
                value={form.end_date ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, end_date: e.target.value }))}
                className="w-full cursor-pointer rounded-xl border border-stone-200 bg-stone-50 px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
              />
            </div>
          </div>
          <div className="space-y-1.5">
            <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Image</label>
            <div className="rounded-xl border border-dashed border-stone-300 p-3">
              <div className="flex items-center gap-3">
                {imageFile ? (
                  <img
                    src={URL.createObjectURL(imageFile)}
                    alt=""
                    className="h-16 w-24 rounded-md object-cover"
                  />
                ) : form.image_url ? (
                  <img
                    src={form.image_url}
                    alt=""
                    className="h-16 w-24 rounded-md object-cover"
                  />
                ) : (
                  <div className="flex h-16 w-24 items-center justify-center rounded-md bg-stone-100 text-stone-400">
                    <ImagePlus className="h-5 w-5" />
                  </div>
                )}
                <div className="flex-1 space-y-1">
                  <label className="inline-flex cursor-pointer items-center gap-2 rounded-lg border border-stone-200 bg-white px-3 py-1.5 text-xs font-semibold text-stone-700 hover:bg-stone-50">
                    <ImagePlus className="h-3.5 w-3.5" />
                    {imageFile ? 'Replace file' : 'Upload to R2'}
                    <input
                      type="file"
                      accept="image/*,.heic,.heif"
                      className="hidden"
                      onChange={(e) => {
                        setStripImage(false);
                        setImageFile(e.target.files?.[0] ?? null);
                      }}
                    />
                  </label>
                  {imageFile && (
                    <button
                      type="button"
                      onClick={() => setImageFile(null)}
                      className="ml-2 inline-flex items-center gap-1 text-xs text-stone-500 hover:text-stone-700"
                    >
                      <X className="h-3 w-3" /> Cancel file
                    </button>
                  )}
                  {(form.image_url || imageFile) && (
                    <button
                      type="button"
                      onClick={() => {
                        setStripImage(true);
                        setImageFile(null);
                        setForm((f) => ({ ...f, image_url: '' }));
                      }}
                      className="mt-1 inline-flex text-xs font-semibold text-red-600 hover:text-red-800"
                    >
                      Remove image
                    </button>
                  )}
                  <input
                    placeholder="...or paste an image URL"
                    value={form.image_url ?? ''}
                    onChange={(e) => setForm((f) => ({ ...f, image_url: e.target.value }))}
                    className="w-full rounded-md bg-stone-50 px-2 py-1 text-xs outline-none focus:ring-2 focus:ring-emerald-500/20"
                  />
                </div>
              </div>
            </div>
          </div>
        </form>
      </Modal>

      <Drawer
        open={viewing != null}
        onClose={() => setViewing(null)}
        title={viewing?.title ?? ''}
        description={viewing?.event_type ?? undefined}
      >
        {viewing && (
          <div className="space-y-4">
            {viewing.image_url && (
              <img
                src={viewing.image_url}
                alt={viewing.title}
                className="w-full rounded-xl object-cover"
              />
            )}
            <p className="text-sm leading-relaxed text-stone-700">
              {viewing.description ?? 'No description provided.'}
            </p>
            <dl className="grid grid-cols-2 gap-3 text-sm">
              <div>
                <dt className="text-xs uppercase text-stone-400">Location</dt>
                <dd className="text-stone-700">{viewing.location ?? '—'}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-stone-400">When</dt>
                <dd className="text-stone-700">
                  {formatDate(viewing.start_date)}
                  {viewing.end_date && viewing.end_date !== viewing.start_date
                    ? ` → ${formatDate(viewing.end_date)}`
                    : ''}
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
