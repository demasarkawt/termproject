import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:termproject/services/theme_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final body = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'How we use your data',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : KurdishHeritageColors.res,
            ),
          ),
          const SizedBox(height: 16),
          _p(
            'Travelo collects the account details you provide (name, email) '
            'and information about the trips and saved places you create in the app. '
            'We use this to personalize your experience and sync data across devices '
            'when you sign in.',
            body,
          ),
          const SizedBox(height: 16),
          _p(
            'We do not sell your personal information. Network requests to our API '
            'are sent over HTTPS. You can delete your account data by contacting support '
            'or using account tools when available.',
            body,
          ),
          const SizedBox(height: 16),
          _p(
            'Location and map features may use your device location only when you '
            'allow it in system settings.',
            body,
          ),
        ],
      ),
    );
  }

  Widget _p(String t, Color color) {
    return Text(t, style: TextStyle(fontSize: 15, height: 1.5, color: color));
  }
}
