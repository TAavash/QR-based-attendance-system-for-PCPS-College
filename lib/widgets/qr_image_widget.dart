import 'dart:convert';
import 'package:flutter/material.dart';

class QRImageFromBase64 extends StatelessWidget {
  final String dataUri;
  final double size;

  const QRImageFromBase64({
    super.key,
    required this.dataUri,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    try {
      // Remove data:image/png;base64,
      final base64Data = dataUri.split(",").last.trim();
      final bytes = base64Decode(base64Data);

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Image.memory(bytes, fit: BoxFit.contain),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text("Invalid QR Image\n$e",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red)),
      );
    }
  }
}
