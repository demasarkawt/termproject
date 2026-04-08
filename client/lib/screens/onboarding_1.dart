import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_page.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      backgroundAsset: 'assets/images/qallat.JPEG',
      icon: Icons.location_on,
      title: 'Welcome to Kurdistan',
      subtitle: 'Discover the cradle of civilization, where\nancient history meets modern beauty',
      activeDot: 0,
      onSkip: () => context.go('/signin'),
      onNext: () => context.go('/onboarding2'),
    );
  }
}
