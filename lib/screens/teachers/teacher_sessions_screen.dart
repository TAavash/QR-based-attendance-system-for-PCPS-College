import 'package:flutter/material.dart';
import '../../endpoints/session_api.dart';

class TeacherSessionsScreen extends StatefulWidget {
  const TeacherSessionsScreen({super.key});

  @override
  State<TeacherSessionsScreen> createState() => _TeacherSessionsScreenState();
}

class _TeacherSessionsScreenState extends State<TeacherSessionsScreen> {
  bool loading = true;
  List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      final data = await SessionAPI.getTeacherSessions();
      setState(() => sessions = data);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Session Records")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
              ? const Center(child: Text("No session records found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (_, i) {
                    final s = sessions[i];

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.qr_code, color: Colors.white),
                        ),
                        title: Text(s["class"]),
                        subtitle: Text(
                          "Date: ${s['date']}",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: Chip(
                          label: Text("${s["attendance_count"]} present"),
                          backgroundColor: Colors.green.shade100,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
