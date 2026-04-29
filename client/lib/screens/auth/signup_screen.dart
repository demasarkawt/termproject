import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:termproject/config/api_config.dart';
import 'package:termproject/services/user_session.dart';
import 'package:termproject/services/theme_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec({
    required String hint,
    required IconData icon,
    required bool isDark,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: KurdishHeritageColors.zer),
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : KurdishHeritageColors.surfaceLight,
      hintStyle: TextStyle(
        color: isDark ? Colors.white.withOpacity(0.24) : KurdishHeritageColors.textSubtleLight,
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
          color: isDark ? Colors.white.withOpacity(0.12) : KurdishHeritageColors.borderLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: KurdishHeritageColors.zer, width: 2),
      ),
    );
  }

  Future<void> _signUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: KurdishHeritageColors.sor),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': pass}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await UserSession.save(
          id: data['user']['id'],
          name: data['user']['name'],
          level: data['user']['level'] ?? 1,
          token: data['access_token'],
        );
        if (mounted) context.go('/home');
      } else {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['detail'] ?? 'Registration failed'), backgroundColor: KurdishHeritageColors.sor),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.'), backgroundColor: KurdishHeritageColors.sor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              KurdishHeritageColors.kesk.withOpacity(isDark ? 0.1 : 0.14),
              -100,
              200,
              400,
            ),
            _buildGlowBlob(
              KurdishHeritageColors.sor.withOpacity(isDark ? 0.1 : 0.12),
              300,
              500,
              300,
            ),
            _buildGlowBlob(
              KurdishHeritageColors.zer.withOpacity(isDark ? 0.0 : 0.08),
              60,
              600,
              260,
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: 0.785,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : KurdishHeritageColors.surface3Light.withOpacity(0.6),
                                border: Border.all(color: KurdishHeritageColors.zer.withOpacity(0.35), width: 2),
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: 0.785,
                            child: Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                color: isDark ? KurdishHeritageColors.res : KurdishHeritageColors.surfaceLight,
                                border: Border.all(color: KurdishHeritageColors.zer, width: 2),
                                boxShadow: isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: KurdishHeritageColors.res.withOpacity(0.06),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                              ),
                              child: Transform.rotate(
                                angle: -0.785,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset('assets/images/KGO.png', fit: BoxFit.contain),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    IconButton(
                      onPressed: () => context.go('/signin'),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.06)
                            : KurdishHeritageColors.surfaceLight,
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : KurdishHeritageColors.borderLight,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : KurdishHeritageColors.res,
                        size: 18,
                      ),
                    ),
                  const SizedBox(height: 20),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join the Journey',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : KurdishHeritageColors.res,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create an account to explore Kurdistan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : KurdishHeritageColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  TextField(
                    controller: _nameCtrl,
                    style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res),
                    decoration: _dec(hint: 'Full Name', icon: Icons.person_rounded, isDark: isDark),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailCtrl,
                    style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res),
                    decoration: _dec(hint: 'Email Address', icon: Icons.mail_rounded, isDark: isDark),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res),
                    decoration: _dec(
                      hint: 'Password',
                      icon: Icons.lock_rounded,
                      isDark: isDark,
                      suffix: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: isDark
                              ? Colors.white.withOpacity(0.3)
                              : KurdishHeritageColors.textSubtleLight,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KurdishHeritageColors.kesk,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: isDark ? 0 : 2,
                        shadowColor: KurdishHeritageColors.kesk.withOpacity(0.45),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: isDark ? Colors.white54 : KurdishHeritageColors.textMutedLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signin'),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
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
