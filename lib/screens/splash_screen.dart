import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _duration = Duration(seconds: 6);
  static const _deepIndigo = Color(0xff05050d);
  static const _royalPurple = Color(0xff0e0e1d);
  static const _oceanBlue = Color(0xff0b1020);

  late final AnimationController _sequenceController;
  late final AnimationController _ambientController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _sequenceController = AnimationController(vsync: this, duration: _duration)
      ..forward();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _navigationTimer = Timer(_duration, _openHome);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _sequenceController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement<void, void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  double _stage(double value, double begin, double end) => Curves.easeOutCubic
      .transform(((value - begin) / (end - begin)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _sequenceController,
        builder: (context, _) => AnimatedBuilder(
          animation: _ambientController,
          builder: (context, _) {
            final progress = _sequenceController.value;
            final ambient = _ambientController.value;
            return LayoutBuilder(
              builder: (context, constraints) {
                final logoSize = math.min(
                  236.0,
                  math.max(164.0, constraints.maxHeight * 0.34),
                );
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1 + ambient * 0.35, -1),
                      end: Alignment(1, 1 - ambient * 0.3),
                      colors: [
                        Color.lerp(
                          _deepIndigo,
                          const Color(0xff101023),
                          ambient,
                        )!,
                        Color.lerp(
                          _royalPurple,
                          const Color(0xff181829),
                          ambient,
                        )!,
                        Color.lerp(
                          _oceanBlue,
                          const Color(0xff111c2a),
                          ambient,
                        )!,
                      ],
                      stops: const [0, 0.54, 1],
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _GlowOrb(
                        size: 250,
                        color: const Color(0xff9c73ff),
                        left: -95 + ambient * 22,
                        top: constraints.maxHeight * 0.12 + ambient * 16,
                      ),
                      _GlowOrb(
                        size: 220,
                        color: const Color(0xff3ca8ff),
                        right: -80 + ambient * 20,
                        bottom: constraints.maxHeight * 0.13 + ambient * 24,
                      ),
                      _GlowOrb(
                        size: 140,
                        color: const Color(0xffe082ff),
                        right: constraints.maxWidth * 0.16,
                        top: constraints.maxHeight * 0.19 - ambient * 18,
                      ),
                      _GlowOrb(
                        size: 190,
                        color: const Color(0xff22d3ee),
                        left: constraints.maxWidth * 0.2 - ambient * 20,
                        bottom: constraints.maxHeight * 0.32 + ambient * 18,
                      ),
                      SafeArea(
                        child: Column(
                          children: [
                            const Spacer(),
                            _QrEmblem(
                              size: logoSize,
                              ambient: ambient,
                              gridProgress: _stage(progress, 0.16, 0.55),
                              scanProgress: _stage(progress, 0.54, 0.73),
                              sequenceProgress: progress,
                            ),
                            SizedBox(height: logoSize * 0.13),
                            _AnimatedAppTitle(
                              progress: progress,
                              maxWidth: constraints.maxWidth - 32,
                            ),
                            const SizedBox(height: 8),
                            Opacity(
                              opacity: _stage(progress, 0.84, 0.94),
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  10 * (1 - _stage(progress, 0.84, 0.94)),
                                ),
                                child: Text(
                                  'Scan. Generate. Share.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.78),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            _ProgressTrack(progress: progress),
                            const SizedBox(height: 18),
                            Text(
                                  'v1.0',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 2200.ms, duration: 450.ms)
                                .slideY(begin: 0.2, duration: 450.ms),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final double size;
  final Color color;
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
      child: RepaintBoundary(
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 54, sigmaY: 54),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.22),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrEmblem extends StatelessWidget {
  const _QrEmblem({
    required this.size,
    required this.ambient,
    required this.gridProgress,
    required this.scanProgress,
    required this.sequenceProgress,
  });

  final double size;
  final double ambient;
  final double gridProgress;
  final double scanProgress;
  final double sequenceProgress;

  @override
  Widget build(BuildContext context) {
    final gridSize = size * 0.58;
    final ringScale = 0.93 + ambient * 0.15;
    final ringOpacity = 0.09 + ambient * 0.12;
    final scanIsVisible = sequenceProgress >= 0.54 && sequenceProgress <= 0.76;
    final scanOpacity = 1 - ((scanProgress - 0.78) / 0.22).clamp(0.0, 1.0);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: ringScale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: ringOpacity),
                  width: 1.2,
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: 1.12 - ambient * 0.1,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffa88cff)
                        .withValues(alpha: 0.13 + ambient * 0.12),
                    blurRadius: 38,
                    spreadRadius: 7,
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: size * 0.76,
                height: size * 0.76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.105),
                  borderRadius: BorderRadius.circular(size * 0.16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox.square(
                    dimension: gridSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CustomPaint(
                          size: Size.square(gridSize),
                          painter: _QrGridPainter(progress: gridProgress),
                        ),
                        if (scanIsVisible)
                          Positioned(
                            left: -gridSize * 0.08,
                            top: gridSize * scanProgress,
                            child: Opacity(
                              opacity: scanOpacity,
                              child: Container(
                                width: gridSize * 1.16,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xffd9f5ff),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff81e4ff)
                                          .withValues(alpha: 0.95),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
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
        ],
      ),
    );
  }
}

class _QrGridPainter extends CustomPainter {
  const _QrGridPainter({required this.progress});

  final double progress;

  static const _count = 11;

  bool _finderCell(int row, int column, int originRow, int originColumn) {
    final localRow = row - originRow;
    final localColumn = column - originColumn;
    if (localRow < 0 || localRow >= 5 || localColumn < 0 || localColumn >= 5) {
      return false;
    }
    return localRow == 0 ||
        localRow == 4 ||
        localColumn == 0 ||
        localColumn == 4 ||
        (localRow == 2 && localColumn == 2);
  }

  bool _isDark(int row, int column) {
    if (_finderCell(row, column, 0, 0) ||
        _finderCell(row, column, 0, 6) ||
        _finderCell(row, column, 6, 0)) {
      return true;
    }
    if ((row < 5 && (column < 5 || column >= 6)) || (row >= 6 && column < 5)) {
      return false;
    }
    return (row * 17 + column * 31 + row * column * 7) % 13 < 6;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.shortestSide / _count;
    final moduleSize = cellSize * 0.76;
    final inset = (cellSize - moduleSize) / 2;
    final paint = Paint()..color = const Color(0xfffbfaff);
    var index = 0;

    for (var row = 0; row < _count; row++) {
      for (var column = 0; column < _count; column++) {
        if (!_isDark(row, column)) continue;
        final cellProgress = ((progress - index * 0.0042) / 0.075).clamp(
          0.0,
          1.0,
        );
        index++;
        if (cellProgress <= 0) continue;

        final scale = Curves.easeOutBack.transform(cellProgress);
        final centerX = (column + 0.5) * cellSize;
        final centerY = (row + 0.5) * cellSize;
        final rect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: moduleSize * scale,
          height: moduleSize * scale,
        );
        paint.color = const Color(0xfffbfaff).withValues(alpha: cellProgress);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(inset * 0.7)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrGridPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _AnimatedAppTitle extends StatelessWidget {
  const _AnimatedAppTitle({required this.progress, required this.maxWidth});

  final double progress;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    const title = 'QR Studio';
    final fontSize = math.min(48.0, maxWidth * 0.105);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(title.length, (index) {
          final reveal = Curves.easeOutCubic.transform(
            ((progress - (0.69 + index * 0.016)) / 0.075).clamp(0.0, 1.0),
          );
          return Opacity(
            opacity: reveal,
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - reveal)),
              child: Text(
                title[index],
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 2,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffb8eaff).withValues(alpha: 0.85),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
