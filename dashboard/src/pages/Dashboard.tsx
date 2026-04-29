import { MapPin, Calendar, Plus, UploadCloud, MoreVertical, Star, TrendingUp } from 'lucide-react';
import { places, cities, events } from '../data/places';

export default function Dashboard() {
  const topPlaces = [...places]
    .sort((a, b) => b.rating - a.rating)
    .slice(0, 5);

  const maxRating = 5.0;

  const kpiData = [
    { label: 'Total Places', value: places.length.toString(), change: '+12%', icon: MapPin, color: 'text-heritage-zer', bgColor: 'bg-heritage-zer/10' },
    { label: 'Total Cities', value: cities.length.toString(), change: 'Live', icon: MapPin, color: 'text-heritage-kesk', bgColor: 'bg-heritage-kesk/10' },
    { label: 'Total Events', value: events.length.toString(), change: '+2', icon: Calendar, color: 'text-heritage-sor', bgColor: 'bg-heritage-sor/10' },
    { label: 'Premium Places', value: places.filter(p => p.isPremium).length.toString(), change: 'Featured', icon: Star, color: 'text-heritage-zer', bgColor: 'bg-heritage-zer/20' },
  ];

  const categoryCount = places.reduce<Record<string, number>>((acc, p) => {
    const cat = p.category;
    acc[cat] = (acc[cat] ?? 0) + 1;
    return acc;
  }, {});

  return (
    <div className="p-10 max-w-[1600px] mx-auto space-y-10">
      {/* Welcome Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-bold text-heritage-spi font-display">Sersal, Administrator</h1>
          <p className="text-heritage-spi/50 mt-1">Here is what is happening with Kurdistan Go today.</p>
        </div>
        <div className="flex gap-3">
          <button className="bg-heritage-sor text-heritage-spi px-6 py-3 rounded-2xl text-sm font-bold flex items-center gap-2 hover:bg-heritage-sor/80 transition-all shadow-lg shadow-heritage-sor/20 border border-heritage-sor/30">
            <Plus className="w-5 h-5" /> Add New Place
          </button>
          <button className="bg-heritage-xweli/30 text-heritage-spi border border-heritage-xweli/50 px-6 py-3 rounded-2xl text-sm font-bold flex items-center gap-2 hover:bg-heritage-xweli/50 transition-all">
            <TrendingUp className="w-5 h-5 text-heritage-zer" /> View Analytics
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {kpiData.map((kpi, i) => (
          <div key={i} className="bg-heritage-xweli/10 backdrop-blur-md p-8 rounded-3xl border border-heritage-xweli/20 hover:border-heritage-zer/30 transition-all group">
            <div className="flex justify-between items-start mb-6">
              <div className={`p-3 rounded-2xl ${kpi.bgColor} ${kpi.color}`}>
                <kpi.icon className="w-6 h-6" />
              </div>
              <span className="text-[10px] font-bold text-heritage-zer uppercase tracking-widest bg-heritage-zer/10 px-2 py-1 rounded-md">{kpi.change}</span>
            </div>
            <h3 className="text-heritage-spi/40 text-[10px] font-bold uppercase tracking-[0.2em] mb-2">{kpi.label}</h3>
            <p className="text-3xl font-bold text-heritage-spi group-hover:text-heritage-zer transition-colors">
              {kpi.value}
            </p>
          </div>
        ))}
      </div>

      {/* Main Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-10">
        {/* Left Column */}
        <div className="lg:col-span-8 space-y-10">

          {/* Top Rated Places */}
          <div className="bg-heritage-xweli/5 backdrop-blur-sm p-10 rounded-3xl border border-heritage-xweli/20">
            <div className="flex items-center justify-between mb-10">
              <div>
                <h2 className="text-xl font-bold text-heritage-spi font-display">Top Rated Destinations</h2>
                <p className="text-sm text-heritage-spi/40 mt-1">Based on real user reviews from the mobile app</p>
              </div>
              <button className="text-xs font-bold text-heritage-zer hover:underline">View All Places</button>
            </div>
            
            <div className="space-y-8">
              {topPlaces.map((place) => (
                <div key={place.id} className="group">
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-4">
                      <div className="w-12 h-12 rounded-xl overflow-hidden border border-heritage-xweli/30">
                        <img src={place.image} alt={place.name} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                      </div>
                      <div>
                        <h4 className="text-sm font-bold text-heritage-spi group-hover:text-heritage-zer transition-colors">{place.name}</h4>
                        <p className="text-[10px] text-heritage-spi/40 uppercase tracking-wider">{place.city} • {place.category}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-1 text-heritage-zer">
                      <Star className="w-3 h-3 fill-current" />
                      <span className="text-sm font-bold">{place.rating.toFixed(1)}</span>
                    </div>
                  </div>
                  <div className="w-full bg-heritage-xweli/20 h-1.5 rounded-full overflow-hidden">
                    <div
                      className="bg-gradient-to-r from-heritage-zer to-heritage-sor h-full rounded-full transition-all duration-1000 ease-out"
                      style={{ width: `${(place.rating / maxRating) * 100}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Upcoming Events */}
          <div className="bg-heritage-xweli/5 backdrop-blur-sm p-10 rounded-3xl border border-heritage-xweli/20">
            <div className="flex items-center justify-between mb-10">
              <h2 className="text-xl font-bold text-heritage-spi font-display">Upcoming Events</h2>
              <span className="text-[10px] font-bold bg-heritage-sor/20 text-heritage-sor border border-heritage-sor/30 px-3 py-1 rounded-full uppercase tracking-widest">
                {events.length} Scheduled
              </span>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {events.map((event) => (
                <div key={event.id} className="p-6 rounded-2xl bg-heritage-xweli/10 border border-heritage-xweli/20 hover:border-heritage-zer/30 transition-all group flex items-center gap-6">
                  <div className="w-16 h-16 rounded-2xl bg-heritage-res flex flex-col items-center justify-center border border-heritage-xweli/30 group-hover:border-heritage-zer/40 transition-colors">
                    <span className="text-[10px] font-bold text-heritage-zer uppercase tracking-tighter">{event.month}</span>
                    <span className="text-xl font-bold text-heritage-spi leading-none">{event.day}</span>
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-heritage-spi group-hover:text-heritage-zer transition-colors">{event.title}</h4>
                    <p className="text-xs text-heritage-spi/40 mt-1">{event.location} • {event.category}</p>
                  </div>
                  <button className="ml-auto p-2 text-heritage-spi/20 hover:text-heritage-spi transition-colors">
                    <MoreVertical className="w-5 h-5" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right Column */}
        <div className="lg:col-span-4 space-y-10">

          {/* Categories Breakdown */}
          <div className="bg-heritage-xweli/5 backdrop-blur-sm p-8 rounded-3xl border border-heritage-xweli/20">
            <h2 className="text-xl font-bold text-heritage-spi mb-8 font-display">Places by Category</h2>
            <div className="space-y-4">
              {Object.entries(categoryCount)
                .sort((a, b) => b[1] - a[1])
                .map(([cat, count]) => (
                  <div key={cat} className="flex items-center justify-between p-4 rounded-2xl bg-heritage-xweli/10 border border-transparent hover:border-heritage-xweli/30 transition-all">
                    <span className="text-sm font-medium text-heritage-spi/60">{cat}</span>
                    <span className="text-xs font-bold text-heritage-zer bg-heritage-zer/10 px-3 py-1 rounded-full border border-heritage-zer/20">
                      {count}
                    </span>
                  </div>
                ))}
            </div>
          </div>

          {/* Cities Overview */}
          <div className="bg-heritage-xweli/5 backdrop-blur-sm p-8 rounded-3xl border border-heritage-xweli/20">
            <h2 className="text-xl font-bold text-heritage-spi mb-8 font-display">City Overview</h2>
            <div className="space-y-4">
              {cities.map((city) => {
                const cityPlaces = places.filter(p => p.city.toLowerCase() === city.name.toLowerCase()).length;
                return (
                  <div key={city.id} className="flex items-center justify-between p-5 rounded-2xl bg-heritage-xweli/10 border border-heritage-xweli/10 hover:border-heritage-zer/20 transition-all group">
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-10 rounded-xl bg-heritage-res flex items-center justify-center text-heritage-zer group-hover:bg-heritage-zer group-hover:text-heritage-res transition-all shadow-inner">
                        <MapPin className="w-5 h-5" />
                      </div>
                      <div>
                        <p className="text-sm font-bold text-heritage-spi">{city.name}</p>
                        <p className="text-[10px] text-heritage-spi/30 uppercase tracking-wider">{city.description}</p>
                      </div>
                    </div>
                    <span className="text-xs font-bold text-heritage-spi/40">{cityPlaces} items</span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Quick Stats Banner */}
          <div className="bg-gradient-to-br from-heritage-sor to-heritage-xweli p-8 rounded-3xl border border-heritage-sor/30 shadow-xl shadow-heritage-sor/10">
            <h3 className="text-heritage-spi font-bold mb-2">Heritage Score</h3>
            <p className="text-heritage-spi/70 text-xs mb-6">Your app's cultural impact score is performing 15% better this month.</p>
            <div className="flex items-end gap-2">
              <span className="text-4xl font-bold text-heritage-spi">94</span>
              <span className="text-heritage-zer font-bold mb-1">/100</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
