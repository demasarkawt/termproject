import { useEffect, useState } from 'react';
import {
  Plus,
  UploadCloud,
  MoreVertical,
  Eye,
  Trash2,
  CreditCard,
  Truck,
  Wallet,
  Sparkles,
  Lock,
  Compass,
  Landmark,
  Ticket,
} from 'lucide-react';
import { motion } from 'motion/react';
import {
  apiFetch, apiDelete, ApiError, type Place, type Event, type City,
} from '@/src/lib/api';
import type { PageId } from '@/src/App';
import { useToast } from '@/src/components/Toast';

export default function Dashboard({
  onNavigate,
}: {
  onNavigate?: (id: PageId) => void;
}) {
  const toast = useToast();
  const [places, setPlaces] = useState<Place[]>([]);
  const [events, setEvents] = useState<Event[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [loading, setLoading] = useState(true);
  const [openMenu, setOpenMenu] = useState<number | null>(null);

  useEffect(() => {
    Promise.all([
      apiFetch<Place[]>('/api/places/?limit=500'),
      apiFetch<Event[]>('/api/events/'),
      apiFetch<City[]>('/api/cities/'),
    ])
      .then(([p, e, c]) => {
        setPlaces(p);
        setEvents(e);
        setCities(c);
      })
      .catch((err) =>
        toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err)),
      )
      .finally(() => setLoading(false));
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const topPlaces = [...places]
    .sort((a, b) => (b.rating ?? 0) - (a.rating ?? 0))
    .slice(0, 5);

  const maxRating = topPlaces[0]?.rating ?? 5;

  const COLORS = ['#3F4A2A', '#B8862F', '#7A1F1F', '#5A3A22', '#1A1410', '#F5EFE2'];

  const kpiData = [
    {
      label: 'Total Places',
      value: loading ? '—' : places.length.toString(),
      change: 'Live',
      icon: Compass,
      color: 'text-kesk',
      bgColor: 'bg-kesk-soft',
    },
    {
      label: 'Total Cities',
      value: loading ? '—' : cities.length.toString(),
      change: 'Live',
      icon: Landmark,
      color: 'text-xweli',
      bgColor: 'bg-surface-3',
    },
    {
      label: 'Total Events',
      value: loading ? '—' : events.length.toString(),
      change: 'Live',
      icon: Ticket,
      color: 'text-zer',
      bgColor: 'bg-zer-soft',
    },
    {
      label: 'Premium Places',
      value: loading ? '—' : places.filter((p) => p.is_premium).length.toString(),
      change: 'Live',
      icon: Sparkles,
      color: 'text-sor',
      bgColor: 'bg-sor-soft',
    },
  ];

  const categoryCount = places.reduce<Record<string, number>>((acc, p) => {
    const cat = p.category ?? 'Other';
    acc[cat] = (acc[cat] ?? 0) + 1;
    return acc;
  }, {});

  const deleteEvent = async (id: number, title: string) => {
    setOpenMenu(null);
    if (!confirm(`Delete "${title}"?`)) return;
    try {
      await apiDelete(`/api/events/${id}`);
      setEvents((prev) => prev.filter((e) => e.id !== id));
      toast.success('Event deleted.');
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    }
  };

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-8">
      <div className="flex flex-wrap gap-4 items-center justify-between">
        <div className="flex gap-3">
          <button
            onClick={() => onNavigate?.('places')}
            className="bg-kesk text-white px-6 py-3 rounded-2xl text-sm font-black flex items-center gap-2 hover:bg-kesk/90 transition-all shadow-xl shadow-kesk/20"
          >
            <Plus className="w-5 h-5" /> ADD PLACE
          </button>
          <button
            onClick={() => {
              sessionStorage.setItem('kg_events_open', 'create');
              onNavigate?.('events');
            }}
            className="bg-white text-kesk border-2 border-kesk/20 px-6 py-3 rounded-2xl text-sm font-black flex items-center gap-2 hover:bg-kesk-soft transition-all"
          >
            <Plus className="w-5 h-5" /> ADD EVENT
          </button>
          <button
            onClick={() => onNavigate?.('cities')}
            className="bg-white text-kesk border-2 border-kesk/20 px-6 py-3 rounded-2xl text-sm font-black flex items-center gap-2 hover:bg-kesk-soft transition-all"
          >
            <Plus className="w-5 h-5" /> ADD CITY
          </button>
        </div>
        <button
          onClick={() => onNavigate?.('media')}
          className="bg-zer-soft text-zer px-6 py-3 rounded-2xl text-sm font-black flex items-center gap-2 hover:bg-zer-soft/80 transition-all border-2 border-zer/10"
        >
          <UploadCloud className="w-5 h-5" /> UPLOAD MEDIA
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {kpiData.map((kpi, i) => (
          <motion.div 
            key={i} 
            initial={{ opacity: 0, scale: 0.95, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            whileHover={{ scale: 1.02, y: -4 }}
            transition={{ delay: i * 0.05, type: 'spring', stiffness: 300 }}
            className="bg-card p-6 rounded-2xl border-2 border-token shadow-sm group hover:border-zer/30 transition-all cursor-pointer"
          >
            <div className="flex justify-between items-start mb-4">
              <div className={`p-3 rounded-xl transition-transform duration-500 group-hover:rotate-[360deg] ${kpi.bgColor} ${kpi.color}`}>
                <kpi.icon className="w-6 h-6" />
              </div>
              <div className="flex flex-col items-end">
                <span className="text-[10px] font-black text-kesk tracking-widest uppercase">{kpi.change}</span>
                <div className="w-8 h-1 bg-kesk/10 rounded-full mt-1 overflow-hidden">
                   <div className="w-1/2 h-full bg-kesk" />
                </div>
              </div>
            </div>
            <h3 className="text-subtle text-[10px] font-black uppercase tracking-[0.2em] mb-1">
              {kpi.label}
            </h3>
            <p className="text-3xl font-black text-default tracking-tight">
              {loading ? (
                <span className="animate-pulse bg-surface-3 rounded w-16 h-8 inline-block" />
              ) : (
                kpi.value
              )}
            </p>
          </motion.div>
        ))}
      </div>

      <div className="bg-white p-8 rounded-xl border border-stone-200 shadow-sm space-y-8">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <h2 className="text-lg font-semibold text-stone-900">Checkout preview</h2>
            <p className="text-sm text-stone-500 mt-1">
              Payment is collected before shipping details — same order as your live checkout.
            </p>
          </div>
          <div className="flex items-center gap-2 text-xs font-semibold text-stone-500">
            <span className="flex items-center gap-1.5 rounded-full bg-emerald-100 text-emerald-800 px-3 py-1">
              <Lock className="w-3.5 h-3.5" /> PCI placeholder
            </span>
          </div>
        </div>

        {/* Payment comes first */}
        <section className="rounded-2xl border border-stone-200 bg-stone-50/80 p-6 space-y-4">
          <div className="flex items-center gap-2">
            <span className="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-800 text-white text-xs font-bold">
              1
            </span>
            <div className="flex items-center gap-2">
              <CreditCard className="w-5 h-5 text-emerald-700" />
              <h3 className="text-base font-semibold text-stone-900">Payment</h3>
            </div>
          </div>
          <p className="text-sm text-stone-600 pl-10">
            Choose how guests pay before you collect a delivery or pickup address.
          </p>
          <div className="pl-10 grid grid-cols-1 sm:grid-cols-2 gap-3">
            <button
              type="button"
              className="flex items-center gap-3 rounded-xl border-2 border-emerald-600 bg-white p-4 text-left shadow-sm transition hover:bg-emerald-50/50"
            >
              <Wallet className="w-6 h-6 text-emerald-700 shrink-0" />
              <div>
                <p className="text-sm font-semibold text-stone-900">Card</p>
                <p className="text-xs text-stone-500">Visa ·••• 4242</p>
              </div>
            </button>
            <button
              type="button"
              className="flex items-center gap-3 rounded-xl border border-stone-200 bg-white p-4 text-left hover:border-stone-300 transition"
            >
              <CreditCard className="w-6 h-6 text-stone-500 shrink-0" />
              <div>
                <p className="text-sm font-semibold text-stone-900">Business invoice</p>
                <p className="text-xs text-stone-500">Net 30 · admin only</p>
              </div>
            </button>
          </div>
        </section>

        {/* Shipping stage follows payment */}
        <section className="rounded-2xl border border-dashed border-stone-300 bg-white p-6 space-y-4">
          <div className="flex items-center gap-2">
            <span className="flex h-8 w-8 items-center justify-center rounded-full bg-stone-200 text-stone-700 text-xs font-bold">
              2
            </span>
            <div className="flex items-center gap-2">
              <Truck className="w-5 h-5 text-stone-600" />
              <h3 className="text-base font-semibold text-stone-900">Shipping</h3>
            </div>
          </div>
          <p className="text-sm text-stone-600 pl-10">
            Shown after payment succeeds — address, courier, and delivery window.
          </p>
          <div className="pl-10 grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                Recipient
              </label>
              <div className="h-10 rounded-lg border border-stone-200 bg-stone-50 px-3 text-sm text-stone-400 flex items-center">
                Ava Yılmaz · Erbil
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                Courier
              </label>
              <div className="h-10 rounded-lg border border-stone-200 bg-stone-50 px-3 text-sm text-stone-400 flex items-center gap-2">
                <Truck className="w-4 h-4" /> Express · 2–4 days
              </div>
            </div>
            <div className="md:col-span-2 space-y-2">
              <label className="text-xs font-bold uppercase tracking-wider text-stone-500">
                Street address
              </label>
              <div className="min-h-[2.5rem] rounded-lg border border-stone-200 bg-stone-50 px-3 py-2 text-sm text-stone-400">
                120 m, Gulan St — Ankawa
              </div>
            </div>
          </div>
        </section>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        <div className="lg:col-span-8 space-y-8">
          <div className="bg-white p-8 rounded-xl border border-stone-200 shadow-sm">
            <div className="flex items-center justify-between mb-8">
              <div>
                <h2 className="text-lg font-semibold">Top Rated Places</h2>
                <p className="text-sm text-stone-500">Sorted by rating from your database</p>
              </div>
              <button
                onClick={() => onNavigate?.('places')}
                className="text-xs font-bold text-emerald-700 hover:underline"
              >
                Manage all
              </button>
            </div>
            {loading ? (
              <div className="space-y-4">
                {[...Array(5)].map((_, i) => (
                  <div key={i} className="h-8 bg-stone-100 rounded-full animate-pulse" />
                ))}
              </div>
            ) : (
              <div className="space-y-6">
                {topPlaces.map((place) => (
                  <div key={place.id} className="space-y-2">
                    <div className="flex justify-between text-xs font-medium text-stone-600">
                      <span>{place.name}</span>
                      <span>⭐ {place.rating?.toFixed(1)}</span>
                    </div>
                    <div className="w-full bg-stone-100 h-2 rounded-full overflow-hidden">
                      <div
                        className="bg-emerald-700 h-full rounded-full transition-all duration-1000"
                        style={{ width: `${((place.rating ?? 0) / maxRating) * 100}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="bg-white p-8 rounded-xl border border-stone-200 shadow-sm">
            <div className="flex flex-wrap items-center justify-between gap-4 mb-8">
              <div className="flex items-center gap-3">
                <h2 className="text-lg font-semibold">Upcoming Events</h2>
                <span className="text-xs font-medium bg-emerald-100 text-emerald-900 px-2.5 py-1 rounded-full">
                  {events.length} Total
                </span>
              </div>
              <div className="flex flex-wrap items-center gap-2">
                <button
                  type="button"
                  onClick={() => {
                    sessionStorage.setItem('kg_events_open', 'create');
                    onNavigate?.('events');
                  }}
                  className="text-xs font-bold text-emerald-800 bg-emerald-50 px-3 py-1.5 rounded-lg hover:bg-emerald-100 transition-colors"
                >
                  + Add event
                </button>
                <button
                  type="button"
                  onClick={() => onNavigate?.('events')}
                  className="text-xs font-bold text-emerald-700 hover:underline"
                >
                  Manage all
                </button>
              </div>
            </div>
            {loading ? (
              <div className="space-y-4">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="h-16 bg-stone-100 rounded-xl animate-pulse" />
                ))}
              </div>
            ) : events.length === 0 ? (
              <>
                <p className="text-stone-400 text-sm">No events in the database yet.</p>
                <button
                  type="button"
                  onClick={() => {
                    sessionStorage.setItem('kg_events_open', 'create');
                    onNavigate?.('events');
                  }}
                  className="mt-3 text-sm font-bold text-emerald-700 hover:underline"
                >
                  + Add your first event
                </button>
              </>
            ) : (
              <div className="divide-y divide-stone-100">
                {events.map((event) => {
                  const dateStr = event.start_date ?? '';
                  const parts = dateStr.split('-');
                  const day = parts[2] ?? '—';
                  const monthNames = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ];
                  const month = parts[1] ? monthNames[parseInt(parts[1]) - 1] : '—';
                  return (
                    <div
                      key={event.id}
                      className="py-4 flex items-center justify-between first:pt-0 last:pb-0 relative"
                    >
                      <div className="flex items-center gap-4 min-w-0">
                        {event.image_url ? (
                          <img
                            src={event.image_url}
                            alt=""
                            className="h-12 w-12 shrink-0 rounded-lg object-cover border border-stone-200"
                          />
                        ) : (
                          <div className="w-12 h-12 shrink-0 rounded-lg bg-stone-50 flex flex-col items-center justify-center border border-stone-200">
                            <span className="text-[10px] font-bold text-stone-400 uppercase">
                              {month}
                            </span>
                            <span className="text-sm font-bold text-stone-900 leading-none">
                              {day}
                            </span>
                          </div>
                        )}
                        <div className="min-w-0">
                          <h4 className="text-sm font-semibold truncate">{event.title}</h4>
                          <p className="text-xs text-stone-500 truncate">
                            {[
                              parts[1] ? `${month} ${day}` : null,
                              event.location,
                              event.event_type,
                            ]
                              .filter(Boolean)
                              .join(' · ') || '—'}
                          </p>
                        </div>
                      </div>
                      <div className="relative">
                        <button
                          onClick={() =>
                            setOpenMenu((cur) => (cur === event.id ? null : event.id))
                          }
                          className="p-2 hover:bg-stone-100 rounded-lg transition-colors"
                        >
                          <MoreVertical className="w-5 h-5 text-stone-400" />
                        </button>
                        {openMenu === event.id && (
                          <div className="absolute right-0 z-10 mt-1 w-40 rounded-xl border border-stone-200 bg-white shadow-lg">
                            <button
                              onClick={() => {
                                setOpenMenu(null);
                                sessionStorage.setItem('kg_events_open', String(event.id));
                                onNavigate?.('events');
                              }}
                              className="flex w-full items-center gap-2 rounded-t-xl px-3 py-2 text-left text-xs hover:bg-stone-50"
                            >
                              <Eye className="h-3.5 w-3.5" /> View / edit
                            </button>
                            <button
                              onClick={() => deleteEvent(event.id, event.title)}
                              className="flex w-full items-center gap-2 rounded-b-xl px-3 py-2 text-left text-xs text-red-600 hover:bg-red-50"
                            >
                              <Trash2 className="h-3.5 w-3.5" /> Delete
                            </button>
                          </div>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>

        <div className="lg:col-span-4 space-y-8">
          <div className="bg-white p-6 rounded-xl border border-stone-200 shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Places by Category</h2>
            {loading ? (
              <div className="space-y-3">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="h-6 bg-stone-100 rounded animate-pulse" />
                ))}
              </div>
            ) : (
              <div className="space-y-3">
                {Object.entries(categoryCount)
                  .sort((a, b) => b[1] - a[1])
                  .map(([cat, count]) => (
                    <div key={cat} className="flex items-center justify-between">
                      <span className="text-sm text-stone-600">{cat}</span>
                      <span className="text-sm font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full">
                        {count}
                      </span>
                    </div>
                  ))}
              </div>
            )}
          </div>

          <div className="bg-white p-6 rounded-xl border border-stone-200 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold">Cities</h2>
              <button
                onClick={() => onNavigate?.('cities')}
                className="text-xs font-bold text-emerald-700 hover:underline"
              >
                Manage
              </button>
            </div>
            {loading ? (
              <div className="space-y-3">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="h-10 bg-stone-100 rounded-xl animate-pulse" />
                ))}
              </div>
            ) : (
              <div className="space-y-3">
                {cities.map((city) => {
                  const cityPlaces = places.filter((p) => p.city_id === city.id).length;
                  return (
                    <div
                      key={city.id}
                      className="flex items-center justify-between p-3 rounded-xl bg-stone-50 border border-stone-100"
                    >
                      <div>
                        <p className="text-sm font-semibold text-stone-800">{city.name}</p>
                        <p className="text-xs text-stone-400">{city.description}</p>
                      </div>
                      <span className="text-xs font-bold text-stone-600">
                        {cityPlaces} places
                      </span>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
