import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:geolocator/geolocator.dart';
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
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _prepareLocation();
  }

  Future<void> _prepareLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission required for geofence")));
        return;
      }
      currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      // ignore - can still try to scan but will send null coords
      currentPosition = null;
    }
  }

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

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;

    ctrl.scannedDataStream.listen((scanData) async {
      if (scanned) return;
      scanned = true;
      await controller?.pauseCamera();

      final code = scanData.code;
      if (code == null || code.isEmpty) {
        _showMessage("Invalid or empty QR code");
        scanned = false;
        await controller?.resumeCamera();
        return;
      }

      // Ensure we have location if possible
      if (currentPosition == null) {
        try {
          currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        } catch (_) {
          // will send 0,0 if still null
        }
      }

      final lat = currentPosition?.latitude ?? 0.0;
      final lng = currentPosition?.longitude ?? 0.0;

      try {
        final result = await SessionAPI.markAttendance(qrUuid: code, lat: lat, lng: lng);
        final msg = result["message"] ?? result["error"] ?? result.toString();
        _showMessage(msg);
      } catch (e) {
        _showMessage("Failed to mark attendance: $e");
      } finally {
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.deepPurple,
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
              child: const Text("Point camera at QR code", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
