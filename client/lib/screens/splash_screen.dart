import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_branding.dart';
import '../services/user_session.dart';
import '../theme/liquid_orb.dart';
import '../widgets/liquid_orb/liquid_orb_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (UserSession.isLoggedIn) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LiquidOrbBackground(fillBehindCard: true),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    AppBranding.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 28,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.96),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppBranding.splashWordmarkCaps,
                    textAlign: TextAlign.center,
                    style: LiquidOrb.subtitleCaps.copyWith(
                      color: LiquidOrb.textSoftBlue,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _TravelMotifIcons(),
                  const SizedBox(height: 18),
                  Text(
                    AppBranding.splashDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 14,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(flex: 4),
                  _BottomTabs(
                    onSignIn: () => context.go('/signin'),
                    onSignUp: () => context.go('/signup'),
                    onTour: () => context.go('/onboarding1'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle flights / globe / explore / beach cues for a travel-first splash.
class _TravelMotifIcons extends StatelessWidget {
  const _TravelMotifIcons();

  @override
  Widget build(BuildContext context) {
    const c = Color(0xE6e8f0fe);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.flight_takeoff, color: c, size: 26),
        const SizedBox(width: 26),
        Icon(Icons.public_rounded, color: c, size: 28),
        const SizedBox(width: 26),
        Icon(Icons.explore_rounded, color: c, size: 28),
        const SizedBox(width: 26),
        Icon(Icons.beach_access_rounded, color: c, size: 26),
      ],
    );
  }
}

class _BottomTabs extends StatelessWidget {
  const _BottomTabs({
    required this.onSignIn,
    required this.onSignUp,
    required this.onTour,
  });

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback onTour;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: onSignIn,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Material(
                color: LiquidOrb.cardWhite,
                elevation: 2,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: onSignUp,
                  borderRadius: BorderRadius.circular(999),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: LiquidOrb.accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: onTour,
          style: TextButton.styleFrom(
            foregroundColor: LiquidOrb.pearl.withValues(alpha: 0.96),
          ),
          child: const Text(
            'Preview the guided tour',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: Color(0x99e8f0fe),
            ),
          ),
        ),
      ],
    );
  }
}
