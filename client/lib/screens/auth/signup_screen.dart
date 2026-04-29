import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:termproject/config/api_config.dart';
import 'package:termproject/utils/fastapi_error.dart';
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
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
      hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: KurdishHeritageColors.zer, width: 1.5),
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

    // Quick check so FastAPI EmailStr rejects don't look like a "network" failure.
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address (e.g. name@domain.com)'),
          backgroundColor: KurdishHeritageColors.sor,
        ),
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
        final msg = messageFromFastApiBody(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: KurdishHeritageColors.sor),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kBaseUrl.startsWith('http://127.') || kBaseUrl.startsWith('http://localhost')
                  ? 'Could not reach the API ($kBaseUrl). Is the server running?'
                  : 'Network error. Please try again.',
            ),
            backgroundColor: KurdishHeritageColors.sor,
          ),
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
      backgroundColor: isDark ? KurdishHeritageColors.res : KurdishHeritageColors.spi,
      body: Stack(
        children: [
          // ── Background Glows ──────────────────────────────────────────
          _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.1), -100, 200, 400),
          _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.1), 300, 500, 300),

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
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                border: Border.all(color: KurdishHeritageColors.zer.withOpacity(0.3), width: 2),
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: 0.785,
                            child: Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                color: isDark ? KurdishHeritageColors.res : Colors.white,
                                border: Border.all(color: KurdishHeritageColors.zer, width: 2),
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
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : KurdishHeritageColors.res),
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
                            color: isDark ? Colors.white54 : Colors.black54,
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
                          color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
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
                        elevation: 0,
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
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w600),
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
