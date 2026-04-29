import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import type { ChangeEvent, DragEvent } from 'react';
import { Upload, X, Star, ImagePlus, Loader2, GripVertical, Layers } from 'lucide-react';
import {
  apiUpload,
  apiPatch,
  apiDelete,
  attachGalleryFromMedia,
  describeUploadError,
  type PlaceImage,
  type LibraryImagePick,
} from '../lib/api';
import { MediaLibraryPicker } from './MediaLibraryPicker';

interface ImageUploaderProps {
  /** Owner endpoint shape: 'places' | 'cities'. We POST to `/api/{kind}/{id}/images`. */
  kind: 'places' | 'cities';
  /** When undefined we buffer uploads and media picks until parent creates the row. */
  ownerId?: number | null;
  images: PlaceImage[];
  onChange: (images: PlaceImage[]) => void;
  pendingFiles?: File[];
  onPendingFilesChange?: (files: File[]) => void;
  /** Media-library assets (by `/api/media` ID) to attach after save when `ownerId` is still null. */
  pendingLibrary?: LibraryImagePick[];
  onPendingLibraryChange?: (items: LibraryImagePick[]) => void;
  maxFiles?: number;
  className?: string;
}

const MAX_FILE_BYTES = 10 * 1024 * 1024;

function isImageFile(file: File): boolean {
  if (file.type.startsWith('image/')) return true;
  const n = file.name.toLowerCase();
  return /\.(jpe?g|png|gif|webp|heic|heif|bmp|tiff?|svg)$/i.test(n);
}

