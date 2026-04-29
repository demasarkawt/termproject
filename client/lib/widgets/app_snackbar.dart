import 'package:flutter/material.dart';

/// Tiny helper around `ScaffoldMessenger.showSnackBar` so screens don't need
/// to repeat the same boilerplate when reporting API failures or status.
class AppSnackBar {
  static void error(BuildContext context, String message) =>
      _show(context, message, Colors.red.shade700, Icons.error_outline);

  static void success(BuildContext context, String message) =>
      _show(context, message, const Color(0xFF1F5E37), Icons.check_circle_outline);

  static void info(BuildContext context, String message) =>
      _show(context, message, Colors.blueGrey.shade700, Icons.info_outline);

  static void _show(
    BuildContext context,
    String message,
    Color background,
    IconData icon,
  ) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
