import 'package:flutter/material.dart';
import '../../endpoints/admin_api.dart';

class AdminCreateClassScreen extends StatefulWidget {
  const AdminCreateClassScreen({super.key});

  @override
  State<AdminCreateClassScreen> createState() =>
      _AdminCreateClassScreenState();
}

class _AdminCreateClassScreenState
    extends State<AdminCreateClassScreen> {
  final year = TextEditingController();
  final semester = TextEditingController();
  final subject = TextEditingController();
  final section = TextEditingController();

  List<Map<String, dynamic>> teachers = [];
  int? selectedTeacher;

  bool loadingTeachers = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    try {
      final users = await AdminAPI.getUsers();
      setState(() {
        teachers = users.where((u) => u["role"] == "teacher").toList();
      });
    } catch (e) {}
    setState(() => loadingTeachers = false);
  }

  Future<void> submit() async {
    if (year.text.isEmpty ||
        semester.text.isEmpty ||
        subject.text.isEmpty ||
        section.text.isEmpty ||
        selectedTeacher == null) {
      _msg("All fields required");
      return;
    }

    setState(() => saving = true);

    try {
      final res = await AdminAPI.createClass(
        year: year.text.trim(),
        semester: semester.text.trim(),
        subject: subject.text.trim(),
        section: section.text.trim(),
        teacherId: selectedTeacher!,
      );

      _msg(res["message"] ?? "Class created");
      Navigator.pop(context);

    } catch (e) {
      _msg("Failed: $e");
    }

    setState(() => saving = false);
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Class")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            TextField(
              controller: year,
              decoration: const InputDecoration(labelText: "Year"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: semester,
              decoration: const InputDecoration(labelText: "Semester"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subject,
              decoration: const InputDecoration(labelText: "Subject"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: section,
              decoration: const InputDecoration(labelText: "Section"),
            ),
            const SizedBox(height: 20),

            // Teachers dropdown
            loadingTeachers
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    decoration:
                        const InputDecoration(labelText: "Select Teacher"),
                    value: selectedTeacher,
                    items: teachers
                        .map((t) => DropdownMenuItem<int>(
                              value: t["id"],
                              child: Text(
                                  "${t["first_name"]} ${t["last_name"]}"),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => selectedTeacher = v),
                  ),

            const SizedBox(height: 25),
            saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: submit,
                    child: const Text("Create Class"),
                  ),
          ],
        ),
      ),
    );
  }
}
