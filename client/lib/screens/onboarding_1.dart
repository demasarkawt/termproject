import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_page.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      backgroundAsset: 'assets/images/place_citadel.png',
      icon: Icons.location_on,
      title: 'Welcome to Travelo',
      subtitle: 'Plan tours & day trips—browse maps, routes,\nand places worth the visit',
      activeDot: 0,
      onSkip: () => context.go('/signin'),
      onNext: () => context.go('/onboarding2'),
    );
  }
}
