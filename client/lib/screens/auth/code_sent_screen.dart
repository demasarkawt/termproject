import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/theme_service.dart';

class CodeSentScreen extends StatefulWidget {
  final String email;
  const CodeSentScreen({super.key, required this.email});

  @override
  State<CodeSentScreen> createState() => _CodeSentScreenState();
}

class _CodeSentScreenState extends State<CodeSentScreen> {
  final _code = TextEditingController();
  bool _loading = false;

  void _onVerify() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text('VERIFICATION', style: TextStyle(color: KurdishHeritageColors.zer, fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const Text('Check your\ninbox', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, height: 1.1)),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15, height: 1.6),
                      children: [
                        const TextSpan(text: 'We have sent a 6-digit verification code to '),
                        TextSpan(text: widget.email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const TextSpan(text: '. Enter it below to proceed.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  _Field(label: 'VERIFICATION CODE', controller: _code, icon: Icons.numbers_rounded),

                  const SizedBox(height: 40),
                  _PrimaryBtn(label: _loading ? 'VERIFYING...' : 'VERIFY & CONTINUE', onTap: _loading ? null : _onVerify),
                  
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "DIDN'T RECEIVE A CODE? RESEND",
                        style: TextStyle(color: KurdishHeritageColors.zer.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
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
  const _Field({required this.label, required this.controller, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
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
