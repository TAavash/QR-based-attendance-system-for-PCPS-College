import 'package:flutter/material.dart';
import 'generate_qr_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenerateQRScreen(
                  qrToken: "test-session-token-123",
                ),
              ),
            );
          },
          child: const Text("Generate Dummy QR"),
        ),
      ),
    );
  }
}
