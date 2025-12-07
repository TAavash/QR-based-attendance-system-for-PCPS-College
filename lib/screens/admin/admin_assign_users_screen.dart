import 'package:flutter/material.dart';
import '../../endpoints/admin_api.dart';

class AdminAssignUsersScreen extends StatefulWidget {
  const AdminAssignUsersScreen({super.key});

  @override
  State<AdminAssignUsersScreen> createState() =>
      _AdminAssignUsersScreenState();
}

class _AdminAssignUsersScreenState
    extends State<AdminAssignUsersScreen> {
  final classId = TextEditingController();

  List<Map<String, dynamic>> students = [];
  final selected = <int>{};

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      final users = await AdminAPI.getUsers();
      setState(() {
        students = users.where((u) => u["role"] == "student").toList();
      });
    } catch (e) {}

    setState(() => loading = false);
  }

  void toggle(int id) {
    setState(() {
      if (selected.contains(id)) {
        selected.remove(id);
      } else {
        selected.add(id);
      }
    });
  }

  Future<void> submit() async {
    final id = int.tryParse(classId.text.trim());
    if (id == null) {
      _msg("Invalid class ID");
      return;
    }

    if (selected.isEmpty) {
      _msg("Select at least 1 student");
      return;
    }

    setState(() => saving = true);

    try {
      final res = await AdminAPI.assignStudents(
        classId: id,
        studentIds: selected.toList(),
      );

      _msg(res["message"] ?? "Assigned");
      Navigator.pop(context);

    } catch (e) {
      _msg("Failed: $e");
    }

    setState(() => saving = false);
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Students")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: TextField(
                    controller: classId,
                    decoration:
                        const InputDecoration(labelText: "Enter Class ID"),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: students.map((s) {
                      final fullName =
                          "${s["first_name"]} ${s["last_name"]}";
                      return CheckboxListTile(
                        value: selected.contains(s["id"]),
                        onChanged: (_) => toggle(s["id"]),
                        title: Text(fullName),
                        subtitle: Text("ID: ${s["id"]}"),
                      );
                    }).toList(),
                  ),
                ),
                saving
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: submit,
                        child: const Text("Assign Selected"),
                      ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }
}
