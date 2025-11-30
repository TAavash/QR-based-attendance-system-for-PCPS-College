// lib/screens/teachers/teacher_generate_qr_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../endpoints/session_api.dart';
import '../../widgets/qr_generator.dart';
import 'package:flutter/services.dart';

class TeacherGenerateQRScreen extends StatefulWidget {
  const TeacherGenerateQRScreen({super.key});

  @override
  State<TeacherGenerateQRScreen> createState() => _TeacherGenerateQRScreenState();
}

class _TeacherGenerateQRScreenState extends State<TeacherGenerateQRScreen> {
  List<Map<String, dynamic>> classes = [];
  int? selectedClassId;
  bool loading = false;

  String? qrToken;
  DateTime? expiresAt;
  Timer? timer;
  Duration remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadClasses() async {
    setState(() => loading = true);

    try {
      final list = await SessionAPI.fetchTeacherClasses();
      setState(() {
        classes = list;
        if (classes.isNotEmpty) selectedClassId = classes.first["id"];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch classes: $e")),
      );
    }

    setState(() => loading = false);
  }

  void startTimer() {
    if (expiresAt == null) return;

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = expiresAt!.difference(DateTime.now());

      setState(() {
        remaining = diff.isNegative ? Duration.zero : diff;
      });

      if (remaining.inSeconds <= 0) timer?.cancel();
    });
  }

  Future<void> generateQR() async {
    if (selectedClassId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select a class first")));
      return;
    }

    setState(() {
      loading = true;
      qrToken = null;
      expiresAt = null;
    });

    try {
      final res = await SessionAPI.createSession(classRefId: selectedClassId!);

      setState(() {
        qrToken = res["qr_token"];
        expiresAt = DateTime.parse(res["expires_at"]).toLocal();
      });

      startTimer();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("QR Generated")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate: $e")),
      );
    }

    setState(() => loading = false);
  }

  Future<void> copyToken() async {
    if (qrToken == null) return;
    await Clipboard.setData(ClipboardData(text: qrToken!));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Token Copied")));
  }

  String formatTime(Duration d) {
    return "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:"
        "${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Session QR")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Select Class", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            loading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    value: selectedClassId,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: classes.map((cls) {
                      return DropdownMenuItem<int>(
                        value: cls["id"],
                        child: Text("${cls['program']} • ${cls['subject']} • S${cls['semester']} • Section ${cls['section']}"),

                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedClassId = val),
                  ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text("Generate QR"),
              onPressed: loading ? null : generateQR,
            ),

            const SizedBox(height: 20),

            if (qrToken != null) ...[
              Center(child: QRGenerator(data: qrToken!, size: 260)),
              const SizedBox(height: 15),

              Text(
                "Expires in: ${formatTime(remaining)}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: remaining.inSeconds < 10 ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: copyToken,
                icon: const Icon(Icons.copy),
                label: const Text("Copy Token"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
