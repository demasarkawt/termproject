import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/theme_service.dart';

class CodeSentScreen extends StatelessWidget {
  final String email;
  const CodeSentScreen({super.key, required this.email});

  Widget _buildGlowBlob(Color color, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayEmail = email.isEmpty ? 'your email' : email;

    return Scaffold(
      backgroundColor: isDark ? KurdishHeritageColors.res : Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? KurdishHeritageColors.res : null,
          gradient: isDark
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    KurdishHeritageColors.surfaceLight,
                    KurdishHeritageColors.surface2Light,
                    KurdishHeritageColors.surface3Light,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
        ),
        child: Stack(
          children: [
            _buildGlowBlob(
              KurdishHeritageColors.kesk.withValues(alpha: isDark ? 0.1 : 0.14),
              -80,
              120,
              360,
            ),
            _buildGlowBlob(
              KurdishHeritageColors.zer.withValues(alpha: isDark ? 0.08 : 0.1),
              240,
              380,
              280,
            ),
            _buildGlowBlob(
              KurdishHeritageColors.sor.withValues(alpha: isDark ? 0.0 : 0.06),
              60,
              540,
              240,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => context.canPop() ? context.pop() : context.go('/signin'),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.white.withValues(alpha: 0.06) : KurdishHeritageColors.surfaceLight,
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : KurdishHeritageColors.borderLight,
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : KurdishHeritageColors.res,
                          size: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : KurdishHeritageColors.surfaceLight,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : KurdishHeritageColors.borderLight,
                              ),
                              boxShadow: isDark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: KurdishHeritageColors.res.withValues(alpha: 0.08),
                                        blurRadius: 28,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: KurdishHeritageColors.kesk,
                                    shape: BoxShape.circle,
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: KurdishHeritageColors.kesk.withValues(alpha: 0.35),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Code Sent!',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : KurdishHeritageColors.res,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "We've sent a reset code to",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : KurdishHeritageColors.textMutedLight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  displayEmail,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? KurdishHeritageColors.zer : KurdishHeritageColors.sor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Please check your inbox and follow the instructions.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white60 : KurdishHeritageColors.textMutedLight,
                                  ),
                                ),
                                const SizedBox(height: 26),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: () => context.go('/signin'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: KurdishHeritageColors.sor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: isDark ? 0 : 2,
                                      shadowColor: KurdishHeritageColors.sor.withValues(alpha: 0.45),
                                    ),
                                    child: const Text(
                                      'Back to Login',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
