import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;

    ctrl.scannedDataStream.listen((scanData) {
      if (scannedData == null) {
        scannedData = scanData.code;

        // Stop scanning
        controller?.pauseCamera();

        // Return scanned text to previous screen
        Navigator.pop(context, scannedData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
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
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: MediaQuery.of(context).size.width * 0.75,
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black12,
              alignment: Alignment.center,
              child: Text(
                scannedData == null
                    ? "Point camera at QR code"
                    : "Scanned: $scannedData",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}
