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
    <div className="flex min-h-screen bg-heritage-res text-heritage-spi font-sans">
      {/* SideNavBar */}
      <aside className="w-[260px] h-screen sticky top-0 left-0 bg-heritage-res/80 backdrop-blur-xl flex flex-col py-8 px-6 gap-2 border-r border-heritage-xweli/30">
        <div className="flex items-center gap-3 px-2 mb-10">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-heritage-sor to-heritage-xweli flex items-center justify-center text-heritage-spi shadow-lg shadow-heritage-sor/20 overflow-hidden border border-heritage-zer/20">
             <Castle className="w-7 h-7 text-heritage-zer" />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-tight text-heritage-spi font-display">Kurdistan Go</h1>
            <p className="text-[10px] uppercase tracking-[0.2em] text-heritage-zer font-bold">Admin Portal</p>
          </div>
        </div>

        <nav className="flex-1 space-y-2">
          {navItems.map((item) => (
            <button
              key={item.id}
              onClick={() => setActivePage(item.id)}
              className={cn(
                "w-full flex items-center gap-4 px-4 py-3 rounded-2xl text-sm font-medium transition-all duration-300 group",
                activePage === item.id 
                  ? "bg-heritage-zer/10 text-heritage-zer border border-heritage-zer/20 shadow-inner"
                  : "text-heritage-spi/40 hover:text-heritage-spi hover:bg-heritage-xweli/20"
              )}
            >
              <item.icon className={cn("w-5 h-5 transition-colors", activePage === item.id ? "text-heritage-zer" : "group-hover:text-heritage-zer")} />
              {item.label}
            </button>
          ))}
        </nav>

        <div className="mt-auto pt-6 border-t border-heritage-xweli/30 flex items-center gap-3 px-2">
          <img 
            className="w-10 h-10 rounded-full border-2 border-heritage-zer/30 object-cover shadow-sm" 
            src="https://picsum.photos/seed/admin/100/100" 
            alt="Admin"
            referrerPolicy="no-referrer"
          />
          <div className="overflow-hidden">
            <p className="text-xs font-bold text-heritage-spi truncate">Administrator</p>
            <p className="text-[10px] text-heritage-zer/60 truncate uppercase tracking-wider">Super Admin</p>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col min-w-0 bg-heritage-res">
        {/* TopNavBar */}
        <header className="w-full h-20 sticky top-0 z-40 bg-heritage-res/60 backdrop-blur-xl border-b border-heritage-xweli/20 flex items-center justify-between px-10">
          <div className="flex items-center gap-4">
            <span className="text-2xl font-bold text-heritage-spi font-display">
              {navItems.find(i => i.id === activePage)?.label}
            </span>
            {activePage === 'settings' && (
              <>
                <span className="h-5 w-[1px] bg-heritage-xweli/30"></span>
                <span className="text-sm font-bold text-heritage-zer border-b-2 border-heritage-zer py-6">Global Config</span>
              </>
            )}
            {activePage === 'analytics' && (
              <span className="px-3 py-1 bg-heritage-sor/20 text-heritage-sor text-[10px] font-bold rounded-full tracking-widest uppercase border border-heritage-sor/30">Live Data</span>
            )}
          </div>

          <div className="flex items-center gap-8">
            <button className="text-heritage-spi/40 hover:text-heritage-zer p-2.5 rounded-2xl hover:bg-heritage-xweli/10 transition-all border border-transparent hover:border-heritage-zer/20">
              <Bell className="w-6 h-6" />
            </button>
            <div className="flex items-center gap-3 cursor-pointer hover:bg-heritage-xweli/10 p-1.5 pr-4 rounded-full transition-all border border-transparent hover:border-heritage-zer/20 group">
              <img 
                className="w-10 h-10 rounded-full object-cover border-2 border-heritage-zer/20 group-hover:border-heritage-zer/50 transition-all" 
                src="https://picsum.photos/seed/user/100/100" 
                alt="User"
                referrerPolicy="no-referrer"
              />
              <span className="text-sm font-bold text-heritage-spi/70 group-hover:text-heritage-spi">Kurdistan Go</span>
            </div>
          </div>
        </header>

        <div className="flex-1 overflow-y-auto bg-heritage-res/50">
          <AnimatePresence mode="wait">
            <motion.div
              key={activePage}
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 1.02 }}
              transition={{ duration: 0.3, ease: "easeOut" }}
              className="min-h-full"
            >
              {renderPage()}
            </motion.div>
          </AnimatePresence>
        </div>
      </main>
    </div>
  );
}
