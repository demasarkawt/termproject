import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:termproject/constants/app_branding.dart';
import 'package:termproject/services/theme_service.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'We’re here to help',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : KurdishHeritageColors.res,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Questions about tours, maps, or your account?',
            style: TextStyle(fontSize: 15, color: text, height: 1.45),
          ),
          const SizedBox(height: 28),
          _card(
            context,
            icon: Icons.mail_outline_rounded,
            title: 'Email support',
            subtitle: 'support@travelo.example\n(Replace with your real inbox in production.)',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Common topics',
            subtitle: '• Saved places not syncing\n• Trip dates and offline maps\n• AI trip suggestions',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: Icons.info_outline_rounded,
            title: 'App',
            subtitle: '${AppBranding.appName} mobile client',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: KurdishHeritageColors.zer, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isDark ? Colors.white : KurdishHeritageColors.res,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
