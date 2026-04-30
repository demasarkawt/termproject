import { useState } from 'react';
import {
  Gauge,
  Compass,
  Landmark,
  MapPinned,
  Ticket,
  Images,
  LineChart,
  UserCircle2,
  SlidersHorizontal,
  Mountain,
  Sun,
  Moon,
} from 'lucide-react';
import { NotificationsBell } from './components/NotificationsBell';
import { cn } from '@/src/lib/utils';
import { motion, AnimatePresence } from 'motion/react';

import Dashboard from './pages/Dashboard';
import Places from './pages/Places';
import Cities from './pages/Cities';
import MapPage from './pages/Map';
import MediaLibrary from './pages/MediaLibrary';
import Analytics from './pages/Analytics';
import Events from './pages/Events';
import UsersPage from './pages/Users';
import SettingsPage from './pages/Settings';
import { ToastProvider } from './components/Toast';
import { ThemeProvider, useTheme } from './lib/theme';

export type PageId =
  | 'dashboard'
  | 'places'
  | 'cities'
  | 'map'
  | 'media'
  | 'events'
  | 'analytics'
  | 'users'
  | 'settings';

interface NavItem {
  id: PageId;
  label: string;
  icon: any;
  color: string;
}

const navItems: NavItem[] = [
  { id: 'dashboard', label: 'Dashboard', icon: Gauge, color: 'var(--color-sor)' },
  { id: 'places', label: 'Places', icon: Compass, color: 'var(--color-kesk)' },
  { id: 'cities', label: 'Cities', icon: Landmark, color: 'var(--color-zer)' },
  { id: 'map', label: 'Map', icon: MapPinned, color: 'var(--color-zer)' },
  { id: 'events', label: 'Events', icon: Ticket, color: 'var(--color-events)' },
  { id: 'media', label: 'Media', icon: Images, color: 'var(--color-xweli)' },
  { id: 'analytics', label: 'Analytics', icon: LineChart, color: 'var(--color-xweli)' },
  { id: 'users', label: 'Users', icon: UserCircle2, color: 'var(--color-xweli)' },
  { id: 'settings', label: 'Settings', icon: SlidersHorizontal, color: 'var(--color-xweli)' },
];

export default function App() {
  return (
    <ThemeProvider>
      <ToastProvider>
        <Shell />
      </ToastProvider>
    </ThemeProvider>
  );
}

