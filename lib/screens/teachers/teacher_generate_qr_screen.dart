// lib/screens/teachers/teacher_generate_qr_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../endpoints/session_api.dart';
import '../../widgets/qr_generator.dart';
import '../../endpoints/endpoints.dart'; // optional if you need constants
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TeacherGenerateQRScreen extends StatefulWidget {
  const TeacherGenerateQRScreen({super.key});

  @override
  State<TeacherGenerateQRScreen> createState() => _TeacherGenerateQRScreenState();
}

class _TeacherGenerateQRScreenState extends State<TeacherGenerateQRScreen> {
  List<Map<String, dynamic>> classes = [];
  int? selectedClassId;
  DateTime selectedDate = DateTime.now();
  bool loading = false;

  // session result
  String? qrToken;
  DateTime? expiresAt;
  Timer? countdownTimer;
  Duration remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    setState(() => loading = true);
    try {
      final list = await SessionAPI.fetchClasses();
      setState(() {
        classes = list;
        if (classes.isNotEmpty) selectedClassId = classes.first['id'] as int?;
      });
    } catch (e) {
      // If classes endpoint not available, leave empty and teacher can input id manually or add fallback.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load classes: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (dt != null) setState(() => selectedDate = dt);
  }

  void _startCountdown() {
    countdownTimer?.cancel();
    if (expiresAt == null) return;
    final now = DateTime.now().toUtc();
    remaining = expiresAt!.toUtc().difference(now);
    if (remaining.isNegative) remaining = Duration.zero;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().toUtc();
      setState(() {
        remaining = expiresAt!.toUtc().difference(now);
        if (remaining.isNegative) remaining = Duration.zero;
      });
      if (remaining.inSeconds <= 0) {
        countdownTimer?.cancel();
      }
    });
  }

  Future<void> _generateQR() async {
    if (selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a class")));
      return;
    }

    setState(() {
      loading = true;
      qrToken = null;
      expiresAt = null;
    });

    try {
      final res = await SessionAPI.createSession(
        classId: selectedClassId!,
        date: selectedDate,
      );

      // parse result
      final token = res['qr_token'] as String?;
      final expires = res['expires_at'] as String?; // assume ISO string
      DateTime? expDt;
      if (expires != null) expDt = DateTime.parse(expires).toLocal();

      setState(() {
        qrToken = token;
        expiresAt = expDt;
      });

      // start countdown
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session created — show QR to students")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Create session failed: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _copyToken() async {
  if (qrToken == null) return;
  await Clipboard.setData(ClipboardData(text: qrToken!));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("QR token copied to clipboard")),
  );
}


  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$mm:$ss";
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMMd().format(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text("Generate Session QR")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Class selector
            const Text("Select Class", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (loading && classes.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (classes.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("No classes available. Ensure you have created classes in the admin or backend."),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: "Class ID (fallback)"),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => selectedClassId = int.tryParse(v),
                  ),
                ],
              )
            else
              DropdownButtonFormField<int>(
                value: selectedClassId,
                items: classes.map((c) {
                  return DropdownMenuItem<int>(
                    value: c['id'] as int?,
                    child: Text("${c['name']} (${c['section'] ?? ''})"),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedClassId = v),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

            const SizedBox(height: 16),

            // Date
            Row(
              children: [
                Expanded(child: Text("Date: $dateLabel")),
                TextButton(onPressed: _pickDate, child: const Text("Change date")),
              ],
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: loading ? null : _generateQR,
              icon: const Icon(Icons.qr_code),
              label: loading ? const Text("Generating...") : const Text("Generate QR (2 min)"),
            ),

            const SizedBox(height: 24),

            // QR display
            if (qrToken != null && expiresAt != null) ...[
              Center(child: QRGenerator(data: qrToken!, size: 280)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Expires in: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    _formatDuration(remaining),
                    style: TextStyle(
                      color: remaining.inSeconds <= 10 ? Colors.red : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: remaining.inSeconds > 0 ? _copyToken : null,
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy Token"),
                  ),
                ],
              ),
            ] else if (qrToken != null && expiresAt == null) ...[
              Text("QR generated but expiry time missing. Token: $qrToken"),
            ],
          ],
        ),
      ),
    );
  }
}
