import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

class QRGenerator extends StatelessWidget {
  final String data;
  final double size;

  const QRGenerator({super.key, required this.data, this.size = 250});

  @override
  Widget build(BuildContext context) {
    // EXACT README STYLE
    final qrCode = QrCode(4, QrErrorCorrectLevel.L)..addData(data);
    final qrImage = QrImage(qrCode);

    return CustomPaint(
      size: Size.square(size),
      painter: _QrPainter(qrImage),
    );
  }
}

class _QrPainter extends CustomPainter {
  final QrImage qrImg;

  _QrPainter(this.qrImg);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final cellSize = size.width / qrImg.moduleCount;

    for (var x = 0; x < qrImg.moduleCount; x++) {
      for (var y = 0; y < qrImg.moduleCount; y++) {
        if (qrImg.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * cellSize,
              y * cellSize,
              cellSize,
              cellSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
