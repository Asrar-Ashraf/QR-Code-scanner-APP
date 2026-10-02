import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/animated_background.dart';
import '../widgets/option_card.dart';
import 'quick_scan_screen.dart';
import 'scanner_screen.dart';
import 'text_link_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 480),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.035),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xff4d476d);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 50),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 46,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 0),
                        Text(
                          'GOOD TO SEE YOU',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ).animate().fadeIn(duration: 430.ms).slideY(begin: 0.1),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xffa99fff),
                                        Color(0xffe8a8ef),
                                        Color(0xff73e5f4),
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  'QR Studio',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipOval(
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: 18,
                                  sigmaY: 18,
                                ),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xff7c6cff)
                                            .withValues(alpha: 0.74),
                                        const Color(0xff22d3ee)
                                            .withValues(alpha: 0.38),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.42,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xff7c6cff)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 23,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 90.ms).slideY(begin: 0.1),
                        const SizedBox(height: 10),
                        Text(
                          'Everything you need to scan or create.',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ).animate().fadeIn(delay: 150.ms),
                        const SizedBox(height: 28),
                        OptionCard(
                              isHero: true,
                              heroTag: 'home-open-icon',
                              icon: Icons.open_in_new_rounded,
                              title: 'Scan & Open',
                              subtitle: 'Open a link, call a number, or read a message.',
                              gradient: const [
                                Color(0xff7c6cff),
                                Color(0xff22d3ee),
                              ],
                              onTap: () =>
                                  _openScreen(context, const QuickScanScreen()),
                            )
                            .animate()
                            .fadeIn(delay: 220.ms, duration: 520.ms)
                            .slideY(begin: 0.12, duration: 650.ms)
                            .scale(begin: const Offset(0.96, 0.96)),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: constraints.maxWidth < 360
                                    ? 0.74
                                    : 0.9,
                                child:
                                    OptionCard(
                                          isCompact: true,
                                          heroTag: 'home-scan-icon',
                                          icon: Icons.qr_code_scanner_rounded,
                                          title: 'Scan QR Code',
                                          subtitle: 'Create a card from any QR',
                                          gradient: const [
                                            Color(0xfff472b6),
                                            Color(0xff9574ff),
                                          ],
                                          onTap: () => _openScreen(
                                            context,
                                            const ScannerScreen(),
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(delay: 350.ms, duration: 500.ms)
                                        .slideY(begin: 0.16, duration: 600.ms)
                                        .scale(begin: const Offset(0.96, 0.96)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: constraints.maxWidth < 360
                                    ? 0.74
                                    : 0.9,
                                child:
                                    OptionCard(
                                          isCompact: true,
                                          heroTag: 'home-link-icon',
                                          icon: Icons.link_rounded,
                                          title: 'Text / Link',
                                          subtitle:
                                              'Turn anything into a QR card',
                                          gradient: const [
                                            Color(0xff22d3ee),
                                            Color(0xff5279e9),
                                          ],
                                          onTap: () => _openScreen(
                                            context,
                                            const TextLinkScreen(),
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(delay: 460.ms, duration: 500.ms)
                                        .slideY(begin: 0.16, duration: 600.ms)
                                        .scale(begin: const Offset(0.96, 0.96)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: Text(
                            'Fast. Simple. Secure.',
                            style: GoogleFonts.inter(
                              color: secondary.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).animate().fadeIn(delay: 650.ms),
                        const SizedBox(height: 8),
                      ],
                    ),
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
