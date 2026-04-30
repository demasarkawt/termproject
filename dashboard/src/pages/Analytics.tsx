import { useMemo, useEffect, useState } from 'react';
import {
  AreaChart,
  Area,
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';
import {
  Users,
  Calendar,
  MapPin,
  Star,
  ImageIcon,
  Building2,
} from 'lucide-react';
import {
  apiFetch,
  ApiError,
  type Place,
  type Event,
  type City,
  type User,
  type MediaItem,
} from '@/src/lib/api';
import { useToast } from '@/src/components/Toast';

const COLORS = ['#3F4A2A', '#B8862F', '#7A1F1F', '#5A3A22', '#1A1410', '#C8BFAF'];

/** Last `days` calendar days ending today; count items whose `created_at` falls on that day (UTC date). */
function seriesByCalendarDay<T extends { created_at: string | null }>(
  days: number,
  items: T[],
): { name: string; value: number }[] {
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);
  const rows: { name: string; value: number }[] = [];
  const keys: string[] = [];
  for (let back = days - 1; back >= 0; back--) {
    const d = new Date(today);
    d.setUTCDate(d.getUTCDate() - back);
    keys.push(d.toISOString().slice(0, 10));
    rows.push({
      name: d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' }),
      value: 0,
    });
  }
  const idx = new Map(keys.map((k, i) => [k, i]));
  for (const it of items) {
    if (!it.created_at) continue;
    const k = new Date(it.created_at).toISOString().slice(0, 10);
    const i = idx.get(k);
    if (i !== undefined) rows[i].value += 1;
  }
  return rows;
}

/** Align two daily series onto the same axis labels (`name` from signup series). */
function mergeActivity(signups: { name: string; value: number }[], uploads: { name: string; value: number }[]) {
  return signups.map((s, i) => ({
    name: s.name,
    signups: s.value,
    uploads: uploads[i]?.value ?? 0,
  }));
}

