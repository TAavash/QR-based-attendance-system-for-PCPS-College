import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../endpoints/session_api.dart';
import '../../widgets/qr_generator.dart';

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
  String? qrToken;
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
      qrToken = null;
      expiresAt = null;
      loading = true;
    });
    print(widget.preSelectedClass);

    try {
      final res = await SessionAPI.generateQR(
        classId: widget.preSelectedClass["id"],
      );
      print(res);
      String rawImage = res["qr_image"];

      setState(() {
        // clean base64 from data:image/png...
        base64QR = rawImage.split(",").last;

        expiresAt = DateTime.parse(res["expires_at"]);
      });

      startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to generate: $e")));
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
    final c = widget.preSelectedClass; // easier to use

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR"),
        elevation: 1,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // -------------------------
            // 🔵 CLASS INFORMATION CARD
            // -------------------------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Class Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoRow("Subject", c["subject"]),
                    _infoRow("Class Code", c["class_code"]),
                    _infoRow("Year", c["year"]),
                    _infoRow("Section", c["section"]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // -------------------------
            // 🔵 GENERATE BUTTON
            // -------------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                onPressed: loading ? null : generateQR,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Generate QR",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------
            // 🔵 QR CODE SECTION
            // -------------------------
            if (base64QR != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // --- Base64 QR Image ---
                      Image.memory(
                        base64Decode(base64QR!),
                        width: 260,
                        height: 260,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Expires in: "
                        "${remaining.inMinutes.toString().padLeft(2, '0')}:"
                        "${(remaining.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // 🔧 Helper Widget For Rows
  // -------------------------
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
