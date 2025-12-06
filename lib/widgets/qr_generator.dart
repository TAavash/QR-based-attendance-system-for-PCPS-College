import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator extends StatelessWidget {
  final String data;
  final double size;

  const QRGenerator({
    super.key,
    required this.data,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.white,
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        gapless: true,
      ),
    );
  }
}
