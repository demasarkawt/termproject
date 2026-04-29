import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/map_spot_memory.dart';
import '../../services/map_spot_memory_store.dart';
import '../../services/theme_service.dart';

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
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _thoughtsCtrl = TextEditingController();
  final List<XFile> _photos = [];
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _thoughtsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCamera() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 2400,
      imageQuality: 90,
    );
    if (x == null || !mounted) return;
    setState(() => _photos.add(x));
  }

  Future<void> _pickGallery() async {
    final list = await ImagePicker().pickMultiImage(
      maxWidth: 2400,
      imageQuality: 90,
    );
    if (list.isEmpty || !mounted) return;
    setState(() {
      for (final x in list) {
        if (_photos.length >= 12) break;
        _photos.add(x);
      }
    });
  }

  void _removeAt(int i) {
    setState(() => _photos.removeAt(i));
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give this spot a title.')),
      );
      return;
    }
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one photo.')),
      );
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
        final ext = p.extension(_photos[i].path);
        final safeExt = ext.isEmpty ? '.jpg' : ext;
        final destPath = p.join(folder.path, '$i$safeExt');
        await File(_photos[i].path).copy(destPath);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
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
            onPressed: _saving ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: _saving ? Colors.grey : KurdishHeritageColors.zer,
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
                const SizedBox(height: 10),
                SizedBox(
                  height: 112,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _AddPhotoTile(icon: Icons.photo_camera_rounded, label: 'Camera', onTap: _pickCamera),
                      const SizedBox(width: 10),
                      _AddPhotoTile(icon: Icons.photo_library_rounded, label: 'Gallery', onTap: _pickGallery),
                      ...List.generate(_photos.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _PhotoThumb(
                            file: File(_photos[i].path),
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
          if (_saving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: KurdishHeritageColors.zer),
                        SizedBox(height: 14),
                        Text('Saving your memory…', style: TextStyle(fontWeight: FontWeight.w700)),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService().isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white24 : Colors.black26, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: KurdishHeritageColors.zer),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: isDark ? Colors.white70 : KurdishHeritageColors.res)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
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
