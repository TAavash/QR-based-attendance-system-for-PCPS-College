import 'package:flutter/material.dart';
import 'package:qr_attendance/endpoints/session_api.dart';

class UserAttendanceHistoryScreen extends StatefulWidget {
  const UserAttendanceHistoryScreen({super.key});

  @override
  State<UserAttendanceHistoryScreen> createState() =>
      _UserAttendanceHistoryScreenState();
}

class _UserAttendanceHistoryScreenState
    extends State<UserAttendanceHistoryScreen> {
  bool loading = true;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => loading = true);

    try {
      final data = await SessionAPI.getStudentHistory();
      setState(() => history = data);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance History")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text("No attendance records"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final h = history[i];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          h["status"] == "present"
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: h["status"] == "present"
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(h["class"]),
                        subtitle: Text("Date: ${h["date"]}"),
                      ),
                    );
                  },
                ),
    );
  }
}
