import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/glass_panel.dart';
import 'final_card_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _scanLineController;
  bool _handled = false;
  String? _startError;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.trim().isEmpty) return;

    _handled = true;
    _handleDetection(value);
  }

  Future<void> _handleDetection(String value) async {
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    try {
      await _controller.stop();
    } catch (_) {
      if (!mounted) return;
    }
    if (!mounted) return;

    final userName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _UserNameSheet(),
    );
    if (!mounted) return;

    if (userName == null || userName.trim().isEmpty) {
      _handled = false;
      await _resumeCamera();
      if (!mounted) return;
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            FinalCardScreen(data: value, userName: userName.trim()),
      ),
    );
    if (!mounted) return;

    _handled = false;
    await _resumeCamera();
    if (!mounted) return;
  }

  Future<void> _resumeCamera() async {
    if (!mounted) return;
    setState(() => _startError = null);
    try {
      await _controller.start();
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _startError = 'We could not start the camera.');
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _startError = 'The flashlight is unavailable.');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller.switchCamera();
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _startError = 'We could not switch cameras.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan QR'),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) => IconButton(
              tooltip: state.torchState == TorchState.on
                  ? 'Turn flashlight off'
                  : 'Turn flashlight on',
              onPressed: _toggleTorch,
              icon: Icon(
                state.torchState == TorchState.on
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Switch camera',
            onPressed: _switchCamera,
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<MobileScannerState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          final error = _startError;
          if (error != null || state.error != null) {
            final permissionDenied =
                state.error?.errorCode ==
                MobileScannerErrorCode.permissionDenied;
            return _CameraErrorView(
              message:
                  error ??
                  (permissionDenied
                      ? 'Camera access is needed to scan QR codes. Allow camera access and try again.'
                      : 'The camera could not be opened. Check camera access and try again.'),
              onRetry: _resumeCamera,
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final frameSize = math.min(constraints.maxWidth * 0.7, 300.0);
              final frameRect = Rect.fromCenter(
                center: Offset(
                  constraints.maxWidth / 2,
                  constraints.maxHeight * 0.48,
                ),
                width: frameSize,
                height: frameSize,
              );

              return Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(controller: _controller, onDetect: _onDetect),
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _ScannerOverlayPainter(frameRect: frameRect),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _scanLineController,
                    builder: (context, _) => Positioned(
                      left: frameRect.left + 14,
                      top:
                          frameRect.top +
                          12 +
                          (frameSize - 24) * _scanLineController.value,
                      width: frameSize - 28,
                      child: IgnorePointer(
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xffbcb2ff),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xff7c6cff),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Color(0xcc7c6cff),
                                blurRadius: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: frameRect.bottom + 22,
                    left: 20,
                    right: 20,
                    child: GlassPanel(
                      borderRadius: 30,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        'Place the QR code inside the frame',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({required this.frameRect});

  final Rect frameRect;

  @override
  void paint(Canvas canvas, Size size) {
    final screenPath = Path()..addRect(Offset.zero & size);
    final framePath = Path()
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(26)));
    final overlay = Path.combine(
      PathOperation.difference,
      screenPath,
      framePath,
    );
    canvas.drawPath(
      overlay,
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(26)),
      Paint()
        ..color = const Color(0xff7c6cff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      oldDelegate.frameRect != frameRect;
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.no_photography_outlined,
                  color: Color(0xffaaa0ff),
                  size: 54,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Camera unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserNameSheet extends StatefulWidget {
  const _UserNameSheet();

  @override
  State<_UserNameSheet> createState() => _UserNameSheetState();
}

class _UserNameSheetState extends State<_UserNameSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name to continue.');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: GlassPanel(
            borderRadius: 32,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'QR detected',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add a name to personalize your QR card.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _continue(),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    errorText: _error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _continue,
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
