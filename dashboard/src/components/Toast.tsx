import { createContext, useCallback, useContext, useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { CheckCircle2, AlertTriangle, Info, X } from 'lucide-react';
import { recordActivity } from './NotificationsBell';

type ToastKind = 'success' | 'error' | 'info';
interface Toast {
  id: number;
  kind: ToastKind;
  message: string;
}

interface ToastCtx {
  push: (message: string, kind?: ToastKind) => void;
  success: (message: string) => void;
  error: (message: string) => void;
  info: (message: string) => void;
}

const Ctx = createContext<ToastCtx | null>(null);

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const push = useCallback((message: string, kind: ToastKind = 'info') => {
    setToasts((prev) => [...prev, { id: Date.now() + Math.random(), kind, message }]);
    const activityKind = kind === 'error' ? 'warn' : kind === 'success' ? 'success' : 'info';
    recordActivity(message, activityKind);
  }, []);

  const value: ToastCtx = {
    push,
    success: (m) => push(m, 'success'),
    error: (m) => push(m, 'error'),
    info: (m) => push(m, 'info'),
  };

  return (
    <Ctx.Provider value={value}>
      {children}
      <div className="pointer-events-none fixed right-4 top-4 z-[100] flex w-80 max-w-[90vw] flex-col gap-2">
        {toasts.map((t) => (
          <ToastView
            key={t.id}
            toast={t}
            onClose={() =>
              setToasts((prev) => prev.filter((x) => x.id !== t.id))
            }
          />
        ))}
      </div>
    </Ctx.Provider>
  );
}

function ToastView(props: { toast: Toast; onClose: () => void }) {
  const { toast, onClose } = props;
  useEffect(() => {
    const t = setTimeout(onClose, 4500);
    return () => clearTimeout(t);
  }, [onClose]);

  const palette =
    toast.kind === 'success'
      ? 'border-emerald-200 bg-emerald-50 text-emerald-800'
      : toast.kind === 'error'
        ? 'border-red-200 bg-red-50 text-red-800'
        : 'border-slate-200 bg-white text-slate-800';
  const Icon =
    toast.kind === 'success' ? CheckCircle2 : toast.kind === 'error' ? AlertTriangle : Info;
  const iconColor =
    toast.kind === 'success'
      ? 'text-emerald-600'
      : toast.kind === 'error'
        ? 'text-red-600'
        : 'text-slate-500';

  return (
    <div
      className={`pointer-events-auto flex items-start gap-2 rounded-xl border px-3 py-2.5 shadow-md backdrop-blur ${palette}`}
    >
      <Icon className={`mt-0.5 h-4 w-4 shrink-0 ${iconColor}`} />
      <div className="flex-1 text-sm leading-relaxed">{toast.message}</div>
      <button
        onClick={onClose}
        className="rounded-md p-1 text-slate-400 hover:bg-white/60 hover:text-slate-600"
      >
        <X className="h-3.5 w-3.5" />
      </button>
    </div>
  );
}

export function useToast(): ToastCtx {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useToast must be used inside <ToastProvider>');
  return ctx;
}
