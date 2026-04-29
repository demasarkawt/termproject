import { createContext, useContext, useEffect, useState } from 'react';
import type { ReactNode } from 'react';

type Mode = 'light' | 'dark';

interface ThemeCtx {
  mode: Mode;
  toggle: () => void;
  setMode: (m: Mode) => void;
}

const Ctx = createContext<ThemeCtx | null>(null);
const STORAGE_KEY = 'kg-theme';

function readInitial(): Mode {
  if (typeof window === 'undefined') return 'light';
  const saved = window.localStorage.getItem(STORAGE_KEY);
  if (saved === 'dark' || saved === 'light') return saved;
  return 'light';
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [mode, setMode] = useState<Mode>(readInitial);

  useEffect(() => {
    const root = document.documentElement;
    if (mode === 'dark') {
      root.setAttribute('data-theme', 'dark');
    } else {
      root.removeAttribute('data-theme');
    }
    try {
      window.localStorage.setItem(STORAGE_KEY, mode);
    } catch {
      /* localStorage may be unavailable in some embeds */
    }
  }, [mode]);

  const value: ThemeCtx = {
    mode,
    setMode,
    toggle: () => setMode((m) => (m === 'light' ? 'dark' : 'light')),
  };

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useTheme(): ThemeCtx {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useTheme must be used inside <ThemeProvider>');
  return ctx;
}
