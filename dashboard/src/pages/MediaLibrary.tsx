import { useEffect, useRef, useState } from 'react';
import {
  Search, UploadCloud, Filter, Grid, List,
  Trash2, Download, ImageIcon, FolderPlus,
  X, Check, MapPin, Calendar, Folder, ArrowLeft,
} from 'lucide-react';
import { cn } from '@/src/lib/utils';
import { apiFetch, apiPost, apiDelete, type Place, type Event } from '@/src/lib/api';

interface UploadedItem {
  id: number;
  name: string;
  data_url: string;
  folder: string | null;
  created_at: string;
}

interface MediaItem {
  id: string;
  name: string;
  url: string;
  source: 'place' | 'event' | 'upload';
  type: string;
  folder: string | null;
  uploadedId?: number; // only for uploaded items
}

export default function MediaLibrary() {
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [selectedItems, setSelectedItems] = useState<string[]>([]);
  const [items, setItems] = useState<MediaItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [sourceFilter, setSourceFilter] = useState<'all' | 'place' | 'event' | 'upload'>('all');
  const [activeFolder, setActiveFolder] = useState<string | null>(null);

  // Upload modal
  const [showUpload, setShowUpload] = useState(false);
  const [uploadTab, setUploadTab] = useState<'file' | 'url'>('file');
  const [uploading, setUploading] = useState(false);
  const [uploadError, setUploadError] = useState('');
  const [urlInput, setUrlInput] = useState('');
  const [urlName, setUrlName] = useState('');
  const [dragOver, setDragOver] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Folder modal
  const [showFolderModal, setShowFolderModal] = useState(false);
  const [folderName, setFolderName] = useState('');

  const load = async () => {
    setLoading(true);
    try {
      const [places, events, uploaded] = await Promise.all([
        apiFetch<Place[]>('/api/places/?limit=100'),
        apiFetch<Event[]>('/api/events/'),
        apiFetch<UploadedItem[]>('/api/media/'),
      ]);

      const placeItems: MediaItem[] = places.map(p => ({
        id: `place-${p.id}`,
        name: p.name,
        url: p.image_url ?? `https://picsum.photos/seed/place-${p.id}/400/400`,
        source: 'place' as const,
        type: p.category ?? 'Place',
        folder: null,
      }));

      const eventItems: MediaItem[] = events.map(e => ({
        id: `event-${e.id}`,
        name: e.title,
        url: e.image_url ?? `https://picsum.photos/seed/event-${e.id}/400/400`,
        source: 'event' as const,
        type: e.event_type ?? 'Event',
        folder: null,
      }));

      const uploadedItems: MediaItem[] = uploaded.map(u => ({
        id: `upload-${u.id}`,
        name: u.name,
        url: u.data_url,
        source: 'upload' as const,
        type: 'Uploaded',
        folder: u.folder,
        uploadedId: u.id,
      }));

      setItems([...uploadedItems, ...placeItems, ...eventItems]);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  // Derive folders from uploaded items
  const folders = Array.from(
    new Set(items.filter(i => i.folder).map(i => i.folder as string))
  );

  const filtered = items.filter(item => {
    const matchSearch = item.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchSource = sourceFilter === 'all' || item.source === sourceFilter;
    const matchFolder = activeFolder === null
      ? true
      : item.folder === activeFolder;
    return matchSearch && matchSource && matchFolder;
  });

  const toggleSelect = (id: string) =>
    setSelectedItems(prev => prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]);

  // ── Upload file ──────────────────────────────────────────────────────────────
  const handleFiles = (files: FileList | null) => {
    if (!files || files.length === 0) return;
    const MAX = 5 * 1024 * 1024; // 5 MB
    Array.from(files).forEach(file => {
      if (file.size > MAX) { setUploadError(`"${file.name}" exceeds the 5 MB limit.`); return; }
      const reader = new FileReader();
      reader.onload = async () => {
        setUploading(true);
        setUploadError('');
        try {
          const created = await apiPost<UploadedItem>('/api/media/', {
            name: file.name,
            data_url: reader.result as string,
            folder: activeFolder,
          });
          setItems(prev => [{
            id: `upload-${created.id}`,
            name: created.name,
            url: created.data_url,
            source: 'upload',
            type: 'Uploaded',
            folder: created.folder,
            uploadedId: created.id,
          }, ...prev]);
        } catch (err: any) {
          setUploadError(err.message ?? 'Upload failed.');
        } finally {
          setUploading(false);
        }
      };
      reader.readAsDataURL(file);
    });
    setShowUpload(false);
  };

  const handleUrlUpload = async () => {
    if (!urlInput.trim()) { setUploadError('Please enter a URL.'); return; }
    setUploading(true);
    setUploadError('');
    try {
      const created = await apiPost<UploadedItem>('/api/media/', {
        name: urlName.trim() || urlInput.split('/').pop() || 'image',
        data_url: urlInput.trim(),
        folder: activeFolder,
      });
      setItems(prev => [{
        id: `upload-${created.id}`,
        name: created.name,
        url: created.data_url,
        source: 'upload',
        type: 'Uploaded',
        folder: created.folder,
        uploadedId: created.id,
      }, ...prev]);
      setShowUpload(false);
      setUrlInput('');
      setUrlName('');
    } catch (err: any) {
      setUploadError(err.message ?? 'Upload failed.');
    } finally {
      setUploading(false);
    }
  };

  // ── Delete ───────────────────────────────────────────────────────────────────
  const handleDelete = async (item: MediaItem) => {
    if (item.source !== 'upload') return;
    if (!confirm(`Delete "${item.name}"?`)) return;
    try {
      await apiDelete(`/api/media/${item.uploadedId}`);
      setItems(prev => prev.filter(i => i.id !== item.id));
      setSelectedItems(prev => prev.filter(i => i !== item.id));
    } catch {
      alert('Failed to delete.');
    }
  };

  const handleBulkDelete = async () => {
    const toDelete = items.filter(i => selectedItems.includes(i.id) && i.source === 'upload');
    if (toDelete.length === 0) { alert('Only uploaded images can be deleted.'); return; }
    if (!confirm(`Delete ${toDelete.length} item(s)?`)) return;
    await Promise.all(toDelete.map(i => apiDelete(`/api/media/${i.uploadedId}`)));
    setItems(prev => prev.filter(i => !selectedItems.includes(i.id)));
    setSelectedItems([]);
  };

  // ── Create folder ────────────────────────────────────────────────────────────
  const handleCreateFolder = () => {
    const name = folderName.trim();
    if (!name) return;
    // Folders only become real when items are placed in them.
    // For now: switch into the new folder view and any new upload will use it.
    setActiveFolder(name);
    setFolderName('');
    setShowFolderModal(false);
  };

  const sourceIcon = (source: MediaItem['source']) => {
    if (source === 'place') return <MapPin className="w-3 h-3 text-white" />;
    if (source === 'event') return <Calendar className="w-3 h-3 text-white" />;
    return <UploadCloud className="w-3 h-3 text-white" />;
  };

  return (
    <div className="p-8 max-w-[1400px] mx-auto space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            {activeFolder && (
              <button onClick={() => setActiveFolder(null)} className="p-1 hover:bg-stone-100 rounded-lg transition-all">
                <ArrowLeft className="w-4 h-4 text-stone-400" />
              </button>
            )}
            <h1 className="text-2xl font-bold text-stone-900">
              {activeFolder ? activeFolder : 'Media Library'}
            </h1>
          </div>
          <p className="text-sm text-stone-500">
            {loading ? 'Loading...' : `${filtered.length} items`}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={() => { setFolderName(''); setShowFolderModal(true); }}
            className="bg-white text-stone-700 border border-stone-200 px-4 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-stone-50 transition-all"
          >
            <FolderPlus className="w-4 h-4" /> New Folder
          </button>
          <button
            onClick={() => { setUploadError(''); setShowUpload(true); }}
            className="bg-emerald-800 text-white px-5 py-2 rounded-xl text-sm font-medium flex items-center gap-2 hover:bg-emerald-900 transition-all shadow-lg shadow-emerald-900/10"
          >
            <UploadCloud className="w-5 h-5" /> Upload Files
          </button>
        </div>
      </div>

      {/* Folders row (only on root view) */}
      {!activeFolder && folders.length > 0 && (
        <div className="flex flex-wrap gap-3">
          {folders.map(f => (
            <button
              key={f}
              onClick={() => setActiveFolder(f)}
              className="flex items-center gap-2 px-4 py-2.5 bg-white border border-stone-200 rounded-xl text-sm font-medium text-stone-700 hover:border-emerald-400 hover:bg-emerald-50 transition-all shadow-sm"
            >
              <Folder className="w-4 h-4 text-amber-400" />
              {f}
              <span className="text-xs text-stone-400">
                ({items.filter(i => i.folder === f).length})
              </span>
            </button>
          ))}
        </div>
      )}

      {/* Toolbar */}
      <div className="bg-white p-4 rounded-2xl border border-stone-200 shadow-sm flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-4 flex-1">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
            <input
              type="text"
              placeholder="Search media..."
              className="w-full pl-10 pr-4 py-2 bg-stone-50 border-none rounded-xl text-sm focus:ring-2 focus:ring-emerald-500/20 transition-all outline-none"
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
            />
          </div>
          <div className="flex items-center gap-2">
            {(['all', 'upload', 'place', 'event'] as const).map(s => (
              <button
                key={s}
                onClick={() => setSourceFilter(s)}
                className={cn(
                  'px-3 py-1.5 rounded-lg text-xs font-bold transition-all capitalize',
                  sourceFilter === s ? 'bg-emerald-800 text-white' : 'bg-stone-50 text-stone-500 hover:bg-stone-100'
                )}
              >
                {s === 'all' ? 'All' : s === 'upload' ? 'Uploaded' : s === 'place' ? 'Places' : 'Events'}
              </button>
            ))}
          </div>
          <div className="h-6 w-[1px] bg-stone-200 hidden md:block" />
          <div className="flex items-center gap-1 bg-stone-50 p-1 rounded-lg">
            <button onClick={() => setViewMode('grid')} className={cn('p-1.5 rounded-md transition-all', viewMode === 'grid' ? 'bg-white text-emerald-700 shadow-sm' : 'text-stone-400 hover:text-stone-600')}>
              <Grid className="w-4 h-4" />
            </button>
            <button onClick={() => setViewMode('list')} className={cn('p-1.5 rounded-md transition-all', viewMode === 'list' ? 'bg-white text-emerald-700 shadow-sm' : 'text-stone-400 hover:text-stone-600')}>
              <List className="w-4 h-4" />
            </button>
          </div>
        </div>

        <div className="flex items-center gap-3">
          {selectedItems.length > 0 && (
            <div className="flex items-center gap-2">
              <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-3 py-1.5 rounded-full border border-emerald-100">
                {selectedItems.length} Selected
              </span>
              <button onClick={handleBulkDelete} className="p-2 text-stone-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all">
                <Trash2 className="w-5 h-5" />
              </button>
              <button onClick={() => setSelectedItems([])} className="p-2 text-stone-400 hover:text-stone-600 rounded-lg transition-all">
                <X className="w-5 h-5" />
              </button>
            </div>
          )}
          <button className="p-2 bg-stone-50 rounded-xl hover:bg-stone-100 transition-all">
            <Filter className="w-5 h-5 text-stone-500" />
          </button>
        </div>
      </div>

      {/* Content */}
      {loading ? (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-6">
          {[...Array(12)].map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-stone-200 overflow-hidden animate-pulse">
              <div className="aspect-square bg-stone-100" />
              <div className="p-3 space-y-1"><div className="h-3 bg-stone-100 rounded w-3/4" /><div className="h-2 bg-stone-100 rounded w-1/2" /></div>
            </div>
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div
          className="py-24 flex flex-col items-center justify-center text-center border-2 border-dashed border-stone-200 rounded-2xl cursor-pointer hover:border-emerald-400 hover:bg-emerald-50/30 transition-all"
          onClick={() => setShowUpload(true)}
        >
          <UploadCloud className="w-16 h-16 text-stone-200 mb-4" />
          <p className="text-stone-400 text-sm font-medium">No media found</p>
          <p className="text-stone-300 text-xs mt-1">Click to upload your first file</p>
        </div>
      ) : viewMode === 'grid' ? (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-6">
          {filtered.map(item => (
            <div
              key={item.id}
              className={cn(
                'group relative bg-white rounded-2xl border transition-all duration-200 overflow-hidden',
                selectedItems.includes(item.id)
                  ? 'border-emerald-500 ring-2 ring-emerald-500/20 shadow-lg'
                  : 'border-stone-200 hover:border-emerald-300 hover:shadow-md'
              )}
            >
              <div className="aspect-square relative overflow-hidden bg-stone-100 cursor-pointer" onClick={() => toggleSelect(item.id)}>
                <img
                  src={item.url}
                  alt={item.name}
                  className={cn('w-full h-full object-cover transition-transform duration-500 group-hover:scale-110', selectedItems.includes(item.id) && 'opacity-80')}
                  onError={e => { (e.target as HTMLImageElement).src = `https://picsum.photos/seed/${item.id}/400/400`; }}
                />
                <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors" />
                <div className={cn('absolute top-3 left-3 w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all',
                  selectedItems.includes(item.id) ? 'bg-emerald-500 border-emerald-500 text-white' : 'bg-white/40 border-white/60 text-transparent group-hover:bg-white/60')}>
                  <Check className="w-4 h-4" />
                </div>
                <div className="absolute bottom-3 right-3 flex items-center gap-1 px-2 py-1 bg-black/40 backdrop-blur-md rounded-md">
                  {sourceIcon(item.source)}
                  <span className="text-[8px] font-bold text-white uppercase tracking-wider">{item.source}</span>
                </div>
                {/* Delete button for uploaded items */}
                {item.source === 'upload' && (
                  <button
                    onClick={e => { e.stopPropagation(); handleDelete(item); }}
                    className="absolute top-3 right-3 p-1.5 bg-red-500 text-white rounded-lg opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
                  >
                    <Trash2 className="w-3 h-3" />
                  </button>
                )}
              </div>
              <div className="p-3">
                <p className="text-[11px] font-semibold text-stone-800 truncate mb-0.5">{item.name}</p>
                <p className="text-[10px] text-stone-400 font-medium uppercase tracking-wider">{item.type}</p>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-stone-200 shadow-sm overflow-hidden">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-stone-50/50 border-b border-stone-200">
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400 w-8" />
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Name</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Source</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400">Type</th>
                <th className="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-stone-400 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-100">
              {filtered.map(item => (
                <tr key={item.id} className="hover:bg-stone-50/50 transition-colors group">
                  <td className="px-6 py-3">
                    <div
                      className={cn('w-5 h-5 rounded border-2 flex items-center justify-center cursor-pointer transition-all',
                        selectedItems.includes(item.id) ? 'bg-emerald-500 border-emerald-500 text-white' : 'border-stone-300 hover:border-emerald-400')}
                      onClick={() => toggleSelect(item.id)}
                    >
                      {selectedItems.includes(item.id) && <Check className="w-3 h-3" />}
                    </div>
                  </td>
                  <td className="px-6 py-3">
                    <div className="flex items-center gap-3">
                      <img src={item.url} alt={item.name} className="w-10 h-10 rounded-lg object-cover bg-stone-100"
                        onError={e => { (e.target as HTMLImageElement).src = `https://picsum.photos/seed/${item.id}/100/100`; }} />
                      <span className="text-sm font-medium text-stone-800">{item.name}</span>
                    </div>
                  </td>
                  <td className="px-6 py-3">
                    <div className="flex items-center gap-1.5 text-xs text-stone-500 font-medium capitalize">
                      {item.source}
                    </div>
                  </td>
                  <td className="px-6 py-3">
                    <span className="text-xs font-bold uppercase text-stone-400">{item.type}</span>
                  </td>
                  <td className="px-6 py-3 text-right">
                    <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <a href={item.url} target="_blank" rel="noreferrer"
                        className="p-2 hover:bg-stone-100 rounded-lg transition-all text-stone-400">
                        <Download className="w-4 h-4" />
                      </a>
                      {item.source === 'upload' && (
                        <button onClick={() => handleDelete(item)}
                          className="p-2 hover:bg-red-50 rounded-lg transition-all text-red-400">
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* ── Upload Modal ────────────────────────────────────────────────────────── */}
      {showUpload && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md">
            <div className="flex items-center justify-between p-6 border-b border-stone-200">
              <h2 className="text-lg font-bold">Upload Media</h2>
              <button onClick={() => setShowUpload(false)} className="p-2 hover:bg-stone-100 rounded-lg">
                <X className="w-5 h-5 text-stone-400" />
              </button>
            </div>

            {/* Tabs */}
            <div className="flex border-b border-stone-100">
              {(['file', 'url'] as const).map(tab => (
                <button key={tab} onClick={() => { setUploadTab(tab); setUploadError(''); }}
                  className={cn('flex-1 py-3 text-sm font-bold transition-all capitalize',
                    uploadTab === tab ? 'text-emerald-800 border-b-2 border-emerald-800' : 'text-stone-400 hover:text-stone-600')}>
                  {tab === 'file' ? 'Upload File' : 'From URL'}
                </button>
              ))}
            </div>

            <div className="p-6 space-y-4">
              {uploadError && (
                <div className="p-3 bg-red-50 border border-red-100 rounded-xl text-sm text-red-700">{uploadError}</div>
              )}

              {uploadTab === 'file' ? (
                <>
                  <input ref={fileInputRef} type="file" accept="image/*" multiple className="hidden"
                    onChange={e => handleFiles(e.target.files)} />
                  <div
                    className={cn('border-2 border-dashed rounded-2xl p-10 text-center cursor-pointer transition-all',
                      dragOver ? 'border-emerald-500 bg-emerald-50' : 'border-stone-200 hover:border-emerald-400 hover:bg-emerald-50/30')}
                    onClick={() => fileInputRef.current?.click()}
                    onDragOver={e => { e.preventDefault(); setDragOver(true); }}
                    onDragLeave={() => setDragOver(false)}
                    onDrop={e => { e.preventDefault(); setDragOver(false); handleFiles(e.dataTransfer.files); }}
                  >
                    <UploadCloud className="w-10 h-10 text-stone-300 mx-auto mb-3" />
                    <p className="text-sm font-semibold text-stone-600">Drop images here or click to browse</p>
                    <p className="text-xs text-stone-400 mt-1">PNG, JPG, GIF, WebP — max 5 MB each</p>
                  </div>
                  {uploading && (
                    <div className="flex items-center justify-center gap-2 text-sm text-emerald-700">
                      <div className="w-4 h-4 border-2 border-emerald-200 border-t-emerald-700 rounded-full animate-spin" />
                      Uploading...
                    </div>
                  )}
                </>
              ) : (
                <>
                  <div className="space-y-1.5">
                    <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Image URL</label>
                    <input type="url" value={urlInput} onChange={e => setUrlInput(e.target.value)}
                      placeholder="https://example.com/image.jpg"
                      className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20" />
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Name (optional)</label>
                    <input type="text" value={urlName} onChange={e => setUrlName(e.target.value)}
                      placeholder="My image name"
                      className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20" />
                  </div>
                  <button onClick={handleUrlUpload} disabled={uploading}
                    className="w-full py-2.5 text-sm font-bold bg-emerald-800 text-white rounded-xl hover:bg-emerald-900 transition-all disabled:opacity-60 flex items-center justify-center gap-2">
                    {uploading ? <><div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />Adding...</> : 'Add Image'}
                  </button>
                </>
              )}
            </div>
          </div>
        </div>
      )}

      {/* ── New Folder Modal ─────────────────────────────────────────────────────── */}
      {showFolderModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm">
            <div className="flex items-center justify-between p-6 border-b border-stone-200">
              <h2 className="text-lg font-bold">New Folder</h2>
              <button onClick={() => setShowFolderModal(false)} className="p-2 hover:bg-stone-100 rounded-lg">
                <X className="w-5 h-5 text-stone-400" />
              </button>
            </div>
            <div className="p-6 space-y-4">
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Folder Name</label>
                <input
                  type="text"
                  value={folderName}
                  onChange={e => setFolderName(e.target.value)}
                  onKeyDown={e => e.key === 'Enter' && handleCreateFolder()}
                  placeholder="e.g. Erbil Photos"
                  autoFocus
                  className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-emerald-500/20"
                />
              </div>
              <p className="text-xs text-stone-400">
                The folder opens and any files you upload next will be placed inside it.
              </p>
              <div className="flex gap-3">
                <button onClick={() => setShowFolderModal(false)}
                  className="flex-1 py-2.5 text-sm font-bold text-stone-500 border border-stone-200 rounded-xl hover:bg-stone-50 transition-all">
                  Cancel
                </button>
                <button onClick={handleCreateFolder} disabled={!folderName.trim()}
                  className="flex-1 py-2.5 text-sm font-bold bg-emerald-800 text-white rounded-xl hover:bg-emerald-900 transition-all disabled:opacity-40">
                  Create Folder
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
