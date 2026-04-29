import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:termproject/config/api_config.dart';
import 'package:termproject/utils/fastapi_error.dart';
import 'package:termproject/services/user_session.dart';
import 'package:termproject/constants/app_branding.dart';
import 'package:termproject/theme/liquid_orb.dart';
import 'package:termproject/widgets/liquid_orb/liquid_orb_auth_layout.dart';

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
  bool _agreePrivacy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/splash');
    }
  }

  Future<void> _signUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: LiquidOrb.snackBarError,
        ),
      );
      return;
    }

    if (!_agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm you agree to the processing of your data'),
          backgroundColor: LiquidOrb.snackBarError,
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address (e.g. name@domain.com)'),
          backgroundColor: LiquidOrb.snackBarError,
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
            SnackBar(content: Text(msg), backgroundColor: LiquidOrb.snackBarError),
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
            backgroundColor: LiquidOrb.snackBarError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orbTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: LiquidOrb.accent),
    );

    return Theme(
      data: orbTheme,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: LiquidOrbAuthLayout(
          travelHeroAsset: AppBranding.authTravelHeroAsset,
          onBack: () => _goBack(context),
          cardChild: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create account',
                  textAlign: TextAlign.center,
                  style: LiquidOrb.heading,
                ),
                const SizedBox(height: 8),
                Text(
                  AppBranding.signUpEyebrow,
                  textAlign: TextAlign.center,
                  style: LiquidOrb.subtitleCaps,
                ),
                const SizedBox(height: 28),
                Text(
                  'Full name',
                  style: LiquidOrb.labelSmall.copyWith(fontSize: 11, letterSpacing: 0.55),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: LiquidOrb.accent,
                  style: const TextStyle(
                    fontSize: 15,
                    color: LiquidOrb.textHeading,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: LiquidOrb.orbInputDecoration(hint: 'Your name').copyWith(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: LiquidOrb.accent, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Email',
                  style: LiquidOrb.labelSmall.copyWith(fontSize: 11, letterSpacing: 0.55),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  cursorColor: LiquidOrb.accent,
                  style: const TextStyle(
                    fontSize: 15,
                    color: LiquidOrb.textHeading,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: LiquidOrb.orbInputDecoration(hint: 'you@email.com').copyWith(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: LiquidOrb.accent, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Password',
                  style: LiquidOrb.labelSmall.copyWith(fontSize: 11, letterSpacing: 0.55),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  cursorColor: LiquidOrb.accent,
                  style: const TextStyle(
                    fontSize: 15,
                    color: LiquidOrb.textHeading,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: LiquidOrb.orbInputDecoration(
                    hint: '••••••••',
                    suffix: IconButton(
                      splashRadius: 20,
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: LiquidOrb.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                LiquidOrbCheckboxTile(
                  value: _agreePrivacy,
                  onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                  label: Text.rich(
                    TextSpan(
                      style: LiquidOrb.labelSmall,
                      children: const [
                        TextSpan(
                          text:
                              'I agree to the processing of my personal data in line with app policies.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                LiquidOrbPrimaryButton(
                  label: 'Sign up',
                  loading: _isLoading,
                  onPressed: _signUp,
                ),
                const SizedBox(height: 28),
                Text(
                  'OR CONTINUE WITH',
                  textAlign: TextAlign.center,
                  style: LiquidOrb.subtitleCaps.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 16),
                const LiquidOrbSocialRow(),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: LiquidOrb.labelSmall.copyWith(color: LiquidOrb.textLabel),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/signin'),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: LiquidOrb.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
