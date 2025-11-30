import 'package:flutter/material.dart';
import 'package:qr_attendance/endpoints/session_api.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  bool loading = false;

  String? program;
  String? semester;
  String? subject;
  String? section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Class")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Program"),
            DropdownButtonFormField(
              items: const [
                DropdownMenuItem(value: "BSC_CSSE", child: Text("CSSE")),
                DropdownMenuItem(value: "BSC_SE", child: Text("Software Engineering")),
                DropdownMenuItem(value: "FOUNDATION_SE", child: Text("Foundation SE")),
                DropdownMenuItem(value: "BSC_BM", child: Text("Business Management")),
              ],
              onChanged: (v) => setState(() => program = v),
            ),

            const SizedBox(height: 15),

            const Text("Semester"),
            DropdownButtonFormField(
              items: List.generate(
                  8, (i) => DropdownMenuItem(value: "S${i + 1}", child: Text("Semester ${i + 1}"))),
              onChanged: (v) => setState(() => semester = v),
            ),

            const SizedBox(height: 15),

            TextField(
              decoration: const InputDecoration(labelText: "Subject Name"),
              onChanged: (v) => subject = v,
            ),

            const SizedBox(height: 15),

            const Text("Section"),
            DropdownButtonFormField(
              items: const [
                DropdownMenuItem(value: "A", child: Text("Section A")),
                DropdownMenuItem(value: "B", child: Text("Section B")),
                DropdownMenuItem(value: "C", child: Text("Section C")),
              ],
              onChanged: (v) => setState(() => section = v),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : createClass,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Create Class"),
            )
          ],
        ),
      ),
    );
  }

  Future<void> createClass() async {
    if (program == null || semester == null || subject == null || section == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => loading = true);

    try {
      await SessionAPI.createClass(
        program: program!,
        semester: semester!,
        subject: subject!,
        section: section!,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Class created")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => loading = false);
  }
}
