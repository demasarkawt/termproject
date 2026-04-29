import { useEffect, useState } from 'react';
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
} from 'recharts';
import {
  Users,
  Eye,
  Calendar,
  Download,
  Filter,
  ArrowUpRight,
  MapPin,
  Star,
} from 'lucide-react';
import { apiFetch, type Place, type Event, type City } from '@/src/lib/api';

const COLORS = ['#065f46', '#059669', '#34d399', '#a7f3d0', '#6ee7b7', '#d1fae5'];

// Illustrative weekly trend (no tracking backend)
const trendData = [
  { name: 'Mon', value: 4000 },
  { name: 'Tue', value: 3200 },
  { name: 'Wed', value: 2800 },
  { name: 'Thu', value: 3900 },
  { name: 'Fri', value: 2600 },
  { name: 'Sat', value: 4200 },
  { name: 'Sun', value: 5100 },
];

export default function Analytics() {
  const [places, setPlaces] = useState<Place[]>([]);
  const [events, setEvents] = useState<Event[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      apiFetch<Place[]>('/api/places/?limit=100'),
      apiFetch<Event[]>('/api/events/'),
      apiFetch<City[]>('/api/cities/'),
    ])
      .then(([p, e, c]) => { setPlaces(p); setEvents(e); setCities(c); })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const categoryMap = places.reduce<Record<string, number>>((acc, p) => {
    const cat = p.category ?? 'Other';
    acc[cat] = (acc[cat] ?? 0) + 1;
    return acc;
  }, {});
  const categoryData = Object.entries(categoryMap).map(([name, value]) => ({ name, value }));
  const totalPlaces = places.length;
  const premiumCount = places.filter(p => p.is_premium).length;
  const avgRating = places.length > 0
    ? (places.reduce((s, p) => s + (p.rating ?? 0), 0) / places.length).toFixed(2)
    : '—';

  // Places per city for bar chart
  const placesByCity = cities.map(c => ({
    name: c.name,
    places: places.filter(p => p.city_id === c.id).length,
    premium: places.filter(p => p.city_id === c.id && p.is_premium).length,
  })).sort((a, b) => b.places - a.places);

  // Top rated places
  const topRated = [...places]
    .filter(p => p.rating != null)
    .sort((a, b) => (b.rating ?? 0) - (a.rating ?? 0))
    .slice(0, 6);

  const stats = [
    { label: 'Total Places', value: loading ? '—' : totalPlaces.toString(), icon: MapPin },
    { label: 'Total Events', value: loading ? '—' : events.length.toString(), icon: Calendar },
    { label: 'Premium Places', value: loading ? '—' : premiumCount.toString(), icon: Eye },
    { label: 'Avg. Rating', value: loading ? '—' : avgRating, icon: Users },
  ];

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Analytics Overview</h1>
          <p className="text-sm text-stone-500">Live stats from your database</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="bg-white text-stone-700 border border-stone-200 px-4 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-stone-50 transition-all">
            <Filter className="w-4 h-4" />
            Filters
          </button>
          <button className="bg-emerald-800 text-white px-5 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/10">
            <Download className="w-4 h-4" />
            Export Report
          </button>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, i) => (
          <div key={i} className="bg-white p-6 rounded-2xl border border-stone-200 shadow-sm relative overflow-hidden group">
            <div className="flex justify-between items-start mb-4">
              <div className="p-2.5 bg-stone-50 rounded-xl text-stone-600 group-hover:bg-emerald-50 group-hover:text-emerald-700 transition-all">
                <stat.icon className="w-5 h-5" />
              </div>
              <div className="flex items-center gap-0.5 text-xs font-bold px-2 py-1 rounded-full bg-emerald-100 text-emerald-800">
                <ArrowUpRight className="w-3 h-3" />
                Live
              </div>
            </div>
            <h3 className="text-stone-500 text-xs font-bold uppercase tracking-wider mb-1">{stat.label}</h3>
            <p className="text-2xl font-bold text-stone-900">
              {loading
                ? <span className="animate-pulse bg-stone-100 rounded w-16 h-7 inline-block" />
                : stat.value}
            </p>
            <div className="absolute bottom-0 left-0 right-0 h-1 bg-stone-100">
              <div className="h-full bg-emerald-500 transition-all duration-1000" style={{ width: '65%' }}></div>
            </div>
          </div>
        ))}
      </div>

      {/* Main Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Places by City Bar Chart */}
        <div className="lg:col-span-8 bg-white p-8 rounded-2xl border border-stone-200 shadow-sm">
          <div className="mb-8">
            <h2 className="text-lg font-bold">Places by City</h2>
            <p className="text-sm text-stone-500">Total vs premium places per city</p>
          </div>
          <div className="h-[350px] w-full">
            {loading ? (
              <div className="h-full flex items-end gap-4 px-4 pb-4">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="flex-1 bg-stone-100 rounded-t-lg animate-pulse" style={{ height: `${40 + i * 20}%` }} />
                ))}
              </div>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={placesByCity} barCategoryGap="30%">
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} dy={10} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#fff', border: 'none', borderRadius: '12px', boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)' }}
                  />
                  <Bar dataKey="places" name="Total Places" fill="#059669" radius={[6, 6, 0, 0]} />
                  <Bar dataKey="premium" name="Premium" fill="#a7f3d0" radius={[6, 6, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </div>
          <div className="flex items-center gap-6 mt-4">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-emerald-600"></div>
              <span className="text-xs font-medium text-stone-600">Total Places</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-emerald-200"></div>
              <span className="text-xs font-medium text-stone-600">Premium</span>
            </div>
          </div>
        </div>

        {/* Category Pie Chart */}
        <div className="lg:col-span-4 bg-white p-8 rounded-2xl border border-stone-200 shadow-sm">
          <h2 className="text-lg font-bold mb-2">Category Distribution</h2>
          <p className="text-sm text-stone-500 mb-8">Popularity by place category</p>
          <div className="h-[250px] w-full relative">
            {loading ? (
              <div className="h-full flex items-center justify-center">
                <div className="w-40 h-40 rounded-full border-8 border-stone-100 animate-pulse" />
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
            <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
              <span className="text-2xl font-bold text-stone-900">{totalPlaces}</span>
              <span className="text-[10px] font-bold text-stone-400 uppercase tracking-widest">Places</span>
            </div>
          </div>
          <div className="mt-8 space-y-3">
            {categoryData.map((cat, i) => (
              <div key={i} className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-2 h-2 rounded-full" style={{ backgroundColor: COLORS[i % COLORS.length] }}></div>
                  <span className="text-xs font-medium text-stone-600">{cat.name}</span>
                </div>
                <span className="text-xs font-bold text-stone-900">
                  {totalPlaces > 0 ? Math.round((cat.value / totalPlaces) * 100) : 0}%
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Weekly Trend */}
        <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-lg font-bold">Weekly App Trend</h2>
              <p className="text-sm text-stone-500">Illustrative usage pattern</p>
            </div>
            <span className="text-[10px] font-bold text-stone-400 bg-stone-100 px-2 py-1 rounded-md uppercase tracking-wider">Sample</span>
          </div>
          <div className="h-[200px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={trendData}>
                <defs>
                  <linearGradient id="colorTrend" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#065f46" stopOpacity={0.1} />
                    <stop offset="95%" stopColor="#065f46" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} />
                <Tooltip contentStyle={{ backgroundColor: '#fff', border: 'none', borderRadius: '12px', boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)' }} />
                <Area type="monotone" dataKey="value" name="Sessions" stroke="#065f46" strokeWidth={3} fillOpacity={1} fill="url(#colorTrend)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Top Rated Places */}
        <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm">
          <h2 className="text-lg font-bold mb-6">Top Rated Places</h2>
          {loading ? (
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => <div key={i} className="h-8 bg-stone-100 rounded-full animate-pulse" />)}
            </div>
          ) : (
            <div className="space-y-4">
              {topRated.map((place, i) => (
                <div key={place.id} className="flex items-center gap-4">
                  <span className="text-xs font-bold text-stone-400 w-4">{i + 1}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between text-xs font-medium text-stone-600 mb-1">
                      <span className="truncate">{place.name}</span>
                      <div className="flex items-center gap-1 text-amber-600 font-bold shrink-0 ml-2">
                        <Star className="w-3 h-3 fill-amber-400 text-amber-400" />
                        {place.rating?.toFixed(1)}
                      </div>
                    </div>
                    <div className="w-full bg-stone-100 h-1.5 rounded-full overflow-hidden">
                      <div
                        className="bg-emerald-600 h-full rounded-full"
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
    </div>
  );
}
