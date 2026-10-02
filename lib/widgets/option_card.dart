import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionCard extends StatefulWidget {
  const OptionCard({
    required this.heroTag,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.isHero = false,
    this.isCompact = false,
    super.key,
  });

  final String heroTag;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool isHero;
  final bool isCompact;

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  Widget _icon(double size) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, math.sin(_glowController.value * math.pi) * -3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isHero ? 23 : 20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(
                  alpha: 0.2 + _glowController.value * 0.22,
                ),
                blurRadius: 22 + _glowController.value * 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
      child: Hero(
        tag: widget.heroTag,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isHero ? 23 : 20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
          ),
          child: Icon(widget.icon, color: Colors.white, size: size * 0.48),
        ),
      ),
    );
  }

  Widget _cardContent(Color foreground, Color secondary) {
    if (widget.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _icon(54),
              _ArrowBadge(
                color: foreground.withValues(alpha: 0.14),
                iconColor: foreground,
              ),
            ],
          ),
          const Spacer(),
          Text(
            widget.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: foreground,
              fontSize: 17,
              height: 1.15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            widget.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: secondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _icon(68),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  color: foreground,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: secondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _ArrowBadge(
          color: foreground.withValues(alpha: 0.12),
          iconColor: foreground,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xffeeecff);
    const subtitleColor = Color(0xffd0cdea);
    final tileStart = Color.lerp(
      widget.gradient.first,
      const Color(0xff101023),
      0.72,
    )!;
    final tileEnd = Color.lerp(
      widget.gradient.last,
      const Color(0xff080817),
      0.84,
    )!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: _onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.isHero ? 34 : 30),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: widget.isHero ? 190 : 0,
                  maxHeight: widget.isHero ? 210 : double.infinity,
                ),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.isHero ? 34 : 30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.01),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.16),
                      blurRadius: 38,
                      offset: const Offset(0, 18),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [tileStart, tileEnd],
                    ),
                    borderRadius: BorderRadius.circular(
                      widget.isHero ? 33 : 29,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        right: widget.isHero ? -48 : -58,
                        top: widget.isHero ? -86 : -70,
                        child: IgnorePointer(
                          child: Container(
                            width: widget.isHero ? 225 : 155,
                            height: widget.isHero ? 225 : 155,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  widget.gradient.last.withValues(alpha: 0.2),
                                  widget.gradient.first.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(widget.isCompact ? 12 : 22),
                        child: _cardContent(titleColor, subtitleColor),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, _) {
                              final phase = _glowController.value;
                              final visible = phase > 0.74 && phase < 0.94;
                              final progress = ((phase - 0.74) / 0.2).clamp(
                                0.0,
                                1.0,
                              );
                              return visible
                                  ? Align(
                                      alignment: Alignment(
                                        -1 + progress * 2,
                                        0,
                                      ),
                                      child: FractionallySizedBox(
                                        widthFactor: 0.4,
                                        heightFactor: 1,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withValues(
                                                  alpha: 0,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: 0.075,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: 0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.22),
                                Colors.white.withValues(alpha: 0.02),
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
          ),
        ),
      ),
    );
  }
}

class _ArrowBadge extends StatelessWidget {
  const _ArrowBadge({required this.color, required this.iconColor});

  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Icon(Icons.arrow_outward_rounded, size: 15, color: iconColor),
  );
}
