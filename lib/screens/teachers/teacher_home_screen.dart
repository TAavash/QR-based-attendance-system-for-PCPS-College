import 'package:flutter/material.dart';
import '../../widgets/logout_button.dart';
import 'teacher_generate_qr_screen.dart';
import 'teacher_sessions_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Home"),
        actions: const [LogoutButton()],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text("Generate Session QR"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeacherGenerateQRScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text("View Session Records"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeacherSessionsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