export function ImageUploader({
  kind,
  ownerId,
  images,
  onChange,
  pendingFiles,
  onPendingFilesChange,
  pendingLibrary,
  onPendingLibraryChange,
  maxFiles,
  className,
}: ImageUploaderProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [dragOver, setDragOver] = useState(false);
  const [reorderId, setReorderId] = useState<number | null>(null);
  const [pickerOpen, setPickerOpen] = useState(false);

  const localFiles = pendingFiles ?? [];
  const libPicks = pendingLibrary ?? [];

  const excludeQueuedMediaIds = useMemo(
    () => (libPicks.length ? new Set(libPicks.map((p) => p.id)) : undefined),
    [libPicks],
  );

  const acceptFiles = useCallback(
    async (files: FileList | File[]) => {
      setError(null);
      const arr = Array.from(files).filter(isImageFile);
      if (arr.length === 0) {
        setError('No usable images selected (JPEG, PNG, WebP, HEIC, GIF…).');
        return;
      }
      const oversize = arr.find((f) => f.size > MAX_FILE_BYTES);
      if (oversize) {
        setError(`"${oversize.name}" is over 10 MB.`);
        return;
      }
      let addable = arr.length;
      if (maxFiles) addable = Math.max(0, maxFiles - (images.length + localFiles.length + libPicks.length));
      const slice = addable <= 0 ? [] : arr.slice(0, addable);
      if (!slice.length) {
        setError(`Maximum ${maxFiles} image${maxFiles === 1 ? '' : 's'} allowed.`);
        return;
      }

      if (ownerId == null) {
        onPendingFilesChange?.([...localFiles, ...slice]);
        return;
      }

      setBusy(true);
      try {
        const fd = new FormData();
        slice.forEach((f) => fd.append('files', f, f.name));
        const created = await apiUpload<PlaceImage[]>(
          `/api/${kind}/${ownerId}/images`,
          fd,
        );
        onChange([...images, ...created]);
      } catch (err) {
        setError(describeUploadError(err));
      } finally {
        setBusy(false);
      }
    },
    [
      images,
      localFiles,
      libPicks.length,
      kind,
      ownerId,
      maxFiles,
      onChange,
      onPendingFilesChange,
    ],
  );

  const onPick = (e: ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) acceptFiles(e.target.files);
    e.target.value = '';
  };

  const onDrop = (e: DragEvent) => {
    e.preventDefault();
    setDragOver(false);
    if (e.dataTransfer.files?.length) acceptFiles(e.dataTransfer.files);
  };

  const removePending = (idx: number) => {
    const next = localFiles.filter((_, i) => i !== idx);
    onPendingFilesChange?.(next);
  };

  const removePendingLibrary = (idx: number) => {
    const next = libPicks.filter((_, i) => i !== idx);
    onPendingLibraryChange?.(next);
  };

  const onLibraryConfirmed = async (
    items: { id: number; data_url: string; name: string }[],
  ) => {
    if (!items.length) return;
    setError(null);

    if (ownerId != null) {
      setBusy(true);
      try {
        const existingUrls = new Set(images.map((img) => img.url.trim()));
        const ids: number[] = [];
        for (const it of items) {
          if (existingUrls.has(it.data_url.trim())) continue;
          ids.push(it.id);
          if (maxFiles && images.length + ids.length >= maxFiles) break;
        }
        const unique = [...new Set(ids)];
        if (!unique.length) {
          setError('Nothing new to attach (same URLs as existing images).');
          return;
        }
        const created = await attachGalleryFromMedia(kind, ownerId, unique);
        onChange([...images, ...created]);
      } catch (err) {
        setError(describeUploadError(err));
      } finally {
        setBusy(false);
      }
      return;
    }

    let next = [...libPicks];
    for (const it of items) {
      if (next.some((x) => x.id === it.id)) continue;
      if (
        maxFiles &&
        images.length + localFiles.length + next.length >= maxFiles
      ) {
        setError(`Maximum ${maxFiles} images allowed.`);
        break;
      }
      next.push({ id: it.id, url: it.data_url, name: it.name });
    }
    onPendingLibraryChange?.(next);
  };

  const removeImage = async (img: PlaceImage) => {
    if (ownerId == null) return;
    setBusy(true);
    setError(null);
    try {
      await apiDelete(`/api/${kind}/${ownerId}/images/${img.id}`);
      onChange(images.filter((i) => i.id !== img.id));
    } catch (err) {
      setError(describeUploadError(err));
    } finally {
      setBusy(false);
    }
  };

  const setCover = async (img: PlaceImage) => {
    if (ownerId == null) return;
    setBusy(true);
    setError(null);
    try {
      await apiPatch<PlaceImage>(
        `/api/${kind}/${ownerId}/images/${img.id}`,
        { is_cover: true },
      );
      onChange(images.map((i) => ({ ...i, is_cover: i.id === img.id })));
    } catch (err) {
      setError(describeUploadError(err));
    } finally {
      setBusy(false);
    }
  };

  const reorder = async (sourceId: number, targetId: number) => {
    if (sourceId === targetId || ownerId == null) return;
    const sorted = [...images].sort((a, b) => a.sort_order - b.sort_order);
    const sIdx = sorted.findIndex((i) => i.id === sourceId);
    const tIdx = sorted.findIndex((i) => i.id === targetId);
    if (sIdx < 0 || tIdx < 0) return;
    const [moved] = sorted.splice(sIdx, 1);
    sorted.splice(tIdx, 0, moved);
    const reindexed = sorted.map((i, idx) => ({ ...i, sort_order: idx }));
    onChange(reindexed);
    setBusy(true);
    setError(null);
    try {
      for (const i of reindexed) {
        await apiPatch<PlaceImage>(
          `/api/${kind}/${ownerId}/images/${i.id}`,
          { sort_order: i.sort_order },
        );
      }
    } catch (err) {
      setError(describeUploadError(err));
    } finally {
      setBusy(false);
    }
  };

  const [pendingPreviews, setPendingPreviews] = useState<string[]>([]);
  useEffect(() => {
    const urls = localFiles.map((f) => URL.createObjectURL(f));
    setPendingPreviews(urls);
    return () => urls.forEach((u) => URL.revokeObjectURL(u));
  }, [localFiles.length]);

  const sorted = [...images].sort((a, b) => a.sort_order - b.sort_order);
  const empty =
    sorted.length === 0 && localFiles.length === 0 && libPicks.length === 0;

  return (
    <div className={className}>
      <div
        onDragOver={(e) => {
          e.preventDefault();
          setDragOver(true);
        }}
        onDragLeave={() => setDragOver(false)}
        onDrop={onDrop}
        className={`rounded-xl border-2 border-dashed p-6 transition ${
          dragOver
            ? 'border-emerald-500 bg-emerald-50/50'
            : 'border-slate-300 hover:border-slate-400 hover:bg-slate-50'
        }`}
      >
        <input
          ref={inputRef}
          type="file"
          accept="image/*,.heic,.heif"
          multiple
          onChange={onPick}
          className="hidden"
        />

        <div className="flex flex-col items-center justify-center gap-3 text-center text-slate-600">
          {busy ? (
            <Loader2 className="h-7 w-7 animate-spin text-emerald-600" />
          ) : empty ? (
            <ImagePlus className="h-7 w-7 text-slate-400" />
          ) : (
            <Upload className="h-7 w-7 text-slate-400" />
          )}
          <div className="text-sm font-medium">
            {empty
              ? 'Drop images here or browse files'
              : 'Add more images'}
          </div>
          <div className="max-w-xs text-xs text-slate-400">
            JPG, PNG, WebP, HEIC up to 10 MB. First resolved image becomes the cover automatically.
          </div>
          <div className="flex flex-wrap justify-center gap-2">
            <button
              type="button"
              disabled={busy}
              onClick={() => inputRef.current?.click()}
              className="inline-flex items-center gap-2 rounded-lg bg-emerald-700 px-4 py-2 text-xs font-semibold text-white hover:bg-emerald-800 disabled:opacity-60"
            >
              <Upload className="h-3.5 w-3.5" /> Browse files
            </button>
            <button
              type="button"
              disabled={busy}
              onClick={() => setPickerOpen(true)}
              className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-800 hover:bg-slate-50 disabled:opacity-60"
              title="Use an existing `/api/media` upload"
            >
              <Layers className="h-3.5 w-3.5" /> Media library
            </button>
          </div>
        </div>
      </div>

      <MediaLibraryPicker
        open={pickerOpen}
        onClose={() => setPickerOpen(false)}
        onConfirm={onLibraryConfirmed}
        excludeMediaIds={excludeQueuedMediaIds}
        title="Attach from Media Library"
      />

      {error && (
        <div className="mt-2 rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-700">
          {error}
        </div>
      )}

      {(sorted.length > 0 || localFiles.length > 0 || libPicks.length > 0) && (
        <div className="mt-4 grid grid-cols-3 gap-3 sm:grid-cols-4 md:grid-cols-5">
          {sorted.map((img) => (
            <div
              key={img.id}
              draggable
              onDragStart={() => setReorderId(img.id)}
              onDragOver={(e) => e.preventDefault()}
              onDrop={(e) => {
                e.preventDefault();
                if (reorderId != null) reorder(reorderId, img.id);
                setReorderId(null);
              }}
              className={`group relative aspect-square overflow-hidden rounded-lg border bg-slate-100 ${
                img.is_cover ? 'border-emerald-500 ring-2 ring-emerald-200' : 'border-slate-200'
              }`}
            >
              <img src={img.url} alt="" className="h-full w-full object-cover" />
              {img.is_cover && (
                <div className="absolute left-1.5 top-1.5 inline-flex items-center gap-1 rounded-full bg-emerald-600 px-1.5 py-0.5 text-[10px] font-semibold text-white">
                  <Star className="h-2.5 w-2.5 fill-current" /> Cover
                </div>
              )}
              <div className="absolute inset-0 flex items-end justify-between bg-gradient-to-t from-black/60 via-transparent to-transparent p-1.5 opacity-0 transition group-hover:opacity-100">
                {!img.is_cover && (
                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      setCover(img);
                    }}
                    className="rounded-full bg-white/90 p-1 text-slate-700 shadow-sm hover:bg-white"
                    title="Set as cover"
                  >
                    <Star className="h-3.5 w-3.5" />
                  </button>
                )}
                <span className="cursor-grab text-white/80">
                  <GripVertical className="h-3.5 w-3.5" />
                </span>
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    removeImage(img);
                  }}
                  className="rounded-full bg-red-600 p-1 text-white shadow-sm hover:bg-red-700"
                  title="Delete image"
                >
                  <X className="h-3.5 w-3.5" />
                </button>
              </div>
            </div>
          ))}

          {pendingPreviews.map((src, idx) => (
            <div
              key={`pending-${idx}`}
              className="group relative aspect-square overflow-hidden rounded-lg border border-dashed border-amber-400 bg-amber-50"
              title="Will upload after save"
            >
              <img src={src} alt="" className="h-full w-full object-cover opacity-90" />
              <div className="absolute left-1.5 top-1.5 rounded-full bg-amber-500 px-1.5 py-0.5 text-[10px] font-semibold text-white">
                Pending upload
              </div>
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  removePending(idx);
                }}
                className="absolute right-1.5 top-1.5 rounded-full bg-red-600 p-1 text-white shadow-sm hover:bg-red-700"
                title="Remove"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            </div>
          ))}

          {libPicks.map((p, idx) => (
            <div
              key={`lib-${p.id}-${idx}`}
              className="group relative aspect-square overflow-hidden rounded-lg border border-emerald-200 bg-emerald-50"
              title="Will attach Media Library ID after save"
            >
              <img src={p.url} alt="" className="h-full w-full object-cover opacity-95" />
              <div className="absolute inset-x-0 bottom-0 bg-emerald-900/80 px-1 py-0.5 text-center font-mono text-[9px] font-bold uppercase text-emerald-100">
                Media #{p.id}
              </div>
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  removePendingLibrary(idx);
                }}
                className="absolute right-1 top-1 rounded-full bg-red-600 p-1 text-white shadow-sm hover:bg-red-700"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// Helper for the pending-file flow used by Place/City create flows.
export async function flushPendingFiles(
  kind: 'places' | 'cities',
  ownerId: number,
  files: File[],
): Promise<PlaceImage[]> {
  if (!files.length) return [];
  const fd = new FormData();
  files.forEach((f) => fd.append('files', f, f.name));
  return apiUpload<PlaceImage[]>(`/api/${kind}/${ownerId}/images`, fd);
}
