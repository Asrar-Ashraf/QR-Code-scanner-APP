import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({required this.child, super.key});

  final Widget child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColors = [Color(0xff05050d)];
    const glowColors = [
      Color(0xff7c6cff),
      Color(0xff22d3ee),
      Color(0xfff472b6),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final phase = _controller.value * math.pi * 2;
              return LayoutBuilder(
                builder: (context, constraints) => Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(color: backgroundColors.first),
                    ),
                    _FloatingGlow(
                      size: 340,
                      color: glowColors[0],
                      left: constraints.maxWidth * 0.02 + math.sin(phase) * 28,
                      top: constraints.maxHeight * 0.02 + math.cos(phase) * 20,
                      opacity: 0.24,
                    ),
                    _FloatingGlow(
                      size: 310,
                      color: glowColors[1],
                      right: constraints.maxWidth * 0.01 + math.cos(phase) * 24,
                      bottom:
                          constraints.maxHeight * 0.02 + math.sin(phase) * 25,
                      opacity: 0.22,
                    ),
                    _FloatingGlow(
                      size: 230,
                      color: glowColors[2],
                      right: constraints.maxWidth * 0.18 - math.sin(phase) * 20,
                      top: constraints.maxHeight * 0.43 + math.cos(phase) * 24,
                      opacity: 0.2,
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _GrainPainter(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.025);
    final random = math.Random(42);
    for (var index = 0; index < 420; index++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 0.65 + 0.15,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FloatingGlow extends StatelessWidget {
  const _FloatingGlow({
    required this.size,
    required this.color,
    required this.opacity,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final double size;
  final Color color;
  final double opacity;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 54, sigmaY: 54),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
