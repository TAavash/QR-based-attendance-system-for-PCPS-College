import 'dart:async';
import 'package:flutter/material.dart';
import '../../endpoints/session_api.dart';
import '../../widgets/qr_image_widget.dart';
import '../../widgets/qr_generator.dart'; // fallback if backend returns a token but no image

class TeacherGenerateQRScreen extends StatefulWidget {
  final Map<String, dynamic>? preSelectedClass;

  const TeacherGenerateQRScreen({super.key, this.preSelectedClass});

  @override
  State<TeacherGenerateQRScreen> createState() => _TeacherGenerateQRScreenState();
}

class _TeacherGenerateQRScreenState extends State<TeacherGenerateQRScreen> {
  List<Map<String, dynamic>> classes = [];
  int? selectedClassId;
  Map<String, dynamic>? selectedClassData;
  bool loading = false;

  // QR result
  String? qrUuid;
  String? qrImageDataUri; // data:image/png;base64,...
  DateTime? expiresAt;
  Timer? countdownTimer;
  Duration remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadClassesAndPrefill();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadClassesAndPrefill() async {
    setState(() => loading = true);
    try {
      final list = await SessionAPI.fetchTeacherClasses();
      setState(() => classes = list);

      if (widget.preSelectedClass != null) {
        selectedClassId = widget.preSelectedClass!["id"] as int?;
        selectedClassData = widget.preSelectedClass;
      } else if (classes.isNotEmpty) {
        selectedClassId = classes.first["id"] as int?;
        selectedClassData = classes.first;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load classes: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  void _startTimer() {
    countdownTimer?.cancel();
    if (expiresAt == null) return;

    remaining = expiresAt!.difference(DateTime.now());
    if (remaining.isNegative) remaining = Duration.zero;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = expiresAt!.difference(DateTime.now());
      setState(() {
        remaining = diff.isNegative ? Duration.zero : diff;
      });
      if (remaining.inSeconds <= 0) countdownTimer?.cancel();
    });
  }

  Future<void> _generateQR() async {
    if (selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select a class")));
      return;
    }

    setState(() {
      loading = true;
      qrUuid = null;
      qrImageDataUri = null;
      expiresAt = null;
    });

    try {
      final res = await SessionAPI.generateQR(classId: selectedClassId!);

      // backend may return {"uuid": "...", "qr_image": "data:...,", "expires_at": "..."}
      setState(() {
        qrUuid = (res["uuid"] ?? res["qr_token"] ?? res["id"]?.toString())?.toString();
        qrImageDataUri = (res["qr_image"] as String?)?.isNotEmpty == true ? res["qr_image"] as String : null;
        if (res["expires_at"] != null) {
          try {
            expiresAt = DateTime.parse(res["expires_at"]).toLocal();
          } catch (_) {
            expiresAt = null;
          }
        }
      });

      // set selectedClassData from classes list so UI shows full details
      final found = classes.firstWhere((c) => c["id"] == selectedClassId, orElse: () => {});
      if (found.isNotEmpty) selectedClassData = found;

      if (expiresAt != null) _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("QR generated — show to students")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to generate QR: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _buildClassInfoCard() {
    if (selectedClassData == null) return const SizedBox.shrink();

    final c = selectedClassData!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c["subject"] ?? c["program"] ?? "Subject", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Code: ${c["class_code"] ?? c["id"] ?? "-"}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text("Year: ${c["year"] ?? c["semester"] ?? "-"}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text("Section: ${c["section"] ?? "-"}", style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$mm:$ss";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      appBar: AppBar(title: const Text("Generate Session QR")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
            child: ListView(
              shrinkWrap: true,
              children: [
                // Class selector
                Row(
                  children: [
                    Expanded(
                      child: loading
                          ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
                          : DropdownButtonFormField<int>(
                              value: selectedClassId,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              items: classes.map((c) {
                                final label = "${c['subject'] ?? c['program']} • ${c['class_code'] ?? c['id']} • ${c['section'] ?? ''}";
                                return DropdownMenuItem<int>(value: c["id"] as int?, child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis));
                              }).toList(),
                              onChanged: (v) {
                                setState(() {
                                  selectedClassId = v;
                                  selectedClassData = classes.firstWhere((c) => c["id"] == v, orElse: () => {});
                                });
                              },
                            ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: loading ? null : _generateQR,
                      icon: const Icon(Icons.qr_code),
                      label: loading ? const Text("Generating...") : const Text("Generate"),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // class info
                _buildClassInfoCard(),
                const SizedBox(height: 14),

                // QR result area
                if (qrImageDataUri != null) ...[
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          QRImageFromBase64(dataUri: qrImageDataUri!, size: isWide ? 320 : 220),
                          const SizedBox(height: 12),
                          if (expiresAt != null)
                            Text("Expires in: ${_formatDuration(remaining)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 8),
                          SelectableText("UUID: $qrUuid", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ] else if (qrUuid != null) ...[
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          QRGenerator(data: qrUuid!, size: isWide ? 320 : 220), // fallback QR renderer
                          const SizedBox(height: 12),
                          if (expiresAt != null)
                            Text("Expires in: ${_formatDuration(remaining)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 8),
                          SelectableText("Token: $qrUuid", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  const Center(child: Text("No QR generated yet")),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
