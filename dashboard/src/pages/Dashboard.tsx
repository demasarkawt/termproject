import { useEffect, useState } from 'react';
import { MapPin, Calendar, Plus, UploadCloud, MoreVertical, Building2, Eye, Trash2 } from 'lucide-react';
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

  const kpiData = [
    {
      label: 'Total Places',
      value: loading ? '—' : places.length.toString(),
      change: 'Live',
      icon: MapPin,
      color: 'text-emerald-600',
      bgColor: 'bg-emerald-50',
    },
    {
      label: 'Total Cities',
      value: loading ? '—' : cities.length.toString(),
      change: 'Live',
      icon: Building2,
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
    },
    {
      label: 'Total Events',
      value: loading ? '—' : events.length.toString(),
      change: 'Live',
      icon: Calendar,
      color: 'text-amber-600',
      bgColor: 'bg-amber-50',
    },
    {
      label: 'Premium Places',
      value: loading ? '—' : places.filter((p) => p.is_premium).length.toString(),
      change: 'Live',
      icon: MapPin,
      color: 'text-purple-600',
      bgColor: 'bg-purple-50',
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
            className="bg-emerald-800 text-white px-5 py-2.5 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/10"
          >
            <Plus className="w-5 h-5" /> Add Place
          </button>
          <button
            onClick={() => onNavigate?.('events')}
            className="bg-white text-emerald-800 border border-emerald-800/10 px-5 py-2.5 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-50 transition-all"
          >
            <Plus className="w-5 h-5" /> Add Event
          </button>
          <button
            onClick={() => onNavigate?.('cities')}
            className="bg-white text-emerald-800 border border-emerald-800/10 px-5 py-2.5 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-50 transition-all"
          >
            <Plus className="w-5 h-5" /> Add City
          </button>
        </div>
        <button
          onClick={() => onNavigate?.('media')}
          className="bg-amber-100 text-amber-900 px-5 py-2.5 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-amber-200 transition-all"
        >
          <UploadCloud className="w-5 h-5" /> Upload Media
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {kpiData.map((kpi, i) => (
          <div key={i} className="bg-white p-6 rounded-xl border border-stone-200 shadow-sm">
            <div className="flex justify-between items-start mb-4">
              <div className={`p-2 rounded-lg ${kpi.bgColor} ${kpi.color}`}>
                <kpi.icon className="w-5 h-5" />
              </div>
              <span className="text-xs font-semibold text-emerald-600">{kpi.change}</span>
            </div>
            <h3 className="text-stone-500 text-xs font-medium uppercase tracking-wider mb-1">
              {kpi.label}
            </h3>
            <p className="text-2xl font-semibold text-stone-900">
              {loading ? (
                <span className="animate-pulse bg-stone-100 rounded w-12 h-7 inline-block" />
              ) : (
                kpi.value
              )}
            </p>
          </div>
        ))}
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
            <div className="flex items-center justify-between mb-8">
              <h2 className="text-lg font-semibold">Upcoming Events</h2>
              <span className="text-xs font-medium bg-emerald-100 text-emerald-900 px-2.5 py-1 rounded-full">
                {events.length} Total
              </span>
            </div>
            {loading ? (
              <div className="space-y-4">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="h-16 bg-stone-100 rounded-xl animate-pulse" />
                ))}
              </div>
            ) : events.length === 0 ? (
              <p className="text-stone-400 text-sm">No events in the database yet.</p>
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
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-lg bg-stone-50 flex flex-col items-center justify-center border border-stone-200">
                          <span className="text-[10px] font-bold text-stone-400 uppercase">
                            {month}
                          </span>
                          <span className="text-sm font-bold text-stone-900 leading-none">
                            {day}
                          </span>
                        </div>
                        <div>
                          <h4 className="text-sm font-semibold">{event.title}</h4>
                          <p className="text-xs text-stone-500">
                            {event.location ?? ''} • {event.event_type ?? ''}
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
