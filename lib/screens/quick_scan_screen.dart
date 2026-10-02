import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/glass_panel.dart';

class QuickScanScreen extends StatefulWidget {
  const QuickScanScreen({super.key});

  @override
  State<QuickScanScreen> createState() => _QuickScanScreenState();
}

class _QuickScanScreenState extends State<QuickScanScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  late final AnimationController _scanAnimationController;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.trim().isEmpty) return;

    _handled = true;
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    await _controller.stop();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildResultSheet(context, _classify(value)),
    );
    if (!mounted) return;

    _handled = false;
    await _controller.start();
    if (!mounted) return;
  }

  _ScanResult _classify(String scannedValue) {
    final value = scannedValue.trim();
    final lowerValue = value.toLowerCase();

    if (lowerValue.startsWith('http://') ||
        lowerValue.startsWith('https://') ||
        lowerValue.startsWith('www.')) {
      final link = lowerValue.startsWith('www.') ? 'https://$value' : value;
      return _ScanResult(
        value: value,
        kind: _ResultKind.link,
        actionValue: link,
      );
    }

    final emailCandidate = lowerValue.startsWith('mailto:')
        ? value.substring(7).trim()
        : value;
    if (_isEmail(emailCandidate)) {
      return _ScanResult(
        value: emailCandidate,
        kind: _ResultKind.email,
        actionValue: emailCandidate,
      );
    }

    final phoneCandidate = lowerValue.startsWith('tel:')
        ? value.substring(4).trim()
        : value;
    final digits = phoneCandidate.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 7 &&
        RegExp(r'^\+?[\d\s().-]+$').hasMatch(phoneCandidate)) {
      return _ScanResult(
        value: phoneCandidate,
        kind: _ResultKind.phone,
        actionValue: phoneCandidate.replaceAll(RegExp(r'[^+\d]'), ''),
      );
    }

    return _ScanResult(value: value, kind: _ResultKind.text);
  }

  bool _isEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);

  Future<void> _openResult(_ScanResult result) async {
    final uri = switch (result.kind) {
      _ResultKind.link => Uri.tryParse(result.actionValue!),
      _ResultKind.phone => Uri(scheme: 'tel', path: result.actionValue),
      _ResultKind.email => Uri(scheme: 'mailto', path: result.actionValue),
      _ResultKind.text => null,
    };
    if (uri == null) return;

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!opened) _showMessage('Could not open this');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not open this');
    }
  }

  Future<void> _copyResult(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    _showMessage('Copied');
  }

  Future<void> _retryCamera() async {
    try {
      await _controller.start();
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not start the camera. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: _controller,
      builder: (context, state, _) {
        if (state.error != null) return _buildErrorView(state.error!);
        return _buildScannerView(context, state);
      },
    );
  }

  Widget _buildErrorView(MobileScannerException error) {
    final permissionDenied =
        error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scan & Open'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                permissionDenied
                    ? Icons.no_photography_outlined
                    : Icons.videocam_off_outlined,
                color: const Color(0xffb8b1ff),
                size: 54,
              ),
              const SizedBox(height: 20),
              Text(
                permissionDenied
                    ? 'Camera access is needed to scan QR codes. Please allow access in Settings.'
                    : 'The camera could not be started. Check your camera and try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _retryCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView(BuildContext context, MobileScannerState state) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan & Open'),
        actions: [
          IconButton(
            tooltip: 'Toggle flashlight',
            onPressed: _controller.toggleTorch,
            icon: Icon(
              state.torchState == TorchState.on
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Switch camera',
            onPressed: _controller.switchCamera,
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          LayoutBuilder(
            builder: (context, constraints) {
              final frameSize = math.min(constraints.maxWidth * 0.7, 300.0);
              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _ScannerShadePainter(frameSize: frameSize),
                  ),
                  Center(
                    child: SizedBox.square(
                      dimension: frameSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xff7c6cff),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff7c6cff)
                                  .withValues(alpha: 0.38),
                              blurRadius: 22,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: AnimatedBuilder(
                            animation: _scanAnimationController,
                            builder: (context, _) => Align(
                              alignment: Alignment(
                                0,
                                -0.88 + _scanAnimationController.value * 1.76,
                              ),
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xffbdb5ff),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff7c6cff)
                                          .withValues(alpha: 0.9),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    top: constraints.maxHeight / 2 + frameSize / 2 + 28,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultSheet(BuildContext context, _ScanResult result) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tint = colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);
    final icon = switch (result.kind) {
      _ResultKind.link => Icons.link_rounded,
      _ResultKind.phone => Icons.phone_rounded,
      _ResultKind.email => Icons.email_outlined,
      _ResultKind.text => Icons.text_fields_rounded,
    };
    final hint = switch (result.kind) {
      _ResultKind.link => 'Tap to open link',
      _ResultKind.phone => 'Tap to call',
      _ResultKind.email => 'Tap to send email',
      _ResultKind.text => 'Scanned text',
    };
    final isActionable = result.kind != _ResultKind.text;

    return GlassPanel(
      borderRadius: 32,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Scan result',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: tint,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: isActionable ? () => _openResult(result) : null,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                result.value,
                                maxLines: 4,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: result.kind == _ResultKind.link
                                      ? colorScheme.secondary
                                      : colorScheme.onSurface,
                                  decoration: result.kind == _ResultKind.link
                                      ? TextDecoration.underline
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hint,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isActionable) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyResult(result.value),
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy'),
                    ),
                  ),
                  if (isActionable) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _openResult(result),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Open'),
                      ),
                    ),
                  ],
                ],
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Scan Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerShadePainter extends CustomPainter {
  const _ScannerShadePainter({required this.frameSize});

  final double frameSize;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: frameSize,
        height: frameSize,
      ),
      const Radius.circular(28),
    );
    final shade = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(frame);
    canvas.drawPath(
      shade,
      Paint()..color = Colors.black.withValues(alpha: 0.58),
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerShadePainter oldDelegate) =>
      frameSize != oldDelegate.frameSize;
}

enum _ResultKind { link, phone, email, text }

class _ScanResult {
  const _ScanResult({
    required this.value,
    required this.kind,
    this.actionValue,
  });

  final String value;
  final _ResultKind kind;
  final String? actionValue;
}
