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
    setState(() => loading = true);

    try {
      final data = await SessionAPI.getTeacherSessions();
      setState(() => sessions = data);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Sessions")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
              ? const Center(child: Text("No sessions found"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (_, i) {
                    final s = sessions[i];
                    return Card(
                      child: ListTile(
                        title: Text(s["class"]),
                        subtitle: Text("Date: ${s["date"]}"),
                        trailing: Chip(
                          label: Text("${s["attendance_count"]} present"),
                          backgroundColor: Colors.green.shade100,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: sessions.length,
                ),
    );
  }
}
