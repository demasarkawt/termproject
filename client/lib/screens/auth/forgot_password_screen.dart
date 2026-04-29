import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/theme_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final emailFromQuery = GoRouterState.of(context).uri.queryParameters['email'];
    if (emailFromQuery != null && _emailCtrl.text.isEmpty) {
      _emailCtrl.text = emailFromQuery;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(bool isDark) {
    return InputDecoration(
      hintText: 'your.email@example.com',
      prefixIcon: const Icon(Icons.mail_outline_rounded, color: KurdishHeritageColors.zer),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : KurdishHeritageColors.surfaceLight,
      hintStyle: TextStyle(
        color: isDark ? Colors.white.withValues(alpha: 0.24) : KurdishHeritageColors.textSubtleLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : KurdishHeritageColors.borderLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: KurdishHeritageColors.zer, width: 2),
      ),
    );
  }

  Future<void> _sendResetCode() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showError('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$kBaseUrl/api/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        context.go('/code-sent?email=$email');
      } else {
        context.go('/code-sent?email=$email');
      }
    } catch (_) {
      if (mounted) context.go('/code-sent?email=$email');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: KurdishHeritageColors.sor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              KurdishHeritageColors.sor.withValues(alpha: isDark ? 0.1 : 0.14),
              -100,
              80,
              380,
            ),
            _buildGlowBlob(
              KurdishHeritageColors.kesk.withValues(alpha: isDark ? 0.1 : 0.12),
              280,
              420,
              300,
            ),
            _buildGlowBlob(
              KurdishHeritageColors.zer.withValues(alpha: isDark ? 0.0 : 0.08),
              40,
              520,
              260,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
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
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
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
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: KurdishHeritageColors.sor,
                                    shape: BoxShape.circle,
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: KurdishHeritageColors.sor.withValues(alpha: 0.35),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                  ),
                                  child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 30),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : KurdishHeritageColors.res,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No worries! Enter your email and we'll send you a reset code.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : KurdishHeritageColors.textMutedLight,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Email Address',
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : KurdishHeritageColors.textMutedLight,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : KurdishHeritageColors.res,
                                  ),
                                  decoration: _dec(isDark),
                                  onSubmitted: (_) => _sendResetCode(),
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _sendResetCode,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: KurdishHeritageColors.sor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: isDark ? 0 : 2,
                                      shadowColor: KurdishHeritageColors.sor.withValues(alpha: 0.45),
                                    ),
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.send_rounded, size: 20),
                                    label: Text(
                                      _isLoading ? 'Sending…' : 'Send Reset Code',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () => context.go('/signin'),
                                  child: const Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: KurdishHeritageColors.zer,
                                      fontWeight: FontWeight.w900,
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
}
