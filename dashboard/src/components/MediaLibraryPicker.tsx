import { useEffect, useMemo, useState } from 'react';
import { Loader2, Search } from 'lucide-react';
import { Modal } from '@/src/components/Modal';
import { useToast } from '@/src/components/Toast';
import { apiFetch, ApiError, type MediaItem } from '@/src/lib/api';
import { cn } from '@/src/lib/utils';

function isProbablyImage(mi: MediaItem): boolean {
  const c = mi.content_type?.toLowerCase() ?? '';
  if (c.startsWith('image/')) return true;
  const u = (mi.data_url || '').split('?')[0].toLowerCase();
  return /\.(jpe?g|png|gif|webp|heic|heif|bmp|svg)$/i.test(u);
}

export type MediaPickResult = Pick<MediaItem, 'id' | 'data_url' | 'name'>;

interface MediaLibraryPickerProps {
  open: boolean;
  onClose: () => void;
  /** Confirmed selections (typically multi-select toggles → one confirm). */
  onConfirm: (items: MediaPickResult[]) => void;
  excludeMediaIds?: ReadonlySet<number>;
  title?: string;
}

/** Browse `/api/media` items and attach by numeric `MediaItem.id`. */
export function MediaLibraryPicker({
  open,
  onClose,
  onConfirm,
  excludeMediaIds,
  title = 'Media library',
}: MediaLibraryPickerProps) {
  const toast = useToast();
  const [loading, setLoading] = useState(true);
  const [items, setItems] = useState<MediaItem[]>([]);
  const [q, setQ] = useState('');
  const [selected, setSelected] = useState<Set<number>>(new Set());

  useEffect(() => {
    if (!open) return;
    setSelected(new Set());
    setQ('');
    let cancelled = false;
    setLoading(true);
    (async () => {
      try {
        const list = await apiFetch<MediaItem[]>('/api/media/');
        if (!cancelled) setItems(list);
      } catch (err) {
        if (!cancelled)
          toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [open]); // eslint-disable-line react-hooks/exhaustive-deps

  const visible = useMemo(() => {
    const fq = q.trim().toLowerCase();
    return items.filter((m) => {
      if (!isProbablyImage(m)) return false;
      if (excludeMediaIds?.has(m.id)) return false;
      if (!fq) return true;
      const name = `${m.name} ${m.id}`.toLowerCase();
      return name.includes(fq);
    });
  }, [items, q, excludeMediaIds]);

  const toggle = (id: number) =>
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });

  const confirm = () => {
    const out: MediaPickResult[] = [];
    for (const id of selected) {
      const row = items.find((x) => x.id === id);
      if (row)
        out.push({ id: row.id, data_url: row.data_url, name: row.name });
    }
    onConfirm(out);
    onClose();
  };

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={title}
      description="Each stored upload has an ID shown on the thumbnail. Selecting here uses that asset for the place gallery (no duplicate file upload)."
      size="lg"
      footer={
        <div className="flex justify-end gap-2">
          <button
            type="button"
            onClick={onClose}
            className="rounded-xl border border-stone-200 px-4 py-2 text-sm font-semibold text-stone-600 hover:bg-stone-50"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={confirm}
            disabled={selected.size === 0}
            className="rounded-xl bg-emerald-700 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-800 disabled:opacity-50"
          >
            Add selected ({selected.size})
          </button>
        </div>
      }
    >
      <div className="space-y-4">
        <div className="relative">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-stone-400" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search by name or ID..."
            className="w-full rounded-xl border border-stone-200 bg-stone-50 py-2.5 pl-10 pr-4 text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
          />
        </div>

        {loading ? (
          <div className="flex items-center justify-center gap-2 py-12 text-sm text-stone-500">
            <Loader2 className="h-5 w-5 animate-spin text-emerald-600" />
            Loading media…
          </div>
        ) : visible.length === 0 ? (
          <p className="rounded-xl border border-dashed border-stone-200 py-12 text-center text-sm text-stone-500">
            No library images yet. Upload some in{' '}
            <strong className="text-stone-700">Media Library → Upload Files</strong> first.
          </p>
        ) : (
          <div className="grid max-h-[50vh] grid-cols-2 gap-3 overflow-y-auto sm:grid-cols-3 md:grid-cols-4">
            {visible.map((m) => {
              const sel = selected.has(m.id);
              return (
                <button
                  key={m.id}
                  type="button"
                  onClick={() => toggle(m.id)}
                  className={cn(
                    'group relative overflow-hidden rounded-xl border bg-stone-100 text-left transition',
                    sel
                      ? 'border-emerald-500 ring-2 ring-emerald-500/25'
                      : 'border-stone-200 hover:border-emerald-300',
                  )}
                >
                  <div className="aspect-square bg-stone-200">
                    <img
                      src={m.data_url}
                      alt=""
                      className="h-full w-full object-cover"
                    />
                  </div>
                  <div className="space-y-0.5 p-2">
                    <p className="truncate text-[11px] font-semibold text-stone-800">{m.name}</p>
                    <p className="font-mono text-[10px] font-bold text-emerald-800">Media ID #{m.id}</p>
                  </div>
                  {sel && (
                    <div className="absolute right-2 top-2 rounded-full bg-emerald-600 px-2 py-0.5 text-[10px] font-bold uppercase text-white">
                      Selected
                    </div>
                  )}
                </button>
              );
            })}
          </div>
        )}
      </div>
    </Modal>
  );
}
