import 'package:flutter/material.dart';
import '../../widgets/qr_generator.dart';

class GenerateQRScreen extends StatelessWidget {
  final String qrToken;

  const GenerateQRScreen({super.key, required this.qrToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generated QR Code")),
      body: Center(
        child: QRGenerator(data: qrToken),
      ),
    );
  }
}
