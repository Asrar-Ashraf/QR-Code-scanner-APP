import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPosterCard extends StatelessWidget {
  const QrPosterCard({required this.data, required this.userName, super.key});

  final String data;
  final String userName;

  static String _formattedDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final qrSize = math.min(224.0, constraints.maxWidth - 72);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xffc9c2ff), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff7c6cff).withValues(alpha: 0.22),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    color: Color(0xff7057d8),
                    size: 21,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'QR Studio',
                    style: GoogleFonts.poppins(
                      color: const Color(0xff302652),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              QrImageView(
                data: data,
                size: qrSize,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
                errorStateBuilder: (context, error) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Text too long for QR',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xff635d72)),
                  ),
                ),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xff171321),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xff171321),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Scan to connect',
                style: GoogleFonts.poppins(
                  color: const Color(0xff635d72),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                userName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: const Color(0xff201a32),
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _formattedDate(DateTime.now()),
                style: GoogleFonts.poppins(
                  color: const Color(0xff898394),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
