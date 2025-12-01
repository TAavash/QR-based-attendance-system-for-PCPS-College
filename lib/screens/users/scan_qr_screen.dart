import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../endpoints/session_api.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;

    ctrl.scannedDataStream.listen((scanData) async {
      if (scanned) return;
      scanned = true;

      final raw = scanData.code;
      final code = raw?.trim();
      await controller?.pauseCamera();
      print(code);

      if (code == null || code.isEmpty) {
        _showMessage("Invalid or empty QR code");
        scanned = false;
        await controller?.resumeCamera();
        return;
      }

      try {
        final result = await SessionAPI.markAttendance(code);
        final msg = result["message"] ?? result["error"] ?? "Unknown response";

        _showMessage(msg);
      } catch (e) {
        _showMessage("Failed: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Scan QR"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: const Color(0xFF6750A4),
                borderRadius: 12,
                borderLength: 45,
                borderWidth: 8,
                cutOutSize: MediaQuery.of(context).size.width * 0.78,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black87,
              alignment: Alignment.center,
              child: const Text(
                "Align the QR inside the frame",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ),
          )
        ],
      ),
    );
  }
}
