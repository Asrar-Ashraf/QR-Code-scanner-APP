import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/animated_background.dart';
import '../widgets/glass_panel.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final _controller = TextEditingController();
  final _qrKey = GlobalKey();
  String? _data;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    final text = _controller.text.trim();
    FocusScope.of(context).unfocus();
    setState(() {
      if (text.isEmpty) {
        _error = 'Please enter some text or a URL';
        _data = null;
      } else {
        _error = null;
        _data = text;
      }
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _data = null;
      _error = null;
    });
  }

  Future<Uint8List> _capturePng() async {
    final boundary =
        _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _save() async {
    try {
      final png = await _capturePng();
      await Gal.putImageBytes(
        png,
        name: 'qr_${DateTime.now().millisecondsSinceEpoch}',
      );
      _toast('QR code saved to gallery');
    } catch (e) {
      _toast('Could not save: $e');
    }
  }

  Future<void> _share() async {
    try {
      final png = await _capturePng();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_code.png');
      await file.writeAsBytes(png);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'My QR code'),
      );
    } catch (e) {
      _toast('Could not share: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Generator'), centerTitle: true),
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassPanel(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        keyboardType: TextInputType.url,
                        onSubmitted: (_) => _generate(),
                        decoration: InputDecoration(
                          labelText: 'Text or URL',
                          hintText: 'https://example.com',
                          errorText: _error,
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.link),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clear,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Generate QR Code'),
                    ),
                    const SizedBox(height: 28),
                    if (_data != null) ...[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final size = math.min(
                            constraints.maxWidth - 32,
                            280.0,
                          );
                          return Center(
                            child: RepaintBoundary(
                              key: _qrKey,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(16),
                                child: QrImageView(
                                  data: _data!,
                                  size: size,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.download),
                              label: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _share,
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Icon(
                        Icons.qr_code_2,
                        size: 120,
                        color: Theme.of(context).colorScheme.outlineVariant,
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
}
