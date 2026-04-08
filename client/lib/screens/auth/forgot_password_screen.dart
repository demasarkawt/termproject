import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7FFFB), Color(0xFFD6F9FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.86),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 22,
                            offset: Offset(0, 14),
                            color: Color(0x22000000),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F766E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mail_outline, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 12),

                          const Text('Forgot Password?',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 6),

                          const Text(
                            "No worries! Enter your email and we'll\nsend you a reset code.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email Address',
                              style: TextStyle(color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'your.email@example.com',
                              prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF0F766E)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: const Color(0xFF0F766E).withOpacity(0.18)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.6),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final email = _emailCtrl.text.trim();
                                // TODO: call API to send code
                                context.go('/code-sent?email=$email');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                elevation: 10,
                              ),
                              icon: const Icon(Icons.send),
                              label: const Text('Send Reset Code', style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextButton(
                            onPressed: () => context.go('/signin'),
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
