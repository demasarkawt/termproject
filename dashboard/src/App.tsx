import { useState } from 'react';
import {
  LayoutDashboard,
  MapPin,
  Image as ImageIcon,
  Calendar,
  BarChart3,
  Users as UsersIcon,
  Building2,
  Map as MapIconLucide,
  Settings,
  Castle,
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
}

const navItems: NavItem[] = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'places', label: 'Places', icon: MapPin },
  { id: 'cities', label: 'Cities', icon: Building2 },
  { id: 'map', label: 'Map', icon: MapIconLucide },
  { id: 'events', label: 'Events', icon: Calendar },
  { id: 'media', label: 'Media Library', icon: ImageIcon },
  { id: 'analytics', label: 'Analytics', icon: BarChart3 },
  { id: 'users', label: 'Users', icon: UsersIcon },
  { id: 'settings', label: 'Settings', icon: Settings },
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
        <div className="flex items-center gap-3 px-2 mb-8">
          <div
            className="w-10 h-10 rounded-xl flex items-center justify-center text-white shadow-sm overflow-hidden"
            style={{ backgroundColor: 'var(--color-kesk)' }}
          >
            <Castle className="w-6 h-6" />
          </div>
          <div>
            <h1 className="text-lg font-bold tracking-tight text-zer">Kurdistan Go</h1>
            <p className="text-[10px] uppercase tracking-widest text-subtle font-bold">
              Admin Dashboard
            </p>
          </div>
        </div>

        <nav className="flex-1 space-y-1">
          {navItems.map((item) => (
            <button
              key={item.id}
              onClick={() => setActivePage(item.id)}
              className={cn(
                'w-full flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-all duration-200',
                activePage === item.id
                  ? 'bg-zer-soft text-zer font-bold'
                  : 'text-muted hover:bg-surface-2',
              )}
            >
              <item.icon className={cn('w-5 h-5', activePage === item.id && 'text-zer')} />
              {item.label}
            </button>
          ))}
        </nav>

        <div className="mt-auto pt-6 border-t border-token flex items-center gap-3 px-2">
          <div
            className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold"
            style={{ backgroundColor: 'var(--color-kesk)' }}
          >
            A
          </div>
          <div className="overflow-hidden">
            <p className="text-xs font-bold text-default truncate">Administrator</p>
            <p className="text-[10px] text-subtle truncate">admin@kurdistango.app</p>
          </div>
        </div>
      </aside>

      <main className="flex-1 flex flex-col min-w-0">
        <header
          className="w-full h-16 sticky top-0 z-40 backdrop-blur-md border-b border-token flex items-center justify-between px-8"
          style={{ backgroundColor: 'color-mix(in srgb, var(--color-surface) 80%, transparent)' }}
        >
          <div className="flex items-center gap-4">
            <span className="text-xl font-medium text-zer">
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
                K
              </div>
              <span className="text-sm font-medium text-muted">Kurdistan Go</span>
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
