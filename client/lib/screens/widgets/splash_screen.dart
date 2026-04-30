
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_branding.dart';
import '../services/user_session.dart';
import '../theme/trip_planner_theme.dart';
import '../widgets/liquid_orb/liquid_orb_auth_layout.dart';

/// Trip Planner–style welcome: nature hero, brown serif headline, floating white card + pill CTA + social stubs.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _heroAsset = 'assets/images/place_dukan_lake.jpg';

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
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF3),
      body: Column(
        children: [
          Expanded(
            flex: 14,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _TravelHeroPhoto(assetPath: _heroAsset),
                // Gentle top wash so serif headline reads like the reference (dark type on sky).
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xF2FFFDF9),
                        Color(0x44FFFDF9),
                        Color(0x00000000),
                        Color(0x55000000),
                        Color(0xE6F8F7F5),
                      ],
                      stops: [0.0, 0.12, 0.42, 0.62, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: topPad + 8,
                  left: 26,
                  right: 26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Navigate the region',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: TripPlannerTheme.headlineBrown,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Let ${AppBranding.appName} guide your routes, stays, and itineraries.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: TripPlannerTheme.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 10,
            child: _TripPlannerWelcomeSheet(
              onCreateAccount: () => context.go('/signup'),
              onHaveAccount: () => context.go('/signin'),
              onTour: () => context.go('/onboarding1'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelHeroPhoto extends StatelessWidget {
  const _TravelHeroPhoto({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      alignment: Alignment.center,
      errorBuilder: (_, __, ___) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF93B5AF),
                Color(0xFF5F7F78),
                Color(0xFF3F5A53),
              ],
            ),
          ),
          child: Center(
            child: Icon(Icons.landscape_rounded, size: 72, color: Colors.white.withValues(alpha: 0.4)),
          ),
        );
      },
    );
  }
}

class _TripPlannerWelcomeSheet extends StatelessWidget {
  const _TripPlannerWelcomeSheet({
    required this.onCreateAccount,
    required this.onHaveAccount,
    required this.onTour,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onHaveAccount;
  final VoidCallback onTour;

  static const BorderRadius _topOnly = BorderRadius.vertical(top: Radius.circular(34));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TripPlannerTheme.cardLight,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: _topOnly),
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: ClipRRect(
        borderRadius: _topOnly,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: TripPlannerTheme.cardLight,
            borderRadius: _topOnly,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: TripPlannerTheme.bodyMuted.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppBranding.appName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: TripPlannerTheme.headlineBrown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Trips saved to your profile—browse offline itineraries later.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.45,
                      color: TripPlannerTheme.bodyMuted.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Material(
                    color: TripPlannerTheme.brownPrimary,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: onCreateAccount,
                      borderRadius: BorderRadius.circular(999),
                      splashColor: Colors.white.withValues(alpha: 0.14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        child: Center(
                          child: Text(
                            'Create new account',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: onHaveAccount,
                    style: TextButton.styleFrom(
                      foregroundColor: TripPlannerTheme.bodyMuted,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'I already have an account',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SIGN UP WITH',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: TripPlannerTheme.bodyMuted.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const LiquidOrbSocialRow(),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onTour,
                    style: TextButton.styleFrom(
                      foregroundColor: TripPlannerTheme.brownPrimary,
                      minimumSize: const Size(0, 40),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Preview the guided tour',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: TripPlannerTheme.brownPrimary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
