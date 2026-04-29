import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual density for [ImmersiveCityCard].
enum ImmersiveCityCardLayout {
  /// Original tall portrait card (~210×440).
  standard,

  /// Wider, shorter rectangle for home regions strip (~286×268).
  compact,
}

/// Data for a single [ImmersiveCityCard].
class ImmersiveCityCardData {
  const ImmersiveCityCardData({
    required this.cityName,
    required this.priceDisplay,
    required this.shortDescription,
    required this.tags,
    required this.ctaLabel,
    this.imageAssetPath,
    this.imageUrl,
    this.activeDotIndex = 0,
    this.cityRouteId,
  }) : assert(
          imageAssetPath != null || imageUrl != null,
          'Provide imageAssetPath or imageUrl',
        );

  final String cityName;
  final String priceDisplay;
  final String shortDescription;
  final List<String> tags;
  final String ctaLabel;
  final String? imageAssetPath;
  final String? imageUrl;

  /// Path segment for `context.go('/city/:id')` (e.g. `erbil`).
  final String? cityRouteId;

  /// Which dot (0–2) is highlighted for the static photo strip.
  final int activeDotIndex;
}

/// Immersive travel card: photo hero, bottom gradient, Playfair + Inter, CTA.
class ImmersiveCityCard extends StatefulWidget {
  const ImmersiveCityCard({
    super.key,
    required this.data,
    required this.onTap,
    this.width = 210,
    this.height = 440,
    this.layout = ImmersiveCityCardLayout.standard,
  });

  final ImmersiveCityCardData data;
  final VoidCallback onTap;
  final double width;
  final double height;
  final ImmersiveCityCardLayout layout;

  static const Color _stageBg = Color(0xFFE8EAF0);

  static Color get stageBackgroundColor => _stageBg;

  @override
  State<ImmersiveCityCard> createState() => _ImmersiveCityCardState();
}

class _ImmersiveCityCardState extends State<ImmersiveCityCard> {
  bool _hover = false;

  double get _w =>
      widget.layout == ImmersiveCityCardLayout.compact ? 286 : widget.width;

  double get _h =>
      widget.layout == ImmersiveCityCardLayout.compact ? 268 : widget.height;

  double get _radius =>
      widget.layout == ImmersiveCityCardLayout.compact ? 20.0 : 22.0;

  double get _gradientFraction =>
      widget.layout == ImmersiveCityCardLayout.compact ? 0.55 : 0.65;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final tagCap = widget.layout == ImmersiveCityCardLayout.compact ? 2 : 3;
    final tags = d.tags.take(tagCap).toList();
    final descMaxLines =
        widget.layout == ImmersiveCityCardLayout.compact ? 2 : 3;
    final titleSize =
        widget.layout == ImmersiveCityCardLayout.compact ? 17.0 : 18.0;
    final bodySize =
        widget.layout == ImmersiveCityCardLayout.compact ? 10.5 : 11.0;
    final shadowBlur =
        widget.layout == ImmersiveCityCardLayout.compact ? 28.0 : 50.0;
    final shadowY =
        widget.layout == ImmersiveCityCardLayout.compact ? 14.0 : 20.0;

    Widget imageLayer;
    if (d.imageUrl != null && d.imageUrl!.isNotEmpty) {
      imageLayer = Image.network(
        d.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0a0f1e)),
      );
    } else {
      imageLayer = Image.asset(
        d.imageAssetPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    final insetH =
        widget.layout == ImmersiveCityCardLayout.compact ? 12.0 : 14.0;
    final insetV =
        widget.layout == ImmersiveCityCardLayout.compact ? 12.0 : 14.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        offset: Offset(0, _hover ? -5.0 / _h : 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(_radius),
            child: Ink(
              width: _w,
              height: _h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x38000000),
                    blurRadius: shadowBlur,
                    offset: Offset(0, shadowY),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: imageLayer),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: _h * _gradientFraction,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xEB0a0f1e),
                              Color(0x800a0f1e),
                              Color(0x000a0f1e),
                            ],
                            stops: [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: insetH,
                      right: insetH,
                      bottom: insetV,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dots(d.activeDotIndex.clamp(0, 2)),
                          SizedBox(
                              height: widget.layout ==
                                      ImmersiveCityCardLayout.compact
                                  ? 8
                                  : 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  d.cityName,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _priceBadge(
                                d.priceDisplay,
                                compact: widget.layout ==
                                    ImmersiveCityCardLayout.compact,
                              ),
                            ],
                          ),
                          SizedBox(
                              height: widget.layout ==
                                      ImmersiveCityCardLayout.compact
                                  ? 6
                                  : 8),
                          Text(
                            d.shortDescription,
                            textAlign: TextAlign.left,
                            maxLines: descMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: bodySize,
                              height: 1.45,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.70),
                            ),
                          ),
                          SizedBox(
                              height: widget.layout ==
                                      ImmersiveCityCardLayout.compact
                                  ? 8
                                  : 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tags
                                .map(
                                  (t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.20),
                                      ),
                                    ),
                                    child: Text(
                                      t,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white
                                            .withValues(alpha: 0.90),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          SizedBox(
                              height: widget.layout ==
                                      ImmersiveCityCardLayout.compact
                                  ? 10
                                  : 14),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: widget.layout ==
                                        ImmersiveCityCardLayout.compact
                                    ? 8
                                    : 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  d.ctaLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: widget.layout ==
                                            ImmersiveCityCardLayout.compact
                                        ? 12.5
                                        : 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1a1a2e),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dots(int active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final on = i == active;
        return Padding(
          padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  on ? Colors.white : Colors.white.withValues(alpha: 0.35),
            ),
          ),
        );
      }),
    );
  }

  Widget _priceBadge(String price, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        price,
        style: GoogleFonts.inter(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Light gray “stage” that wraps a horizontal row of [ImmersiveCityCard]s.
class ImmersiveCityCardStage extends StatelessWidget {
  const ImmersiveCityCardStage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: padding,
      decoration: BoxDecoration(
        color: ImmersiveCityCard.stageBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _spaced(children, 18),
        ),
      ),
    );
  }

  List<Widget> _spaced(List<Widget> items, double gap) {
    if (items.isEmpty) return [];
    final out = <Widget>[items.first];
    for (var i = 1; i < items.length; i++) {
      out.add(SizedBox(width: gap));
      out.add(items[i]);
    }
    return out;
  }
}
