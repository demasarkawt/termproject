import { useState } from 'react';
import { 
  Settings, 
  Globe, 
  Shield, 
  Bell, 
  Database, 
  Smartphone, 
  Mail, 
  Key, 
  Save,
  Check,
  AlertCircle,
  ChevronRight,
  Eye,
  EyeOff,
  Trash2,
  Plus
} from 'lucide-react';
import { cn } from '@/src/lib/utils';

const settingsSections = [
  { id: 'general', label: 'General Settings', icon: Globe },
  { id: 'security', label: 'Security & Access', icon: Shield },
  { id: 'notifications', label: 'Notifications', icon: Bell },
  { id: 'api', label: 'API & Integrations', icon: Database },
  { id: 'mobile', label: 'Mobile App Config', icon: Smartphone },
];

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('general');
  const [isSaving, setIsSaving] = useState(false);
  const [showApiKey, setShowApiKey] = useState(false);

  const handleSave = () => {
    setIsSaving(true);
    setTimeout(() => setIsSaving(false), 1500);
  };

  return (
    <div className="p-8 max-w-[1400px] mx-auto">
      <div className="flex flex-col lg:flex-row gap-8">
        {/* Sidebar Tabs */}
        <aside className="lg:w-64 space-y-1">
          {settingsSections.map((section) => (
            <button
              key={section.id}
              onClick={() => setActiveTab(section.id)}
              className={cn(
                "w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200",
                activeTab === section.id 
                  ? "bg-emerald-800 text-white shadow-lg shadow-emerald-900/20" 
                  : "text-stone-600 hover:bg-stone-100"
              )}
            >
              <section.icon className="w-5 h-5" />
              {section.label}
            </button>
          ))}
        </aside>

        {/* Content Area */}
        <div className="flex-1 space-y-8">
          {activeTab === 'general' && (
            <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4">
              <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
                <h2 className="text-xl font-bold">Global Configuration</h2>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Site Name</label>
                    <input 
                      type="text" 
                      defaultValue="Visit Kurdistan"
                      className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Support Email</label>
                    <input 
                      type="email" 
                      defaultValue="support@kurdistan.gov"
                      className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Default Language</label>
                  <select className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all cursor-pointer">
                    <option>English (US)</option>
                    <option>Kurdish (Sorani)</option>
                    <option>Kurdish (Kurmanji)</option>
                    <option>Arabic</option>
                  </select>
                </div>

                <div className="space-y-2">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Maintenance Mode</label>
                  <div className="flex items-center justify-between p-4 bg-amber-50 border border-amber-100 rounded-xl">
                    <div className="flex items-center gap-3">
                      <AlertCircle className="w-5 h-5 text-amber-600" />
                      <div>
                        <p className="text-sm font-semibold text-amber-900">Disable Public Access</p>
                        <p className="text-xs text-amber-700">Only admins can view the site when enabled</p>
                      </div>
                    </div>
                    <button className="w-12 h-6 bg-stone-200 rounded-full relative transition-colors">
                      <div className="absolute left-1 top-1 w-4 h-4 bg-white rounded-full shadow-sm"></div>
                    </button>
                  </div>
                </div>
              </div>

              <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
                <h2 className="text-xl font-bold">SEO & Metadata</h2>
                <div className="space-y-2">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Meta Description</label>
                  <textarea 
                    rows={3}
                    defaultValue="Explore the beauty, history, and culture of the Kurdistan region. Plan your next adventure with Visit Kurdistan."
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all resize-none"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Keywords</label>
                  <div className="flex flex-wrap gap-2">
                    {['Kurdistan', 'Tourism', 'Erbil', 'Slemani', 'History', 'Nature'].map((tag) => (
                      <span key={tag} className="px-3 py-1 bg-stone-100 text-stone-600 text-xs font-bold rounded-full flex items-center gap-1">
                        {tag}
                        <button className="hover:text-red-500"><Plus className="w-3 h-3 rotate-45" /></button>
                      </span>
                    ))}
                    <button className="px-3 py-1 border border-dashed border-stone-300 text-stone-400 text-xs font-bold rounded-full hover:border-emerald-500 hover:text-emerald-500 transition-all">
                      + Add Keyword
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'api' && (
            <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4">
              <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
                <div className="flex items-center justify-between">
                  <h2 className="text-xl font-bold">API Credentials</h2>
                  <button className="text-emerald-700 text-sm font-bold hover:underline">Documentation</button>
                </div>
                
                <div className="space-y-4">
                  <div className="p-4 bg-stone-50 rounded-xl border border-stone-200">
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-xs font-bold text-stone-500 uppercase">Production API Key</span>
                      <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded">Active</span>
                    </div>
                    <div className="flex items-center gap-3">
                      <div className="flex-1 font-mono text-sm bg-white px-3 py-2 rounded-lg border border-stone-200 overflow-hidden truncate">
                        {showApiKey ? "vk_live_51Mv9L2H8sJ9k2L0m1n2o3p4q5r6s7t8u9v0" : "••••••••••••••••••••••••••••••••••••••••"}
                      </div>
                      <button 
                        onClick={() => setShowApiKey(!showApiKey)}
                        className="p-2 hover:bg-white rounded-lg transition-all"
                      >
                        {showApiKey ? <EyeOff className="w-5 h-5 text-stone-400" /> : <Eye className="w-5 h-5 text-stone-400" />}
                      </button>
                      <button className="p-2 hover:bg-white rounded-lg transition-all">
                        <Trash2 className="w-5 h-5 text-red-400" />
                      </button>
                    </div>
                  </div>
                  <button className="w-full py-3 border border-dashed border-stone-300 rounded-xl text-stone-500 text-sm font-bold hover:border-emerald-500 hover:text-emerald-500 transition-all flex items-center justify-center gap-2">
                    <Plus className="w-4 h-4" />
                    Generate New API Key
                  </button>
                </div>
              </div>

              <div className="bg-white p-8 rounded-2xl border border-stone-200 shadow-sm space-y-6">
                <h2 className="text-xl font-bold">Webhooks</h2>
                <div className="divide-y divide-stone-100">
                  {[
                    { url: 'https://api.mobileapp.com/webhooks/places', events: 'place.created, place.updated' },
                    { url: 'https://analytics.service.io/ingest', events: 'visitor.new' },
                  ].map((hook, i) => (
                    <div key={i} className="py-4 flex items-center justify-between first:pt-0 last:pb-0">
                      <div>
                        <p className="text-sm font-semibold">{hook.url}</p>
                        <p className="text-xs text-stone-400">Events: {hook.events}</p>
                      </div>
                      <button className="p-2 hover:bg-stone-100 rounded-lg">
                        <ChevronRight className="w-5 h-5 text-stone-400" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Save Bar */}
          <div className="flex items-center justify-end gap-4 pt-4">
            <button className="px-6 py-2.5 text-sm font-bold text-stone-500 hover:text-stone-800 transition-all">
              Cancel
            </button>
            <button 
              onClick={handleSave}
              disabled={isSaving}
              className="bg-emerald-800 text-white px-8 py-2.5 rounded-xl text-sm font-bold flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/20 disabled:opacity-70"
            >
              {isSaving ? (
                <>
                  <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                  Saving...
                </>
              ) : (
                <>
                  <Save className="w-4 h-4" />
                  Save Changes
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
