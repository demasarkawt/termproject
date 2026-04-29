import { useEffect, useRef, useState } from 'react';
import { Bell, X, Trash2 } from 'lucide-react';

interface ActivityItem {
  id: string;
  ts: number;
  message: string;
  kind: 'info' | 'success' | 'warn';
}

const STORAGE_KEY = 'kg-recent-activity';
const MAX_ITEMS = 30;

export function recordActivity(message: string, kind: ActivityItem['kind'] = 'info') {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    const list: ActivityItem[] = raw ? JSON.parse(raw) : [];
    list.unshift({ id: `${Date.now()}-${Math.random()}`, ts: Date.now(), message, kind });
    while (list.length > MAX_ITEMS) list.pop();
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
    window.dispatchEvent(new CustomEvent('kg-activity-changed'));
  } catch {
    /* localStorage may be unavailable */
  }
}

function readActivity(): ActivityItem[] {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    return raw ? (JSON.parse(raw) as ActivityItem[]) : [];
  } catch {
    return [];
  }
}

export function NotificationsBell() {
  const [open, setOpen] = useState(false);
  const [items, setItems] = useState<ActivityItem[]>([]);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const reload = () => setItems(readActivity());
    reload();
    window.addEventListener('kg-activity-changed', reload);
    window.addEventListener('storage', reload);
    return () => {
      window.removeEventListener('kg-activity-changed', reload);
      window.removeEventListener('storage', reload);
    };
  }, []);

  useEffect(() => {
    if (!open) return;
    const onClick = (e: MouseEvent) => {
      if (!containerRef.current?.contains(e.target as Node)) setOpen(false);
    };
    window.addEventListener('mousedown', onClick);
    return () => window.removeEventListener('mousedown', onClick);
  }, [open]);

  const clearAll = () => {
    window.localStorage.removeItem(STORAGE_KEY);
    window.dispatchEvent(new CustomEvent('kg-activity-changed'));
  };

  return (
    <div ref={containerRef} className="relative">
      <button
        onClick={() => setOpen((v) => !v)}
        title="Recent activity"
        className="relative rounded-full p-2 text-muted hover:bg-surface-2 transition-all"
      >
        <Bell className="w-5 h-5" />
        {items.length > 0 && (
          <span
            className="absolute right-1 top-1 inline-flex h-4 min-w-4 items-center justify-center rounded-full bg-sor px-1 text-[10px] font-bold text-white"
            style={{ backgroundColor: 'var(--color-sor)' }}
          >
            {items.length}
          </span>
        )}
      </button>
      {open && (
        <div
          className="absolute right-0 z-50 mt-2 w-80 rounded-2xl border border-token shadow-2xl"
          style={{ backgroundColor: 'var(--color-card)' }}
        >
          <div className="flex items-center justify-between border-b border-token px-4 py-3">
            <div>
              <div className="text-sm font-bold text-default">Recent activity</div>
              <div className="text-[10px] uppercase tracking-wider text-subtle">
                Local to this browser
              </div>
            </div>
            <div className="flex items-center gap-1">
              {items.length > 0 && (
                <button
                  onClick={clearAll}
                  title="Clear all"
                  className="rounded-md p-1.5 text-subtle hover:bg-surface-2 hover:text-default"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                </button>
              )}
              <button
                onClick={() => setOpen(false)}
                className="rounded-md p-1.5 text-subtle hover:bg-surface-2 hover:text-default"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>
          <div className="max-h-80 overflow-y-auto">
            {items.length === 0 ? (
              <div className="px-4 py-8 text-center text-xs text-subtle">
                Nothing yet. Place / event / image actions will show up here.
              </div>
            ) : (
              <ul className="divide-y divide-token">
                {items.map((it) => (
                  <li key={it.id} className="px-4 py-3 text-sm text-default">
                    <div className="flex items-start gap-2">
                      <span
                        className="mt-1 inline-block h-1.5 w-1.5 shrink-0 rounded-full"
                        style={{
                          backgroundColor:
                            it.kind === 'success'
                              ? 'var(--color-kesk)'
                              : it.kind === 'warn'
                                ? 'var(--color-sor)'
                                : 'var(--color-zer)',
                        }}
                      />
                      <span className="flex-1">{it.message}</span>
                    </div>
                    <div className="mt-1 text-[10px] text-subtle pl-3.5">
                      {timeAgo(it.ts)}
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function timeAgo(ts: number): string {
  const diff = Date.now() - ts;
  if (diff < 60_000) return 'just now';
  if (diff < 3600_000) return `${Math.floor(diff / 60_000)}m ago`;
  if (diff < 86400_000) return `${Math.floor(diff / 3600_000)}h ago`;
  const d = new Date(ts);
  return d.toLocaleString();
}
