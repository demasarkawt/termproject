import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class OnboardingPage extends StatefulWidget {
  final String backgroundAsset;
  final IconData icon; 
  final String title;
  final String subtitle;
  final int activeDot;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingPage({
    super.key,
    required this.backgroundAsset,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.activeDot,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _zoom;
  late Animation<double> _blur;
  late Animation<double> _fade;
  late Animation<double> _parallax;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    
    _zoom = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
    _blur = Tween<double>(begin: 20.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.8, curve: Curves.easeIn)));
    _parallax = Tween<double>(begin: 30.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundAsset != widget.backgroundAsset) {
      _ctrl.reset();
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Background Scenery ────────────────────────────────────
              Transform.scale(
                scale: _zoom.value,
                child: Image.asset(widget.backgroundAsset, fit: BoxFit.cover),
              ),

              // ── 2. Cinematic Focus Shift ──────────────────────────────────
              if (_blur.value > 0.1)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _blur.value, sigmaY: _blur.value),
                  child: Container(color: Colors.transparent),
                ),

              // ── 3. Gradient Protection ────────────────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 4. Skip Button ───────────────────────────────────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Opacity(
                      opacity: _fade.value,
                      child: _buildGlassBtn('Skip', widget.onSkip),
                    ),
                  ),
                ),
              ),

              // ── 5. Bottom UI Card ────────────────────────────────────────
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Transform.translate(
                      offset: Offset(0, _parallax.value),
                      child: Opacity(
                        opacity: _fade.value,
                        child: _buildBottomCard(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heritage Label (Clean & Professional)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: KurdishHeritageColors.zer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: KurdishHeritageColors.zer.withOpacity(0.3)),
                ),
                child: const Text(
                  'HERITAGE EDITION',
                  style: TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title.toUpperCase(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -1),
              ),
              const SizedBox(height: 12),
              Text(
                widget.subtitle,
                style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.65), height: 1.6, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Dots(activeIndex: widget.activeDot, count: 3),
                  GestureDetector(
                    onTap: widget.onNext,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [KurdishHeritageColors.zer, Color(0xFFF7C948)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                        ],
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int activeIndex;
  final int count;
  const _Dots({required this.activeIndex, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.only(right: 12),
          width: active ? 40 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: active ? KurdishHeritageColors.zer : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
