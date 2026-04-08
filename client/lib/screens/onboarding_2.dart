import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_page.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      backgroundAsset: 'assets/images/shanadar.JPEG',
      icon: Icons.landscape,
      title: 'Explore Hidden Gems',
      subtitle: 'From majestic mountains to stunning \nwaterfalls, find breathtaking destinations',
      activeDot: 1,
      onSkip: () => context.go('/signin'),
      onNext: () => context.go('/onboarding3'), // finish onboarding for now
    );
  }
}
