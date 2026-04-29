import { useEffect, useMemo, useState } from 'react';
import {
  Globe, Shield, Database, Save, AlertCircle, Eye, EyeOff, Copy, Check,
} from 'lucide-react';
import { cn } from '@/src/lib/utils';
import {
  apiFetch, apiPatch, ApiError, ADMIN_KEY, API_URL,
  type SiteSettings, type HealthInfo,
} from '@/src/lib/api';
import { useToast } from '@/src/components/Toast';

const SECTIONS = [
  { id: 'general', label: 'General', icon: Globe },
  { id: 'security', label: 'Security & Access', icon: Shield },
  { id: 'api', label: 'API & Backend', icon: Database },
];

interface FormState {
  site_name: string;
  site_description: string;
  contact_email: string;
  maintenance_mode: boolean;
  seo_keywords: string;
}

const empty: FormState = {
  site_name: '',
  site_description: '',
  contact_email: '',
  maintenance_mode: false,
  seo_keywords: '',
};

export default function SettingsPage() {
  const toast = useToast();
  const [activeTab, setActiveTab] = useState('general');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showApiKey, setShowApiKey] = useState(false);
  const [copied, setCopied] = useState(false);

  const [original, setOriginal] = useState<FormState>(empty);
  const [form, setForm] = useState<FormState>(empty);

  const [health, setHealth] = useState<HealthInfo | null>(null);

  const refresh = async () => {
    setLoading(true);
    try {
      const [s, h] = await Promise.all([
        apiFetch<SiteSettings>('/api/settings/site'),
        apiFetch<HealthInfo>('/api/health'),
      ]);
      const next: FormState = {
        site_name: s.site_name ?? '',
        site_description: s.site_description ?? '',
        contact_email: s.contact_email ?? '',
        maintenance_mode: s.maintenance_mode ?? false,
        seo_keywords: s.seo_keywords ?? '',
      };
      setOriginal(next);
      setForm(next);
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

  const dirty = useMemo(
    () => JSON.stringify(form) !== JSON.stringify(original),
    [form, original],
  );

  const save = async () => {
    setSaving(true);
    try {
      const updated = await apiPatch<SiteSettings>('/api/settings/site', form);
      const next: FormState = {
        site_name: updated.site_name,
        site_description: updated.site_description ?? '',
        contact_email: updated.contact_email ?? '',
        maintenance_mode: updated.maintenance_mode,
        seo_keywords: updated.seo_keywords ?? '',
      };
      setOriginal(next);
      setForm(next);
      toast.success('Settings saved.');
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    } finally {
      setSaving(false);
    }
  };

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
      <div className="flex flex-col lg:flex-row gap-8">
        <aside className="lg:w-64 space-y-1">
          {SECTIONS.map((section) => (
            <button
              key={section.id}
              onClick={() => setActiveTab(section.id)}
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
          {loading ? (
            <div className="rounded-2xl border border-stone-200 bg-white p-12 text-center text-sm text-stone-400">
              Loading settings…
            </div>
          ) : activeTab === 'general' ? (
            <>
              <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
                <h2 className="text-xl font-bold">Global Configuration</h2>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Site Name</label>
                    <input
                      value={form.site_name}
                      onChange={(e) => setForm((f) => ({ ...f, site_name: e.target.value }))}
                      className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Support Email</label>
                    <input
                      type="email"
                      value={form.contact_email}
                      onChange={(e) => setForm((f) => ({ ...f, contact_email: e.target.value }))}
                      className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Maintenance Mode</label>
                  <div className="flex items-center justify-between p-4 bg-amber-50 border border-amber-100 rounded-xl">
                    <div className="flex items-center gap-3">
                      <AlertCircle className="w-5 h-5 text-amber-600" />
                      <div>
                        <p className="text-sm font-semibold text-amber-900">Disable Public Access</p>
                        <p className="text-xs text-amber-700">
                          When on, the Flutter app and dashboard can show a maintenance banner.
                        </p>
                      </div>
                    </div>
                    <button
                      onClick={() =>
                        setForm((f) => ({ ...f, maintenance_mode: !f.maintenance_mode }))
                      }
                      className={cn(
                        'relative h-6 w-12 rounded-full transition-colors',
                        form.maintenance_mode ? 'bg-emerald-600' : 'bg-stone-200',
                      )}
                    >
                      <div
                        className={cn(
                          'absolute top-1 h-4 w-4 rounded-full bg-white shadow-sm transition-all',
                          form.maintenance_mode ? 'left-7' : 'left-1',
                        )}
                      />
                    </button>
                  </div>
                </div>
              </div>

              <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
                <h2 className="text-xl font-bold">SEO & Metadata</h2>
                <div className="space-y-2">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">
                    Meta Description
                  </label>
                  <textarea
                    rows={3}
                    value={form.site_description}
                    onChange={(e) => setForm((f) => ({ ...f, site_description: e.target.value }))}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all resize-none"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">
                    Keywords (comma separated)
                  </label>
                  <input
                    value={form.seo_keywords}
                    onChange={(e) => setForm((f) => ({ ...f, seo_keywords: e.target.value }))}
                    placeholder="Kurdistan, Tourism, Erbil, Slemani"
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                  />
                </div>
              </div>
            </>
          ) : activeTab === 'security' ? (
            <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
              <h2 className="text-xl font-bold">Admin Access</h2>
              <p className="text-sm text-stone-500">
                The dashboard authenticates with the backend using an{' '}
                <code className="rounded bg-stone-100 px-1.5 py-0.5 text-xs">X-Admin-Key</code>{' '}
                header read from <code className="rounded bg-stone-100 px-1.5 py-0.5 text-xs">VITE_ADMIN_KEY</code>.
                It must match the <code className="rounded bg-stone-100 px-1.5 py-0.5 text-xs">ADMIN_KEY</code>{' '}
                env var on the server.
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
                Rotate this key by updating both <code>ADMIN_KEY</code> in <code>server/.env</code> and{' '}
                <code>VITE_ADMIN_KEY</code> in <code>dashboard/.env</code>, then restart both services.
              </div>
            </div>
          ) : (
            <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
              <h2 className="text-xl font-bold">Backend Status</h2>
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
                <Status label="R2 public URL" ok={!!health?.r2_public_url} hint="Optional - presigned URLs are used otherwise." />
                <Status label="Admin key set" ok={!!health?.admin_configured} />
                <Status
                  label="PostgreSQL (Railway)"
                  ok={!!health?.database_configured}
                  hint="DATABASE_URL must be set on the Railway API service (internal postgres.* URL is OK there only)."
                />
              </dl>
              <button
                onClick={refresh}
                className="rounded-xl border border-stone-200 px-4 py-2 text-sm font-semibold text-stone-700 hover:bg-stone-50"
              >
                Refresh status
              </button>
            </div>
          )}

          {activeTab === 'general' && (
            <div className="flex items-center justify-end gap-4 pt-4">
              <button
                onClick={() => setForm(original)}
                disabled={!dirty || saving}
                className="px-6 py-2.5 text-sm font-bold text-stone-500 hover:text-stone-800 transition-all disabled:opacity-40"
              >
                Discard
              </button>
              <button
                onClick={save}
                disabled={!dirty || saving}
                className="bg-emerald-800 text-white px-8 py-2.5 rounded-xl text-sm font-bold flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/20 disabled:opacity-50"
              >
                {saving ? (
                  <>
                    <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Saving...
                  </>
                ) : (
                  <>
                    <Save className="w-4 h-4" /> Save changes
                  </>
                )}
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
          onClick={onToggle}
          className="rounded-lg p-2 text-stone-400 hover:bg-white hover:text-stone-600"
          title={show ? 'Hide' : 'Show'}
        >
          {show ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
        </button>
        {onCopy && (
          <button
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
          className={cn(
            'inline-block h-2 w-2 rounded-full',
            ok ? 'bg-emerald-500' : 'bg-red-500',
          )}
        />
        {ok ? 'enabled' : 'disabled'}
      </dd>
      {hint && <p className="mt-1 text-[10px] text-stone-500">{hint}</p>}
    </div>
  );
}
