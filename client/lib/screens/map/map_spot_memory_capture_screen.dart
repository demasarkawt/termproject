import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/map_spot_memory.dart';
import '../../services/map_spot_memory_store.dart';
import '../../services/theme_service.dart';

/// One photo the user picked, held in memory until save (works with Android `content://` URIs).
class _CapturedPhoto {
  _CapturedPhoto({required this.bytes, required this.filenameHint});

  final Uint8List bytes;
  final String filenameHint;
}

/// Save a photo memory at the map center (lat/lng from route query).
class MapSpotMemoryCaptureScreen extends StatefulWidget {
  const MapSpotMemoryCaptureScreen({
    super.key,
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  @override
  State<MapSpotMemoryCaptureScreen> createState() => _MapSpotMemoryCaptureScreenState();
}

class _MapSpotMemoryCaptureScreenState extends State<MapSpotMemoryCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _thoughtsCtrl = TextEditingController();
  final List<_CapturedPhoto> _photos = [];
  bool _saving = false;
  bool _picking = false;

  static const int _maxPhotos = 12;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _thoughtsCtrl.dispose();
    super.dispose();
  }

  static String _guessExtension(String hint) {
    final e = p.extension(hint).toLowerCase();
    if (e == '.png' || e == '.webp' || e == '.heic' || e == '.jpg' || e == '.jpeg') {
      return e == '.jpeg' ? '.jpg' : e;
    }
    return '.jpg';
  }

