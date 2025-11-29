import 'package:flutter/material.dart';
import 'teacher_generate_qr_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Home")),
      body: Center(
        child: // example button in TeacherHomeScreen
            ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TeacherGenerateQRScreen()),
            );
          },
          child: const Text("Generate Session QR"),
        ),
      ),
    );
  }
}
