import 'package:flutter/material.dart';
import 'package:qr_attendance/widgets/logout_button.dart';
import 'scan_qr_screen.dart'; 

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Home"),
        centerTitle: true,
        actions: const [
          LogoutButton(),
          ],

      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Welcome Student 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Scan QR Button
            ElevatedButton.icon(
              onPressed: () async {
                final scannedToken = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanQRScreen()),
                );

                if (scannedToken != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Scanned: $scannedToken")),
                  );

                  // Later, send scannedToken to backend via Attendance API
                }
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan Attendance QR"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            // View attendance history (optional placeholder)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.history),
              label: const Text("View Attendance History"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
