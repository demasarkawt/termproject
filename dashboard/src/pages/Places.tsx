import { useState } from 'react';
import {
  Search, Filter, Plus, Eye, Trash2, MapPin,
  ChevronLeft, ChevronRight, ArrowUpDown, Star, X, Download
} from 'lucide-react';
import { cn } from '@/src/lib/utils';
import { places as localPlaces, cities as localCities } from '../data/places';

const STATUS_COLORS: Record<string, string> = {
  Historical: 'bg-heritage-zer/20 text-heritage-zer border-heritage-zer/30',
  Nature: 'bg-heritage-kesk/20 text-heritage-kesk border-heritage-kesk/30',
  Food: 'bg-heritage-sor/20 text-heritage-sor border-heritage-sor/30',
  Waterfalls: 'bg-blue-900/20 text-blue-400 border-blue-400/30',
  Religious: 'bg-purple-900/20 text-purple-400 border-purple-400/30',
  Activities: 'bg-heritage-xweli/20 text-heritage-spi/70 border-heritage-xweli/30',
};

const PAGE_SIZE = 8;

export default function Places() {
  const [places] = useState(localPlaces);
  const [cities] = useState(localCities);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedCity, setSelectedCity] = useState('All');
  const [page, setPage] = useState(1);
  const [showModal, setShowModal] = useState(false);

  const categories = ['All', ...Array.from(new Set(places.map(p => p.category)))];

  const filtered = places.filter(p => {
    const matchSearch = p.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchCat = selectedCategory === 'All' || p.category === selectedCategory;
    const matchCity = selectedCity === 'All' || p.city === selectedCity;
    return matchSearch && matchCat && matchCity;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  return (
    <div className="p-10 max-w-[1600px] mx-auto space-y-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-bold text-heritage-spi font-display">Places Management</h1>
          <p className="text-sm text-heritage-spi/40 mt-1">
            Browse and manage {filtered.length} authentic locations from the Kurdistan Go database.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button className="bg-heritage-xweli/20 text-heritage-spi/70 border border-heritage-xweli/30 px-5 py-3 rounded-2xl text-sm font-bold flex items-center gap-2 hover:bg-heritage-xweli/40 transition-all">
            <Download className="w-4 h-4" /> Export
          </button>
          <button
            onClick={() => setShowModal(true)}
            className="bg-heritage-sor text-heritage-spi px-6 py-3 rounded-2xl text-sm font-bold flex items-center gap-2 hover:bg-heritage-sor/80 transition-all shadow-lg shadow-heritage-sor/20 border border-heritage-sor/30"
          >
            <Plus className="w-5 h-5" /> Add New Place
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-heritage-xweli/10 backdrop-blur-md p-6 rounded-3xl border border-heritage-xweli/20 flex flex-wrap items-center gap-6 shadow-xl">
        <div className="flex-1 min-w-[300px] relative">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-heritage-spi/30" />
          <input
            type="text"
            placeholder="Search places, categories, or cities..."
            className="w-full pl-12 pr-6 py-3 bg-heritage-res/50 border border-heritage-xweli/30 rounded-2xl text-sm text-heritage-spi placeholder:text-heritage-spi/20 focus:ring-2 focus:ring-heritage-zer/20 focus:border-heritage-zer/30 transition-all outline-none"
            value={searchQuery}
            onChange={(e) => { setSearchQuery(e.target.value); setPage(1); }}
          />
        </div>
        <div className="flex gap-4">
          <select
            className="bg-heritage-res/50 border border-heritage-xweli/30 rounded-2xl text-sm px-6 py-3 text-heritage-spi/70 focus:ring-2 focus:ring-heritage-zer/20 outline-none cursor-pointer appearance-none hover:bg-heritage-xweli/20 transition-all"
            value={selectedCategory}
            onChange={(e) => { setSelectedCategory(e.target.value); setPage(1); }}
          >
            {categories.map(c => <option key={c} value={c}>{c}</option>)}
          </select>
          <select
            className="bg-heritage-res/50 border border-heritage-xweli/30 rounded-2xl text-sm px-6 py-3 text-heritage-spi/70 focus:ring-2 focus:ring-heritage-zer/20 outline-none cursor-pointer appearance-none hover:bg-heritage-xweli/20 transition-all"
            value={selectedCity}
            onChange={(e) => { setSelectedCity(e.target.value); setPage(1); }}
          >
            <option value="All">All Cities</option>
            {cities.map(c => <option key={c.id} value={c.name}>{c.name}</option>)}
          </select>
        </div>
        <button className="p-3 bg-heritage-zer/10 border border-heritage-zer/20 rounded-2xl hover:bg-heritage-zer/20 transition-all text-heritage-zer">
          <Filter className="w-5 h-5" />
        </button>
      </div>

      {/* Table */}
      <div className="bg-heritage-xweli/5 rounded-3xl border border-heritage-xweli/20 shadow-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-heritage-xweli/10 border-b border-heritage-xweli/20">
                <th className="px-8 py-5 text-[10px] font-bold uppercase tracking-[0.2em] text-heritage-spi/30">Location Details</th>
                <th className="px-8 py-5 text-[10px] font-bold uppercase tracking-[0.2em] text-heritage-spi/30">Category</th>
                <th className="px-8 py-5 text-[10px] font-bold uppercase tracking-[0.2em] text-heritage-spi/30">City</th>
                <th className="px-8 py-5 text-[10px] font-bold uppercase tracking-[0.2em] text-heritage-spi/30">Rating</th>
                <th className="px-8 py-5 text-[10px] font-bold uppercase tracking-[0.2em] text-heritage-spi/30">Status</th>
                <th className="px-8 py-5 text-[10px] font-bold uppercase tracking-[0.2em] text-heritage-spi/30 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-heritage-xweli/10">
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-8 py-20 text-center text-heritage-spi/20 text-sm">
                    No places match your current filters.
                  </td>
                </tr>
              ) : (
                paginated.map((place) => (
                  <tr key={place.id} className="hover:bg-heritage-xweli/10 transition-all group">
                    <td className="px-8 py-6">
                      <div className="flex items-center gap-5">
                        <div className="w-14 h-14 rounded-2xl overflow-hidden border border-heritage-xweli/30 group-hover:border-heritage-zer/40 transition-colors shadow-lg shadow-black/20">
                          <img src={place.image} alt={place.name} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-heritage-spi group-hover:text-heritage-zer transition-colors">{place.name}</p>
                          <p className="text-[10px] text-heritage-spi/40 font-medium tracking-wide mt-0.5 uppercase">ID: {place.id}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <span className={cn(
                        "text-[10px] font-bold uppercase px-3 py-1.5 rounded-full border",
                        STATUS_COLORS[place.category] ?? 'bg-heritage-xweli/20 text-heritage-spi/40 border-heritage-xweli/30'
                      )}>
                        {place.category}
                      </span>
                    </td>
                    <td className="px-8 py-6">
                      <div className="flex items-center gap-2 text-xs text-heritage-spi/60 font-bold uppercase tracking-wider">
                        <MapPin className="w-3.5 h-3.5 text-heritage-zer" />{place.city}
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <div className="flex items-center gap-1.5 text-sm font-bold text-heritage-zer">
                        <Star className="w-4 h-4 fill-current" />
                        {place.rating.toFixed(1)}
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      {place.isPremium ? (
                        <span className="text-[10px] font-bold uppercase px-3 py-1.5 rounded-full bg-gradient-to-r from-heritage-zer/20 to-heritage-sor/20 text-heritage-zer border border-heritage-zer/30 shadow-inner">Premium</span>
                      ) : (
                        <span className="text-[10px] font-bold uppercase px-3 py-1.5 rounded-full bg-heritage-xweli/20 text-heritage-spi/20 border border-heritage-xweli/20">Standard</span>
                      )}
                    </td>
                    <td className="px-8 py-6 text-right">
                      <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-all duration-300 transform translate-x-2 group-hover:translate-x-0">
                        <button className="p-3 bg-heritage-res/50 hover:bg-heritage-zer/20 border border-heritage-xweli/30 hover:border-heritage-zer/30 rounded-xl transition-all text-heritage-spi/40 hover:text-heritage-zer" title="View Details">
                          <Eye className="w-4 h-4" />
                        </button>
                        <button className="p-3 bg-heritage-res/50 hover:bg-heritage-sor/20 border border-heritage-xweli/30 hover:border-heritage-sor/30 rounded-xl transition-all text-heritage-spi/40 hover:text-heritage-sor" title="Delete Location">
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
        <div className="px-8 py-6 bg-heritage-xweli/10 border-t border-heritage-xweli/20 flex items-center justify-between">
          <p className="text-xs text-heritage-spi/30 font-bold uppercase tracking-[0.1em]">
            Displaying <span className="text-heritage-zer">{Math.min((page - 1) * PAGE_SIZE + 1, filtered.length)}–{Math.min(page * PAGE_SIZE, filtered.length)}</span> of {filtered.length} locations
          </p>
          <div className="flex items-center gap-4">
            <button
              className="p-3 bg-heritage-res/50 border border-heritage-xweli/30 rounded-2xl text-heritage-spi/30 hover:text-heritage-zer hover:border-heritage-zer/30 disabled:opacity-10 transition-all"
              disabled={page === 1}
              onClick={() => setPage(p => p - 1)}
            >
              <ChevronLeft className="w-5 h-5" />
            </button>
            <div className="flex items-center gap-2">
               {[...Array(totalPages)].map((_, i) => (
                 <button 
                  key={i} 
                  onClick={() => setPage(i + 1)}
                  className={cn(
                    "w-10 h-10 rounded-xl text-xs font-bold transition-all",
                    page === i + 1 ? "bg-heritage-zer text-heritage-res shadow-lg shadow-heritage-zer/20" : "text-heritage-spi/20 hover:text-heritage-spi hover:bg-heritage-xweli/20"
                  )}
                 >
                   {i + 1}
                 </button>
               ))}
            </div>
            <button
              className="p-3 bg-heritage-res/50 border border-heritage-xweli/30 rounded-2xl text-heritage-spi/30 hover:text-heritage-zer hover:border-heritage-zer/30 disabled:opacity-10 transition-all"
              disabled={page >= totalPages}
              onClick={() => setPage(p => p + 1)}
            >
              <ChevronRight className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Add Place Modal Mockup */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-heritage-res/80 backdrop-blur-md">
          <div className="bg-heritage-res border border-heritage-xweli/30 rounded-[40px] shadow-2xl w-full max-w-xl p-10 relative overflow-hidden">
            <div className="absolute top-0 right-0 p-8">
              <button onClick={() => setShowModal(false)} className="p-3 bg-heritage-xweli/20 hover:bg-heritage-xweli/40 rounded-full transition-all text-heritage-spi/50">
                <X className="w-6 h-6" />
              </button>
            </div>
            <div className="mb-10">
              <h2 className="text-2xl font-bold text-heritage-spi font-display">New Location</h2>
              <p className="text-sm text-heritage-spi/40 mt-1">Register a new heritage site into the ecosystem.</p>
            </div>
            <div className="space-y-6">
              <div className="space-y-2">
                <label className="text-[10px] font-bold text-heritage-spi/30 uppercase tracking-widest">Location Name</label>
                <input type="text" placeholder="e.g. Citadel of Erbil" className="w-full bg-heritage-xweli/10 border border-heritage-xweli/20 rounded-2xl p-4 text-heritage-spi outline-none focus:border-heritage-zer/50 transition-all" />
              </div>
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-heritage-spi/30 uppercase tracking-widest">City</label>
                  <select className="w-full bg-heritage-xweli/10 border border-heritage-xweli/20 rounded-2xl p-4 text-heritage-spi outline-none appearance-none">
                    {localCities.map(c => <option key={c.id}>{c.name}</option>)}
                  </select>
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-heritage-spi/30 uppercase tracking-widest">Category</label>
                  <select className="w-full bg-heritage-xweli/10 border border-heritage-xweli/20 rounded-2xl p-4 text-heritage-spi outline-none appearance-none">
                    <option>Historical</option>
                    <option>Nature</option>
                    <option>Waterfalls</option>
                  </select>
                </div>
              </div>
              <div className="pt-6">
                <button className="w-full bg-heritage-zer text-heritage-res font-bold py-5 rounded-3xl shadow-xl shadow-heritage-zer/20 hover:scale-[1.02] active:scale-[0.98] transition-all">
                  Publish Location
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
