import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/theme_service.dart';
import '../../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  void _onSignUp() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.register(name, email, pass);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset('assets/images/place_dukan_lake.jpg', fit: BoxFit.cover),
            ),
          ),
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black]))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text('JOIN US', style: TextStyle(color: KurdishHeritageColors.zer, fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const Text('Create your\nheritage profile', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, height: 1.1)),
                  const SizedBox(height: 48),

                  _Field(label: 'FULL NAME', controller: _name, icon: Icons.person_outline),
                  const SizedBox(height: 20),
                  _Field(label: 'EMAIL', controller: _email, icon: Icons.email_outlined),
                  const SizedBox(height: 20),
                  _Field(label: 'PASSWORD', controller: _pass, icon: Icons.lock_outline, isPass: true),

                  const SizedBox(height: 40),
                  _PrimaryBtn(label: _loading ? 'CREATING...' : 'CREATE ACCOUNT', onTap: _loading ? null : _onSignUp),
                  const SizedBox(height: 24),

                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                          children: [
                            TextSpan(text: "Already have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                            const TextSpan(text: 'LOG IN', style: TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isPass;
  const _Field({required this.label, required this.controller, required this.icon, this.isPass = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPass,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: KurdishHeritageColors.zer, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: KurdishHeritageColors.zer)),
          ),
        ),
      ],
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PrimaryBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: KurdishHeritageColors.zer, borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3)),
      ),
    );
  }
}
