import { useEffect, useState } from 'react';
import { Shield, Database, Eye, EyeOff, Copy, Check } from 'lucide-react';
import { cn } from '@/src/lib/utils';
import { apiFetch, ApiError, ADMIN_KEY, API_URL, type HealthInfo } from '@/src/lib/api';
import { useToast } from '@/src/components/Toast';

const SECTIONS = [
  { id: 'security', label: 'Security & Access', icon: Shield },
  { id: 'api', label: 'API & Backend', icon: Database },
];

export default function SettingsPage() {
  const toast = useToast();
  const [activeTab, setActiveTab] = useState<'security' | 'api'>('security');
  const [loading, setLoading] = useState(true);
  const [showApiKey, setShowApiKey] = useState(false);
  const [copied, setCopied] = useState(false);

  const [health, setHealth] = useState<HealthInfo | null>(null);

  const refresh = async () => {
    setLoading(true);
    try {
      const h = await apiFetch<HealthInfo>('/api/health');
      setHealth(h);
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const copyKey = async () => {
    try {
      await navigator.clipboard.writeText(ADMIN_KEY);
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    } catch {
      toast.error('Could not copy to clipboard.');
    }
  };

  return (
    <div className="p-8 max-w-[1400px] mx-auto">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-stone-900">Settings</h1>
        <p className="text-sm text-stone-500 mt-1">
          Admin credentials and backend status — site copy and SEO are no longer edited here.
        </p>
      </div>

      <div className="flex flex-col lg:flex-row gap-8">
        <aside className="lg:w-64 space-y-1">
          {SECTIONS.map((section) => (
            <button
              key={section.id}
              onClick={() => setActiveTab(section.id as 'security' | 'api')}
              className={cn(
                'w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200',
                activeTab === section.id
                  ? 'bg-emerald-800 text-white shadow-lg shadow-emerald-900/20'
                  : 'text-stone-600 hover:bg-stone-100',
              )}
            >
              <section.icon className="w-5 h-5" />
              {section.label}
            </button>
          ))}
        </aside>

        <div className="flex-1 space-y-8">
          {activeTab === 'security' ? (
            <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
              <h2 className="text-xl font-bold">Admin access</h2>
              <p className="text-sm text-stone-500">
                This dashboard sends an{' '}
                <code className="rounded bg-stone-100 px-1.5 py-0.5 text-xs">X-Admin-Key</code> header from{' '}
                <code className="rounded bg-stone-100 px-1.5 py-0.5 text-xs">VITE_ADMIN_KEY</code>; it must match{' '}
                <code className="rounded bg-stone-100 px-1.5 py-0.5 text-xs">ADMIN_KEY</code> on the API.
              </p>
              <KeyRow
                label="Current admin key"
                value={ADMIN_KEY || '(not set)'}
                show={showApiKey}
                onToggle={() => setShowApiKey((v) => !v)}
                onCopy={ADMIN_KEY ? copyKey : undefined}
                copied={copied}
              />
              <div className="rounded-xl border border-amber-200 bg-amber-50 p-4 text-xs text-amber-800 leading-relaxed">
                Rotate both <code>ADMIN_KEY</code> (<code>server/.env</code>) and{' '}
                <code>VITE_ADMIN_KEY</code> (<code>dashboard/.env</code>), then redeploy / restart.
              </div>
            </div>
          ) : loading ? (
            <div className="rounded-2xl border border-stone-200 bg-white p-12 text-center text-sm text-stone-400">
              Loading status…
            </div>
          ) : (
            <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
              <h2 className="text-xl font-bold">Backend status</h2>
              <dl className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                <div className="rounded-xl border border-stone-200 bg-stone-50 p-4">
                  <dt className="text-xs uppercase font-bold text-stone-400">API URL</dt>
                  <dd className="mt-1 break-all font-mono text-xs">{API_URL}</dd>
                </div>
                <div className="rounded-xl border border-stone-200 bg-stone-50 p-4">
                  <dt className="text-xs uppercase font-bold text-stone-400">Health</dt>
                  <dd className="mt-1 flex items-center gap-2 text-stone-700">
                    <span
                      className={cn(
                        'inline-block h-2 w-2 rounded-full',
                        health?.status === 'healthy' ? 'bg-emerald-500' : 'bg-red-500',
                      )}
                    />
                    {health?.status ?? 'unknown'}
                  </dd>
                </div>
                <Status label="R2 configured" ok={!!health?.r2_configured} />
                <Status
                  label="R2 public URL"
                  ok={!!health?.r2_public_url}
                  hint="Optional — presigned URLs may be used instead."
                />
                <Status label="Admin key set" ok={!!health?.admin_configured} />
                <Status
                  label="PostgreSQL"
                  ok={!!health?.database_configured}
                  hint="DATABASE_URL must be set on the API service."
                />
              </dl>
              <button
                type="button"
                onClick={refresh}
                className="rounded-xl border border-stone-200 px-4 py-2 text-sm font-semibold text-stone-700 hover:bg-stone-50"
              >
                Refresh status
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function KeyRow({
  label,
  value,
  show,
  onToggle,
  onCopy,
  copied,
}: {
  label: string;
  value: string;
  show: boolean;
  onToggle: () => void;
  onCopy?: () => void;
  copied?: boolean;
}) {
  return (
    <div className="rounded-xl border border-stone-200 bg-stone-50 p-4 space-y-2">
      <div className="text-xs font-bold uppercase tracking-wider text-stone-500">{label}</div>
      <div className="flex items-center gap-3">
        <code className="flex-1 truncate rounded-lg border border-stone-200 bg-white px-3 py-2 text-xs">
          {show ? value : '•'.repeat(Math.min(40, value.length))}
        </code>
        <button
          type="button"
          onClick={onToggle}
          className="rounded-lg p-2 text-stone-400 hover:bg-white hover:text-stone-600"
          title={show ? 'Hide' : 'Show'}
        >
          {show ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
        </button>
        {onCopy && (
          <button
            type="button"
            onClick={onCopy}
            className="rounded-lg p-2 text-stone-400 hover:bg-white hover:text-stone-600"
            title="Copy"
          >
            {copied ? <Check className="h-4 w-4 text-emerald-600" /> : <Copy className="h-4 w-4" />}
          </button>
        )}
      </div>
    </div>
  );
}

function Status({ label, ok, hint }: { label: string; ok: boolean; hint?: string }) {
  return (
    <div className="rounded-xl border border-stone-200 bg-stone-50 p-4">
      <dt className="text-xs uppercase font-bold text-stone-400">{label}</dt>
      <dd className="mt-1 flex items-center gap-2 text-stone-700">
        <span
          className={cn('inline-block h-2 w-2 rounded-full', ok ? 'bg-emerald-500' : 'bg-red-500')}
        />
        {ok ? 'enabled' : 'disabled'}
      </dd>
      {hint && <p className="mt-1 text-[10px] text-stone-500">{hint}</p>}
    </div>
  );
}
