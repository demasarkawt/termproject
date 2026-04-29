import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_page.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      backgroundAsset: 'assets/images/place_bekhal.png',
      icon: Icons.explore, // change icon if you want
      title: 'Start Your Journey',
      subtitle: 'Find places, maps, and favorites\nall in one app',
      activeDot: 2, // <-- third dot
      onSkip: () => context.go('/signin'),
      onNext: () => context.go('/signin'), // later change to /signin or /home
    );
  }
}