function Shell() {
  const [activePage, setActivePage] = useState<PageId>('dashboard');
  const { mode, toggle } = useTheme();

  const navigate = (id: PageId) => setActivePage(id);

  const renderPage = () => {
    switch (activePage) {
      case 'dashboard':
        return <Dashboard onNavigate={navigate} />;
      case 'places':
        return <Places />;
      case 'cities':
        return <Cities />;
      case 'map':
        return <MapPage onEditPlace={() => navigate('places')} />;
      case 'media':
        return <MediaLibrary />;
      case 'events':
        return <Events />;
      case 'analytics':
        return <Analytics />;
      case 'users':
        return <UsersPage />;
      case 'settings':
        return <SettingsPage />;
      default:
        return <Dashboard onNavigate={navigate} />;
    }
  };

  return (
    <div className="flex min-h-screen text-default font-sans">
      <aside className="w-[240px] h-screen sticky top-0 left-0 bg-surface flex flex-col py-6 px-4 gap-2 border-r border-token">
        <div className="flex items-center gap-4 px-2 mb-10">
          <div
            className="w-12 h-12 rounded-2xl flex items-center justify-center text-white shadow-lg overflow-hidden border-2 border-zer"
            style={{ backgroundColor: 'var(--color-res)' }}
          >
            <img src="/KGO.png" alt="Travelo" className="w-full h-full object-cover" />
          </div>
          <div>
            <h1 className="text-xl font-black tracking-tight text-default leading-none">TRAVELO</h1>
            <p className="text-[10px] uppercase tracking-[0.2em] text-zer font-black mt-1">
              Command
            </p>
          </div>
        </div>

        <div className="px-2 mb-6">
          <HeritagePatternDivider />
        </div>

        <nav className="flex-1 space-y-3">
          {navItems.map((item) => {
            const isActive = activePage === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActivePage(item.id)}
                className={cn(
                  'w-full flex items-center gap-2 py-2 px-3 rounded-2xl text-sm transition-all duration-300 group relative overflow-visible',
                  isActive
                    ? 'font-bold bg-surface-3/30'
                    : 'text-muted hover:bg-surface-3/50'
                )}
              >
                <div className="relative z-10 flex items-center gap-4 w-full">
                  <div className="relative w-10 h-10 flex items-center justify-center">
                    {/* Parallax Glow */}
                    {isActive && (
                      <motion.div
                        layoutId="nav-glow"
                        className="absolute inset-1 rotate-45 blur-md"
                        style={{ backgroundColor: item.color, opacity: 0.4 }}
                      />
                    )}
                    
                    {/* Main Diamond */}
                    <div 
                      className={cn(
                        "absolute w-8 h-8 rotate-45 transition-all duration-500 border-2",
                        isActive 
                          ? "border-white shadow-lg" 
                          : "border-transparent group-hover:border-token group-hover:bg-surface-3"
                      )}
                      style={{ 
                        backgroundColor: isActive ? item.color : 'transparent',
                        boxShadow: isActive ? '4px 4px 12px rgba(0,0,0,0.25)' : 'none'
                      }}
                    />
                    
                    {/* Inner White Diamond */}
                    <div 
                      className={cn(
                        "absolute rotate-45 transition-all duration-300 bg-white",
                        isActive ? "w-0 h-0 opacity-0" : "w-2.5 h-2.5 opacity-0 group-hover:opacity-100"
                      )}
                    />

                    {/* Icon */}
                    <item.icon 
                      className={cn(
                        'relative z-10 w-4 h-4 transition-all duration-300',
                        isActive ? "text-white scale-110" : "text-muted group-hover:scale-110"
                      )} 
                    />
                  </div>
                  <span className={cn(
                    "tracking-wide transition-all duration-300",
                    isActive ? "text-default" : "text-muted group-hover:text-default"
                  )}>
                    {item.label}
                  </span>
                </div>
                
                {isActive && (
                  <motion.div 
                    layoutId="active-pill"
                    className="absolute right-[-4px] top-1/2 -translate-y-1/2 w-1.5 h-8 rounded-l-full"
                    style={{ backgroundColor: item.color }}
                  />
                )}
              </button>
            );
          })}
        </nav>

        <div className="mt-auto pt-6 border-t border-token flex items-center gap-3 px-2">
          <div
            className="w-10 h-10 rounded-xl flex items-center justify-center text-white text-xs font-bold border-2 border-zer shadow-md"
            style={{ backgroundColor: 'var(--color-res)' }}
          >
            AD
          </div>
          <div className="overflow-hidden">
            <p className="text-xs font-black text-default truncate">ADMINISTRATOR</p>
            <p className="text-[10px] text-subtle truncate uppercase tracking-tighter">admin@travelo.app</p>
          </div>
        </div>
      </aside>

      <main className="flex-1 flex flex-col min-w-0">
        <header
          className="w-full h-16 sticky top-0 z-40 backdrop-blur-md border-b border-token flex items-center justify-between px-8"
          style={{ backgroundColor: 'color-mix(in srgb, var(--color-surface) 80%, transparent)' }}
        >
          <div className="flex items-center gap-4">
            <span className="text-xl font-black tracking-tight text-default uppercase">
              {navItems.find((i) => i.id === activePage)?.label}
            </span>
            {activePage === 'analytics' && (
              <span className="px-2 py-1 bg-kesk-soft text-kesk text-[10px] font-bold rounded-md tracking-wider uppercase">
                Live Data
              </span>
            )}
          </div>

          <div className="flex items-center gap-3">
            <button
              onClick={toggle}
              title={mode === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'}
              className="rounded-full p-2 text-muted hover:bg-surface-2 transition-all"
            >
              {mode === 'dark' ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
            </button>
            <NotificationsBell />
            <div className="flex items-center gap-3 cursor-pointer hover:bg-surface-2 p-1 pr-3 rounded-full transition-all">
              <div
                className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold"
                style={{ backgroundColor: 'var(--color-zer)' }}
              >
                T
              </div>
              <span className="text-sm font-medium text-muted">Travelo</span>
            </div>
          </div>
        </header>

        <div className="flex-1 overflow-y-auto bg-surface-2">
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
function HeritagePatternDivider() {
  return (
    <div className="flex items-center gap-2 justify-center">
      {[...Array(5)].map((_, i) => (
        <div 
          key={i}
          className={cn(
            "w-2 h-2 rotate-45 border border-white/20",
            i % 2 === 0 ? "bg-sor" : "bg-kesk"
          )}
        />
      ))}
    </div>
  );
}