export default function Analytics() {
  const toast = useToast();
  const [places, setPlaces] = useState<Place[]>([]);
  const [events, setEvents] = useState<Event[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [mediaItems, setMediaItems] = useState<MediaItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    Promise.all([
      apiFetch<Place[]>('/api/places/?limit=500'),
      apiFetch<Event[]>('/api/events/'),
      apiFetch<City[]>('/api/cities/'),
      apiFetch<User[]>('/api/users/'),
      apiFetch<MediaItem[]>('/api/media/'),
    ])
      .then(([p, e, c, u, m]) => {
        if (!cancelled) {
          setPlaces(p);
          setEvents(e);
          setCities(c);
          setUsers(u);
          setMediaItems(m);
        }
      })
      .catch((err) => {
        if (!cancelled) {
          const msg =
            err instanceof ApiError ? err.detail ?? err.message : String(err);
          toast.error(msg);
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const categoryMap = places.reduce<Record<string, number>>((acc, p) => {
    const cat = p.category ?? 'Other';
    acc[cat] = (acc[cat] ?? 0) + 1;
    return acc;
  }, {});
  const categoryData = Object.entries(categoryMap).map(([name, value]) => ({ name, value }));
  const totalPlaces = places.length;
  const premiumCount = places.filter((p) => p.is_premium).length;
  const premiumPct =
    totalPlaces > 0 ? Math.round((premiumCount / totalPlaces) * 100) : 0;
  const avgRating =
    places.length > 0
      ? (places.reduce((s, p) => s + (p.rating ?? 0), 0) / places.length).toFixed(2)
      : '—';

  const eventTypeMap = events.reduce<Record<string, number>>((acc, e) => {
    const t = e.event_type ?? 'Other';
    acc[t] = (acc[t] ?? 0) + 1;
    return acc;
  }, {});
  const eventTypeData = Object.entries(eventTypeMap)
    .map(([name, value]) => ({ name, value }))
    .sort((a, b) => b.value - a.value);

  const placesByCity = cities
    .map((city) => ({
      name: city.name,
      places: places.filter((p) => p.city_id === city.id).length,
      premium: places.filter((p) => p.city_id === city.id && p.is_premium).length,
    }))
    .sort((a, b) => b.places - a.places);

  const topRated = [...places]
    .filter((p) => p.rating != null)
    .sort((a, b) => (b.rating ?? 0) - (a.rating ?? 0))
    .slice(0, 8);

  const DAY_RANGE = 14;
  const activityData = useMemo(() => {
    const signups = seriesByCalendarDay(DAY_RANGE, users);
    const uploads = seriesByCalendarDay(DAY_RANGE, mediaItems);
    return mergeActivity(signups, uploads);
  }, [users, mediaItems]);

  const stats = [
    { label: 'Places', value: loading ? '—' : totalPlaces.toString(), icon: MapPin },
    { label: 'Events', value: loading ? '—' : events.length.toString(), icon: Calendar },
    { label: 'Cities', value: loading ? '—' : cities.length.toString(), icon: Building2 },
    { label: 'Users', value: loading ? '—' : users.length.toString(), icon: Users },
  ];

  const mediaCount = mediaItems.length;

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-8">
      <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Analytics</h1>
          <p className="text-sm text-stone-500">
            Aggregated from your API: places ({totalPlaces}), events ({events.length}), media library ({mediaCount}).
          </p>
          <div className="mt-3 flex flex-wrap gap-3 text-xs text-stone-600">
            <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 px-3 py-1 font-semibold text-emerald-900">
              <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-500" /> Avg. rating{' '}
              {loading ? '—' : avgRating}
            </span>
            <span className="inline-flex items-center gap-1 rounded-full bg-stone-100 px-3 py-1 font-medium">
              Premium places: {loading ? '—' : `${premiumCount} (${premiumPct}% of listings)`}
            </span>
            <span className="inline-flex items-center gap-1 rounded-full bg-stone-100 px-3 py-1 font-medium">
              <ImageIcon className="h-3.5 w-3.5 text-stone-500" /> Media assets:{' '}
              {loading ? '—' : mediaCount}
            </span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, i) => (
          <div
            key={i}
            className="bg-white p-6 rounded-2xl border border-stone-200 shadow-sm relative overflow-hidden group"
          >
            <div className="flex justify-between items-start mb-4">
              <div className="p-2.5 bg-stone-50 rounded-xl text-stone-600 group-hover:bg-emerald-50 group-hover:text-emerald-700 transition-all">
                <stat.icon className="w-5 h-5" />
              </div>
            </div>
            <h3 className="text-stone-500 text-xs font-bold uppercase tracking-wider mb-1">
              {stat.label}
            </h3>
            <p className="text-2xl font-bold text-stone-900">
              {loading ? (
                <span className="animate-pulse bg-stone-100 rounded w-16 h-7 inline-block" />
              ) : (
                stat.value
              )}
            </p>
            {!loading && stat.label === 'Places' && (
              <div className="absolute bottom-0 left-0 right-0 h-1 bg-stone-100">
                <div
                  className="h-full bg-emerald-500 transition-all duration-1000"
                  style={{ width: `${premiumPct}%` }}
                />
              </div>
            )}
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        <div className="lg:col-span-8 bg-white p-8 rounded-2xl border border-stone-200 shadow-sm">
          <div className="mb-8">
            <h2 className="text-lg font-bold">Places by city</h2>
            <p className="text-sm text-stone-500">Total vs. premium listings per city</p>
          </div>
          <div className="h-[350px] w-full">
            {loading ? (
              <div className="h-full flex items-end gap-4 px-4 pb-4">
                {[...Array(4)].map((_, i) => (
                  <div
                    key={i}
                    className="flex-1 bg-stone-100 rounded-t-lg animate-pulse"
                    style={{ height: `${40 + i * 20}%` }}
                  />
                ))}
              </div>
            ) : placesByCity.every((row) => row.places === 0) ? (
              <div className="flex h-full items-center justify-center text-sm text-stone-500">
                No places assigned to cities yet.
              </div>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={placesByCity} barCategoryGap="22%">
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis
                    dataKey="name"
                    axisLine={false}
                    tickLine={false}
                    tick={{ fontSize: 12, fill: '#94a3b8' }}
                    dy={10}
                  />
                  <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#fff',
                      border: 'none',
                      borderRadius: '12px',
                      boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)',
                    }}
                  />
                  <Bar dataKey="places" name="Total places" fill="#059669" radius={[6, 6, 0, 0]} />
                  <Bar dataKey="premium" name="Premium" fill="#a7f3d0" radius={[6, 6, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </div>
          <div className="flex flex-wrap items-center gap-6 mt-4">
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-emerald-600" />
              <span className="text-xs font-medium text-stone-600">Total places</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-emerald-200" />
              <span className="text-xs font-medium text-stone-600">Premium</span>
            </div>
          </div>
        </div>

        <div className="lg:col-span-4 bg-white p-8 rounded-2xl border border-stone-200 shadow-sm">
          <h2 className="text-lg font-bold mb-2">Category mix</h2>
          <p className="text-sm text-stone-500 mb-8">Places by category</p>
          <div className="h-[250px] w-full relative">
            {loading ? (
              <div className="h-full flex items-center justify-center">
                <div className="h-40 w-40 animate-pulse rounded-full border-8 border-stone-100" />
              </div>
            ) : categoryData.length === 0 ? (
              <div className="flex h-full items-center justify-center text-center text-sm text-stone-500">
                No places yet.
              </div>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={categoryData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {categoryData.map((_, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            )}
            {!loading && categoryData.length > 0 && (
              <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center">
                <span className="text-2xl font-bold text-stone-900">{totalPlaces}</span>
                <span className="text-[10px] font-bold uppercase tracking-widest text-stone-400">
                  Places
                </span>
              </div>
            )}
          </div>
          {!loading && categoryData.length > 0 && (
            <div className="mt-8 space-y-3">
              {categoryData.map((cat, i) => (
                <div key={cat.name} className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div
                      className="h-2 w-2 rounded-full"
                      style={{ backgroundColor: COLORS[i % COLORS.length] }}
                    />
                    <span className="text-xs font-medium text-stone-600">{cat.name}</span>
                  </div>
                  <span className="text-xs font-bold text-stone-900">
                    {totalPlaces > 0 ? Math.round((cat.value / totalPlaces) * 100) : 0}%
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm">
          <div className="mb-6">
            <h2 className="text-lg font-bold">Activity ({DAY_RANGE} days)</h2>
            <p className="text-sm text-stone-500">
              Daily counts from <code className="text-xs">created_at</code>: new registered users vs. new rows in{' '}
              <code className="text-xs">media_items</code>.
            </p>
          </div>
          <div className="h-[260px] w-full">
            {loading ? (
              <div className="flex h-full items-center justify-center text-sm text-stone-400">
                Loading charts…
              </div>
            ) : activityData.every((r) => r.signups === 0 && r.uploads === 0) ? (
              <div className="flex h-full flex-col items-center justify-center gap-2 text-center text-sm text-stone-500">
                <p>No user or media activity in this window.</p>
              </div>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={activityData}>
                  <defs>
                    <linearGradient id="signupGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#047857" stopOpacity={0.12} />
                      <stop offset="95%" stopColor="#047857" stopOpacity={0} />
                    </linearGradient>
                    <linearGradient id="uploadGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#0891b2" stopOpacity={0.12} />
                      <stop offset="95%" stopColor="#0891b2" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis
                    dataKey="name"
                    axisLine={false}
                    tickLine={false}
                    tick={{ fontSize: 11, fill: '#94a3b8' }}
                  />
                  <YAxis
                    axisLine={false}
                    tickLine={false}
                    tick={{ fontSize: 12, fill: '#94a3b8' }}
                    allowDecimals={false}
                  />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#fff',
                      border: 'none',
                      borderRadius: '12px',
                      boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)',
                    }}
                  />
                  <Legend wrapperStyle={{ fontSize: '12px' }} />
                  <Area
                    type="monotone"
                    dataKey="signups"
                    name="New users"
                    stroke="#047857"
                    strokeWidth={2}
                    fillOpacity={1}
                    fill="url(#signupGrad)"
                  />
                  <Area
                    type="monotone"
                    dataKey="uploads"
                    name="Media uploads"
                    stroke="#0891b2"
                    strokeWidth={2}
                    fillOpacity={1}
                    fill="url(#uploadGrad)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            )}
          </div>
        </div>

        <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm">
          <div className="mb-6">
            <h2 className="text-lg font-bold">Events by type</h2>
            <p className="text-sm text-stone-500">Count per <code className="text-xs">event_type</code></p>
          </div>
          <div className="min-h-[200px]">
            {loading ? (
              <div className="space-y-4">
                {[...Array(5)].map((_, i) => (
                  <div key={i} className="h-8 animate-pulse rounded-full bg-stone-100" />
                ))}
              </div>
            ) : eventTypeData.length === 0 ? (
              <p className="text-sm text-stone-500">No events yet.</p>
            ) : (
              <ResponsiveContainer width="100%" height={Math.min(380, 56 + eventTypeData.length * 36)}>
                <BarChart
                  data={eventTypeData}
                  layout="vertical"
                  margin={{ left: 8, right: 24 }}
                  barCategoryGap="18%"
                >
                  <CartesianGrid strokeDasharray="3 3" horizontal stroke="#f1f5f9" />
                  <XAxis type="number" allowDecimals={false} axisLine={false} tickLine={false} />
                  <YAxis
                    type="category"
                    dataKey="name"
                    width={88}
                    tick={{ fontSize: 11 }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <Tooltip />
                  <Bar dataKey="value" fill="#059669" name="Events" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </div>
        </div>
      </div>

      <div className="border border-stone-200 bg-white p-8 shadow-sm rounded-2xl">
        <h2 className="mb-6 text-lg font-bold">Highest rated places</h2>
        {loading ? (
          <div className="space-y-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-8 animate-pulse rounded-full bg-stone-100" />
            ))}
          </div>
        ) : topRated.length === 0 ? (
          <p className="text-sm text-stone-500">No rated places yet.</p>
        ) : (
          <div className="space-y-4">
            {topRated.map((place, i) => (
              <div key={place.id} className="flex items-center gap-4">
                <span className="w-4 text-xs font-bold text-stone-400">{i + 1}</span>
                <div className="min-w-0 flex-1">
                  <div className="mb-1 flex justify-between gap-2 text-xs font-medium text-stone-600">
                    <span className="truncate">{place.name}</span>
                    <div className="ml-2 shrink-0 flex items-center gap-1 font-bold text-amber-600">
                      <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                      {place.rating?.toFixed(1)}
                    </div>
                  </div>
                  <div className="h-1.5 w-full overflow-hidden rounded-full bg-stone-100">
                    <div
                      className="h-full rounded-full bg-emerald-600"
                      style={{ width: `${((place.rating ?? 0) / 5) * 100}%` }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
