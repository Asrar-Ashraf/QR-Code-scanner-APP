import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/animated_background.dart';
import '../widgets/glass_panel.dart';
import 'final_card_screen.dart';

class TextLinkScreen extends StatefulWidget {
  const TextLinkScreen({super.key});

  @override
  State<TextLinkScreen> createState() => _TextLinkScreenState();
}

class _TextLinkScreenState extends State<TextLinkScreen>
    with TickerProviderStateMixin {
  final _dataController = TextEditingController();
  final _nameController = TextEditingController();
  late final AnimationController _shakeController;
  late final AnimationController _buttonGlowController;
  String? _dataError;
  String? _nameError;
  bool _isGenerating = false;
  bool _hasGenerated = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _buttonGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _buttonGlowController.dispose();
    _dataController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _validate() {
    final data = _dataController.text.trim();
    final userName = _nameController.text.trim();
    setState(() {
      _dataError = data.isEmpty
          ? 'Add some text or a link to continue.'
          : data.length > 800
          ? 'Keep your text under 800 characters.'
          : null;
      _nameError = userName.isEmpty
          ? 'Please enter a name for your card.'
          : null;
    });
    return _dataError == null && _nameError == null;
  }

  Future<void> _generate() async {
    HapticFeedback.lightImpact();
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    if (!_validate()) {
      _shakeController.forward(from: 0);
      return;
    }

    setState(() {
      _isGenerating = true;
      _hasGenerated = false;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 560));
      if (!mounted) return;
      setState(() => _hasGenerated = true);
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;

      _buttonGlowController.stop();
      await Navigator.of(context).push<void>(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FinalCardScreen(
                data: _dataController.text.trim(),
                userName: _nameController.text.trim(),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _hasGenerated = false;
        });
        _buttonGlowController.repeat(reverse: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const foreground = Color(0xffeeecff);
    const secondary = Color(0xffa9a6c8);
    const inputFill = Color(0x0dffffff);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 10),
                    child: Row(
                      children: [
                        _GlassBackButton(
                          foreground: foreground,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            'Text / Link',
                            style: GoogleFonts.poppins(
                              color: foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        Hero(
                          tag: 'home-link-icon',
                          child: _DestinationIcon(
                            icon: Icons.link_rounded,
                            colors: const [
                              Color(0xff7c6cff),
                              Color(0xff22d3ee),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                      child: AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          final progress = _shakeController.value;
                          final offset =
                              math.sin(progress * math.pi * 8) *
                              (1 - progress) *
                              7;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          );
                        },
                        child:
                            GlassPanel(
                                  padding: const EdgeInsets.all(22),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ShaderMask(
                                                  shaderCallback: (bounds) =>
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xffa99fff),
                                                          Color(0xffe8a8ef),
                                                          Color(0xff73e5f4),
                                                        ],
                                                      ).createShader(bounds),
                                                  child: Text(
                                                    'Create your QR',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 27,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 1.18,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Turn a message or link into a card worth sharing.',
                                                  style: GoogleFonts.inter(
                                                    color: secondary,
                                                    fontSize: 13,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          _QrStatusChip(
                                            hasText:
                                                _dataController.text.isNotEmpty,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      TextField(
                                        controller: _dataController,
                                        minLines: 2,
                                        maxLines: 4,
                                        maxLength: 800,
                                        maxLengthEnforcement:
                                            MaxLengthEnforcement.none,
                                        keyboardType: TextInputType.multiline,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        onChanged: (_) {
                                          setState(() {
                                            if (_dataError != null) {
                                              _dataError = null;
                                            }
                                          });
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Text or Link',
                                          hintText:
                                              'Write a message or paste a URL',
                                          prefixIcon: const Icon(
                                            Icons.link_rounded,
                                          ),
                                          errorText: _dataError,
                                          counterText: '',
                                          filled: true,
                                          fillColor: inputFill,
                                          alignLabelWithHint: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 17,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xff7c6cff),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '${_dataController.text.length} / 800',
                                          style: GoogleFonts.inter(
                                            color: secondary.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      TextField(
                                        controller: _nameController,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (_) {
                                          if (_nameError != null) {
                                            setState(() => _nameError = null);
                                          }
                                        },
                                        onSubmitted: (_) => _generate(),
                                        decoration: InputDecoration(
                                          labelText: 'User Name',
                                          hintText: 'How should it appear?',
                                          prefixIcon: const Icon(
                                            Icons.person_outline_rounded,
                                          ),
                                          errorText: _nameError,
                                          filled: true,
                                          fillColor: inputFill,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 17,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xff7c6cff),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 22),
                                      AnimatedBuilder(
                                        animation: _buttonGlowController,
                                        builder: (context, child) => Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xff7c6cff)
                                                    .withValues(
                                                      alpha:
                                                          0.2 +
                                                          _buttonGlowController
                                                                  .value *
                                                              0.16,
                                                    ),
                                                blurRadius:
                                                    20 +
                                                    _buttonGlowController
                                                            .value *
                                                        12,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: child,
                                        ),
                                        child: Align(
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 360,
                                            ),
                                            curve: Curves.easeOutBack,
                                            width: _isGenerating
                                                ? 54
                                                : double.infinity,
                                            height: 54,
                                            child: FilledButton(
                                              onPressed: _isGenerating
                                                  ? null
                                                  : _generate,
                                              style: FilledButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                disabledBackgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: const StadiumBorder(),
                                                minimumSize: Size(
                                                  _isGenerating ? 0 : 64,
                                                  54,
                                                ),
                                                padding: _isGenerating
                                                    ? EdgeInsets.zero
                                                    : null,
                                                textStyle: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              child: Ink(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xff7c6cff),
                                                      Color(0xff4b8ff7),
                                                      Color(0xff22b8d1),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(30),
                                                      ),
                                                ),
                                                child: Center(
                                                  child: AnimatedSwitcher(
                                                    duration: const Duration(
                                                      milliseconds: 220,
                                                    ),
                                                    switchInCurve:
                                                        Curves.easeOutBack,
                                                    child: _isGenerating
                                                        ? _hasGenerated
                                                              ? const Icon(
                                                                  Icons
                                                                      .check_rounded,
                                                                  key: ValueKey(
                                                                    'complete',
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                )
                                                              : const SizedBox.square(
                                                                  key: ValueKey(
                                                                    'loading',
                                                                  ),
                                                                  dimension: 21,
                                                                  child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2.2,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                )
                                                        : const Row(
                                                            key: ValueKey(
                                                              'ready',
                                                            ),
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .qr_code_2_rounded,
                                                              ),
                                                              SizedBox(
                                                                width: 9,
                                                              ),
                                                              Text('Generate'),
                                                            ],
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(
                                  begin: 0.08,
                                  duration: 560.ms,
                                  curve: Curves.easeOutBack,
                                ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.foreground, required this.onPressed});

  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: IconButton(
            onPressed: onPressed,
            tooltip: 'Back',
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 17),
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class _QrStatusChip extends StatelessWidget {
  const _QrStatusChip({required this.hasText});

  final bool hasText;

  @override
  Widget build(BuildContext context) {
    const foreground = Color(0xffeeecff);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey(hasText),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasText ? Icons.qr_code_2_rounded : Icons.edit_note_rounded,
              size: 17,
              color: foreground,
            ),
            const SizedBox(width: 5),
            Text(
              hasText ? 'QR ready' : 'Your QR',
              style: GoogleFonts.inter(
                color: foreground,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationIcon extends StatelessWidget {
  const _DestinationIcon({required this.icon, required this.colors});

  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: colors),
      ),
      child: Icon(icon, color: Colors.white, size: 21),
    );
  }
}
