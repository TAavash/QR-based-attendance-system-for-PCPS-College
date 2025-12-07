import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../endpoints/session_api.dart';

class TeacherGenerateQRScreen extends StatefulWidget {
  final Map<String, dynamic> preSelectedClass;

  const TeacherGenerateQRScreen({
    super.key,
    required this.preSelectedClass,
  });

  @override
  State<TeacherGenerateQRScreen> createState() =>
      _TeacherGenerateQRScreenState();
}

class _TeacherGenerateQRScreenState extends State<TeacherGenerateQRScreen> {
  String? base64QR;
  DateTime? expiresAt;
  Timer? timer;
  Duration remaining = Duration.zero;
  bool loading = false;

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (expiresAt == null) return;

      final diff = expiresAt!.difference(DateTime.now());
      setState(() {
        remaining = diff.isNegative ? Duration.zero : diff;
      });
    });
  }

  Future<void> generateQR() async {
    setState(() {
      base64QR = null;
      expiresAt = null;
      loading = true;
    });

    try {
      final res = await SessionAPI.generateQR(
        classId: widget.preSelectedClass["id"],
      );

      setState(() {
        base64QR = res["qr_image"].split(",").last;
        expiresAt = DateTime.parse(res["expires_at"]);
      });

      startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate QR: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.preSelectedClass;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Generate QR"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          
              // 🔵 CLASS DETAILS CARD
          
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Class Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _infoRow("Subject", c["subject"]),
                      _infoRow("Class Code", c["class_code"]),
                      _infoRow("Year", c["year"]),
                      _infoRow("Section", c["section"]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

          
              // 🔵 GENERATE BUTTON
          
              ElevatedButton(
                onPressed: loading ? null : generateQR,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child: loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Generate QR",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),

              const SizedBox(height: 30),

          
              // 🔵 QR CODE DISPLAY
          
              if (base64QR != null)
                Card(
                  elevation: 4,
                  shadowColor: Colors.deepPurple.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          child: Image.memory(
                            base64Decode(base64QR!),
                            width: 260,
                            height: 260,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Countdown
                        Text(
                          remaining.inSeconds <= 0
                              ? "QR Code Expired"
                              : "Expires in: ${remaining.inMinutes.toString().padLeft(2, '0')}:"
                                  "${(remaining.inSeconds % 60).toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: remaining.inSeconds <= 0
                                ? Colors.red
                                : Colors.deepPurple,
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔧 Helper widget
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
