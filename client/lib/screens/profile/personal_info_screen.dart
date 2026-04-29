import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:termproject/config/api_config.dart';
import 'package:termproject/services/theme_service.dart';
import 'package:termproject/services/user_session.dart';
import 'package:termproject/utils/fastapi_error.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _avatarPath = UserSession.avatarLocalPath;
    _nameCtrl.text = UserSession.userName ?? '';
    _emailCtrl.text = UserSession.userEmail ?? '';
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final id = UserSession.userId;
    if (id == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final r = await http.get(
        Uri.parse('$kBaseUrl/api/users/$id'),
        headers: UserSession.authHeaders,
      );
      if (r.statusCode == 200 && mounted) {
        final m = jsonDecode(r.body) as Map<String, dynamic>;
        await UserSession.updateLocalProfile(
          name: m['name'] as String?,
          email: m['email'] as String?,
        );
        _nameCtrl.text = UserSession.userName ?? '';
        _emailCtrl.text = UserSession.userEmail ?? '';
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickAvatar() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 88,
    );
    if (x == null || !mounted) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dest = File('${dir.path}/profile_avatar.jpg');
      await File(x.path).copy(dest.path);
      await UserSession.setAvatarLocalPath(dest.path);
      setState(() => _avatarPath = dest.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save profile photo.')),
      );
    }
  }

  Future<void> _clearAvatar() async {
    await UserSession.setAvatarLocalPath(null);
    setState(() => _avatarPath = null);
  }

  Future<void> _save() async {
    final id = UserSession.userId;
    if (id == null) return;
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required.')),
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final r = await http.patch(
        Uri.parse('$kBaseUrl/api/users/$id'),
        headers: UserSession.authHeaders,
        body: jsonEncode({'name': name, 'email': email}),
      );
      if (r.statusCode == 200) {
        final m = jsonDecode(r.body) as Map<String, dynamic>;
        await UserSession.updateLocalProfile(
          name: m['name'] as String?,
          email: m['email'] as String?,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated')),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(messageFromFastApiBody(r.body))),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Personal information')),
        body: const Center(child: CircularProgressIndicator(color: KurdishHeritageColors.zer)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: KurdishHeritageColors.zer.withValues(alpha: 0.2),
                  backgroundImage: _avatarPath != null && File(_avatarPath!).existsSync()
                      ? FileImage(File(_avatarPath!))
                      : null,
                  child: _avatarPath == null || !File(_avatarPath!).existsSync()
                      ? Icon(Icons.person_rounded, size: 56, color: isDark ? Colors.white54 : KurdishHeritageColors.res)
                      : null,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Material(
                    color: KurdishHeritageColors.zer,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: _pickAvatar,
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _avatarPath != null ? _clearAvatar : null,
              child: const Text('Remove photo'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Display name', style: _labelStyle(isDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDeco(isDark, hint: 'Your name'),
          ),
          const SizedBox(height: 20),
          Text('Email', style: _labelStyle(isDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: _inputDeco(isDark, hint: 'you@email.com'),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: KurdishHeritageColors.zer,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _saving
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save changes'),
          ),
          const SizedBox(height: 12),
          Text(
            'Profile photo is stored on this device only.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle(bool isDark) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: isDark ? Colors.white70 : KurdishHeritageColors.res,
    );
  }

  InputDecoration _inputDeco(bool isDark, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
