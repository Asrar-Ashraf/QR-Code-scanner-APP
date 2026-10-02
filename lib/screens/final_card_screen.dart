import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/animated_background.dart';
import '../widgets/qr_poster_card.dart';

enum _CardAction { download, share }

class FinalCardScreen extends StatefulWidget {
  const FinalCardScreen({
    required this.data,
    required this.userName,
    super.key,
  });

  final String data;
  final String userName;

  @override
  State<FinalCardScreen> createState() => _FinalCardScreenState();
}

class _FinalCardScreenState extends State<FinalCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  _CardAction? _activeAction;

  void _createNew(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<Uint8List> _captureCard() async {
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('The QR card is not ready yet.');
    }

    final image = await boundary.toImage(pixelRatio: 3);
    if (!mounted) {
      image.dispose();
      throw StateError('The QR card screen was closed.');
    }

    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted) {
        throw StateError('The QR card screen was closed.');
      }
      if (byteData == null) {
        throw StateError('The QR card image could not be created.');
      }
      return byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
    } finally {
      image.dispose();
    }
  }

  Future<void> _runAction(_CardAction action) async {
    setState(() => _activeAction = action);
    try {
      await HapticFeedback.selectionClick();
      if (!mounted) return;

      final bytes = await _captureCard();
      if (!mounted) return;

      if (action == _CardAction.download) {
        await Gal.putImageBytes(
          bytes,
          name: 'qr_card_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (!mounted) return;
        _showMessage('QR card saved to gallery');
      } else {
        final directory = await getTemporaryDirectory();
        if (!mounted) return;

        final file = File('${directory.path}/qr_card.png');
        await file.writeAsBytes(bytes, flush: true);
        if (!mounted) return;

        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'QR card'),
        );
        if (!mounted) return;
        _showMessage('QR card shared');
      }
    } catch (error) {
      if (!mounted) return;
      final errorText = error.toString().toLowerCase();
      final permissionDenied =
          action == _CardAction.download &&
          errorText.contains('permission') &&
          errorText.contains('denied');
      _showMessage(
        permissionDenied
            ? 'Please allow gallery access in Settings'
            : action == _CardAction.download
            ? 'Could not save your QR card. Please try again.'
            : 'Could not share your QR card. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _activeAction = null);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const foreground = Color(0xffeeecff);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your QR Card',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 46,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RepaintBoundary(
                          key: _cardKey,
                          child: QrPosterCard(
                            data: widget.data,
                            userName: widget.userName,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _activeAction == null
                                    ? () => _runAction(_CardAction.download)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: foreground,
                                  minimumSize: const Size.fromHeight(52),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                child: _actionButtonContent(
                                  context,
                                  _CardAction.download,
                                  Icons.download_rounded,
                                  'Download',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _activeAction == null
                                    ? () => _runAction(_CardAction.share)
                                    : null,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                child: _actionButtonContent(
                                  context,
                                  _CardAction.share,
                                  Icons.share_rounded,
                                  'Share',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: () => _createNew(context),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(
                              'Create New',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              foregroundColor: foreground,
                              backgroundColor: const Color(0xff181829),
                              shape: const StadiumBorder(),
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
      ),
    );
  }

  Widget _actionButtonContent(
    BuildContext context,
    _CardAction action,
    IconData icon,
    String label,
  ) {
    final isWorking = _activeAction == action;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isWorking)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: action == _CardAction.share
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
          )
        else
          Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
