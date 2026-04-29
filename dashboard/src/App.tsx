import { useState } from 'react';
import {
  LayoutDashboard,
  MapPin,
  Image as ImageIcon,
  Compass,
  Calendar,
  LibraryBig,
  BarChart3,
  Users as UsersIcon,
  Languages,

  Settings,
  Bell,
  Castle
} from 'lucide-react';
import { cn } from '@/src/lib/utils';
import { motion, AnimatePresence } from 'motion/react';

// Import Pages
import Dashboard from './pages/Dashboard';
import Places from './pages/Places';
import MediaLibrary from './pages/MediaLibrary';
import Analytics from './pages/Analytics';
import Events from './pages/Events';
import UsersPage from './pages/Users';
import SettingsPage from './pages/Settings';

// Mock Pages for items not yet implemented
const Activities = () => <div className="p-8 flex flex-col items-center justify-center h-[60vh] text-stone-400"><Compass className="w-16 h-16 mb-4 opacity-20" /><p className="text-xl font-medium">Activities Module Coming Soon</p></div>;
const CultureHub = () => <div className="p-8 flex flex-col items-center justify-center h-[60vh] text-stone-400"><LibraryBig className="w-16 h-16 mb-4 opacity-20" /><p className="text-xl font-medium">Culture Hub Module Coming Soon</p></div>;
const Translations = () => <div className="p-8 flex flex-col items-center justify-center h-[60vh] text-stone-400"><Languages className="w-16 h-16 mb-4 opacity-20" /><p className="text-xl font-medium">Translations Engine Coming Soon</p></div>;

type PageId = 'dashboard' | 'places' | 'media' | 'activities' | 'events' | 'culture' | 'analytics' | 'users' | 'translations' | 'settings';

interface NavItem {
  id: PageId;
  label: string;
  icon: any;
}

const navItems: NavItem[] = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'places', label: 'Places', icon: MapPin },
  { id: 'media', label: 'Media Library', icon: ImageIcon },
  { id: 'activities', label: 'Activities', icon: Compass },
  { id: 'events', label: 'Events', icon: Calendar },
  { id: 'culture', label: 'Culture Hub', icon: LibraryBig },
  { id: 'analytics', label: 'Analytics', icon: BarChart3 },
  { id: 'users', label: 'Users', icon: UsersIcon },
  { id: 'translations', label: 'Translations', icon: Languages },
  { id: 'settings', label: 'Settings', icon: Settings },
];

export default function App() {
  const [activePage, setActivePage] = useState<PageId>('dashboard');

  const renderPage = () => {
    switch (activePage) {
      case 'dashboard': return <Dashboard />;
      case 'places': return <Places />;
      case 'media': return <MediaLibrary />;
      case 'activities': return <Activities />;
      case 'events': return <Events />;
      case 'culture': return <CultureHub />;
      case 'analytics': return <Analytics />;
      case 'users': return <UsersPage />;
      case 'translations': return <Translations />;
      case 'settings': return <SettingsPage />;
      default: return <Dashboard />;
    }
  };

  return (
    <div className="flex min-h-screen bg-white text-stone-900 font-sans">
      {/* SideNavBar */}
      <aside className="w-[240px] h-screen sticky top-0 left-0 bg-stone-50/50 flex flex-col py-6 px-4 gap-2 border-r border-stone-100">
        <div className="flex items-center gap-3 px-2 mb-8">
          <div className="w-10 h-10 rounded-xl bg-emerald-800 flex items-center justify-center text-white shadow-sm overflow-hidden">
             <Castle className="w-6 h-6" />
          </div>
          <div>
            <h1 className="text-lg font-bold tracking-tight text-emerald-900">Kurdistan Go</h1>
            <p className="text-[10px] uppercase tracking-widest text-stone-400 font-bold">Admin Dashboard</p>
          </div>
        </div>

        <nav className="flex-1 space-y-1">
          {navItems.map((item) => (
            <button
              key={item.id}
              onClick={() => setActivePage(item.id)}
              className={cn(
                "w-full flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-all duration-200",
                activePage === item.id 
                  ? "bg-emerald-50 text-emerald-900 font-bold"
                  : "text-stone-500 hover:text-emerald-800 hover:bg-stone-100"
              )}
            >
              <item.icon className={cn("w-5 h-5", activePage === item.id && "text-emerald-700")} />
              {item.label}
            </button>
          ))}
        </nav>

        <div className="mt-auto pt-6 border-t border-stone-100 flex items-center gap-3 px-2">
          <img 
            className="w-8 h-8 rounded-full border border-stone-200 object-cover" 
            src="https://picsum.photos/seed/admin/100/100" 
            alt="Admin"
            referrerPolicy="no-referrer"
          />
          <div className="overflow-hidden">
            <p className="text-xs font-bold text-stone-800 truncate">Administrator</p>
            <p className="text-[10px] text-stone-400 truncate">admin@kurdistango.app</p>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col min-w-0">
        {/* TopNavBar */}
        <header className="w-full h-16 sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b border-stone-100 flex items-center justify-between px-8">
          <div className="flex items-center gap-4">
            <span className="text-xl font-medium text-emerald-900">
              {navItems.find(i => i.id === activePage)?.label}
            </span>
            {activePage === 'settings' && (
              <>
                <span className="h-4 w-[1px] bg-stone-200"></span>
                <span className="text-sm font-bold text-emerald-800 border-b-2 border-emerald-800 py-4">Global Config</span>
              </>
            )}
            {activePage === 'analytics' && (
              <span className="px-2 py-1 bg-emerald-50 text-emerald-800 text-[10px] font-bold rounded-md tracking-wider uppercase">Live Data</span>
            )}
          </div>

          <div className="flex items-center gap-6">
            <button className="text-stone-400 hover:bg-emerald-50 p-2 rounded-full transition-all">
              <Bell className="w-5 h-5" />
            </button>
            <div className="flex items-center gap-3 cursor-pointer hover:bg-emerald-50 p-1 pr-3 rounded-full transition-all">
              <img 
                className="w-8 h-8 rounded-full object-cover" 
                src="https://picsum.photos/seed/user/100/100" 
                alt="User"
                referrerPolicy="no-referrer"
              />
              <span className="text-sm font-medium text-stone-600">Kurdistan Go</span>
            </div>
          </div>
        </header>

        <div className="flex-1 overflow-y-auto bg-stone-50/30">
          <AnimatePresence mode="wait">
            <motion.div
              key={activePage}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.2 }}
            >
              {renderPage()}
            </motion.div>
          </AnimatePresence>
        </div>
      </main>
    </div>
  );
}
