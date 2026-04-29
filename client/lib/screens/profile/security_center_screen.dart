import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:termproject/config/api_config.dart';
import 'package:termproject/services/theme_service.dart';
import 'package:termproject/services/user_session.dart';
import 'package:termproject/utils/fastapi_error.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _ob1 = true;
  bool _ob2 = true;
  bool _ob3 = true;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final id = UserSession.userId;
    if (id == null) return;

    final c = _current.text;
    final n = _next.text;
    final cf = _confirm.text;
    if (c.isEmpty || n.isEmpty || cf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all password fields.')),
      );
      return;
    }
    if (n.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 8 characters.')),
      );
      return;
    }
    if (n != cf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final r = await http.post(
        Uri.parse('$kBaseUrl/api/users/$id/password'),
        headers: UserSession.authHeaders,
        body: jsonEncode({
          'current_password': c,
          'new_password': n,
        }),
      );
      if (!mounted) return;
      if (r.statusCode == 204) {
        _current.clear();
        _next.clear();
        _confirm.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(messageFromFastApiBody(r.body))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Change password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : KurdishHeritageColors.res,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use a strong password you do not reuse elsewhere.',
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black54),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _current,
            obscureText: _ob1,
            decoration: InputDecoration(
              labelText: 'Current password',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _ob1 = !_ob1),
                icon: Icon(_ob1 ? Icons.visibility_rounded : Icons.visibility_off_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _next,
            obscureText: _ob2,
            decoration: InputDecoration(
              labelText: 'New password',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _ob2 = !_ob2),
                icon: Icon(_ob2 ? Icons.visibility_rounded : Icons.visibility_off_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: _ob3,
            decoration: InputDecoration(
              labelText: 'Confirm new password',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _ob3 = !_ob3),
                icon: Icon(_ob3 ? Icons.visibility_rounded : Icons.visibility_off_rounded),
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: KurdishHeritageColors.zer,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update password'),
          ),
          const SizedBox(height: 24),
          Text(
            'Two-factor authentication and session management will appear here in a future update.',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black45),
          ),
        ],
      ),
    );
  }
}