  Future<void> _ingestFiles(Iterable<XFile> files, {required String sourceLabel}) async {
    for (final x in files) {
      if (_photos.length >= _maxPhotos) break;
      try {
        final bytes = await x.readAsBytes();
        if (bytes.isEmpty) continue;
        if (!mounted) return;
        setState(() => _photos.add(_CapturedPhoto(bytes: bytes, filenameHint: x.name.isNotEmpty ? x.name : x.path)));
      } catch (e, st) {
        debugPrint('[MapSpotMemoryCapture] read $sourceLabel bytes: $e\n$st');
        if (!mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Could not read a photo (${x.name}). Try another.')),
        );
      }
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickCamera() async {
    if (kIsWeb) {
      _toast('Camera capture is best on iOS or Android.');
      return;
    }
    setState(() => _picking = true);
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2400,
        imageQuality: 90,
      );
      if (x == null || !mounted) return;
      await _ingestFiles([x], sourceLabel: 'camera');
    } on PlatformException catch (e) {
      if (!mounted) return;
      _toast(e.message ?? 'Camera is not available. Check permissions in Settings.');
    } catch (e) {
      if (!mounted) return;
      _toast('Camera error: $e');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _pickGallery() async {
    if (kIsWeb) {
      _toast('Gallery on web is limited—use the mobile app for full map memories.');
      return;
    }
    setState(() => _picking = true);
    try {
      final remain = _maxPhotos - _photos.length;
      if (remain <= 0) {
        _toast('You can add up to $_maxPhotos photos.');
        return;
      }

      try {
        final list = await _picker.pickMultiImage(
          maxWidth: 2400,
          imageQuality: 90,
        );
        if (list.isNotEmpty) {
          await _ingestFiles(list.take(remain), sourceLabel: 'gallery');
          return;
        }
      } on PlatformException catch (_) {
        // Older devices / strict stores: fall back to one-at-a-time.
      }

      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        imageQuality: 90,
      );
      if (x != null && mounted) {
        await _ingestFiles([x], sourceLabel: 'gallery');
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      _toast(e.message ?? 'Photos need library access. Enable it in Settings.');
    } catch (e) {
      if (!mounted) return;
      _toast('Gallery error: $e');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _removeAt(int i) {
    setState(() => _photos.removeAt(i));
  }

  Future<void> _save() async {
    if (kIsWeb) {
      _toast('Saving map memories to this device works in the iOS or Android app.');
      return;
    }

    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _toast('Give this spot a title.');
      return;
    }
    if (_photos.isEmpty) {
      _toast('Add at least one photo.');
      return;
    }

    setState(() => _saving = true);
    try {
      final id = 'mem_${DateTime.now().microsecondsSinceEpoch}';
      final docs = await getApplicationDocumentsDirectory();
      final folder = Directory(p.join(docs.path, 'spot_memories', id));
      await folder.create(recursive: true);

      final paths = <String>[];
      for (var i = 0; i < _photos.length; i++) {
        final ext = _guessExtension(_photos[i].filenameHint);
        final destPath = p.join(folder.path, '$i$ext');
        await File(destPath).writeAsBytes(_photos[i].bytes, flush: true);
        paths.add(destPath);
      }

      final memory = MapSpotMemory(
        id: id,
        lat: widget.lat,
        lng: widget.lng,
        title: title,
        description: _descCtrl.text.trim(),
        thoughts: _thoughtsCtrl.text.trim(),
        imagePaths: paths,
        createdAt: DateTime.now(),
      );
      await MapSpotMemoryStore.upsert(memory);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      _toast('Could not save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService().isDark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : KurdishHeritageColors.res,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Save this spot',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : KurdishHeritageColors.res,
          ),
        ),
        actions: [
          TextButton(
            onPressed: (_saving || _picking) ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: (_saving || _picking) ? Colors.grey : KurdishHeritageColors.zer,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (kIsWeb)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: isDark ? 0.14 : 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.phone_android_rounded, color: Colors.amber.shade800),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Map memories save photos on your phone or tablet. Open Travelo on iOS/Android to add pictures.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: isDark ? Colors.amber.shade100 : KurdishHeritageColors.res,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: KurdishHeritageColors.zer.withValues(alpha: isDark ? 0.14 : 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: KurdishHeritageColors.zer.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.place_rounded, color: KurdishHeritageColors.zer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pin at ${widget.lat.toStringAsFixed(5)}, ${widget.lng.toStringAsFixed(5)} · '
                          'Center the map before tapping + to match where you stood.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : KurdishHeritageColors.res.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Photos',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? Colors.white : KurdishHeritageColors.res,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_photos.length}/$_maxPhotos · Camera or gallery; previews load before you save.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : KurdishHeritageColors.res.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 112,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _AddPhotoTile(
                        icon: Icons.photo_camera_rounded,
                        label: 'Camera',
                        enabled: !_picking && !_saving && !kIsWeb,
                        onTap: _pickCamera,
                      ),
                      const SizedBox(width: 10),
                      _AddPhotoTile(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        enabled: !_picking && !_saving && !kIsWeb,
                        onTap: _pickGallery,
                      ),
                      ...List.generate(_photos.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _PhotoThumbMemory(
                            bytes: _photos[i].bytes,
                            onRemove: () => _removeAt(i),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: isDark ? Colors.white : KurdishHeritageColors.res,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Quiet bench at Sami Park',
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: isDark ? Colors.white70 : KurdishHeritageColors.res.withValues(alpha: 0.9),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'What’s here — trees, landmark, best light…',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _thoughtsCtrl,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.amber.shade100 : KurdishHeritageColors.res.withValues(alpha: 0.88),
                  ),
                  decoration: InputDecoration(
                    labelText: 'My thoughts',
                    hintText: 'Fresh air, great sunset angle, calm crowd…',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: KurdishHeritageColors.zer.withValues(alpha: isDark ? 0.12 : 0.14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: KurdishHeritageColors.zer.withValues(alpha: 0.45)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_picking || _saving)
            Container(
              color: Colors.black26,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: KurdishHeritageColors.zer),
                        const SizedBox(height: 14),
                        Text(
                          _saving ? 'Saving your memory…' : 'Loading photos…',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService().isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled
                  ? (isDark ? Colors.white24 : Colors.black26)
                  : Colors.grey.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: enabled ? KurdishHeritageColors.zer : Colors.grey),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: enabled
                      ? (isDark ? Colors.white70 : KurdishHeritageColors.res)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoThumbMemory extends StatelessWidget {
  const _PhotoThumbMemory({required this.bytes, required this.onRemove});

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            bytes,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: KurdishHeritageColors.res,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
