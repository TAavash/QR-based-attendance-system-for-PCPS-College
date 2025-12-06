import 'package:flutter/material.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  // Example static routine data for now
  final List<Map<String, String>> demoRoutine = const [
    {"day": "Mon", "time": "9:00 - 10:30", "subject": "Software Engineering"},
    {"day": "Mon", "time": "11:00 - 12:30", "subject": "Mathematics"},
    {"day": "Tue", "time": "9:00 - 10:30", "subject": "Databases"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Class Routine")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: demoRoutine.length,
        itemBuilder: (_, i) {
          final r = demoRoutine[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text(r["day"]!.substring(0,1))),
              title: Text(r["subject"]!),
              subtitle: Text(r["time"]!),
              trailing: const Icon(Icons.more_horiz),
            ),
          );
        },
      ),
    );
  }
}
