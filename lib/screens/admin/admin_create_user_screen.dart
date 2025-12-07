import 'package:flutter/material.dart';
import '../../endpoints/admin_api.dart';

class AdminCreateUserScreen extends StatefulWidget {
  const AdminCreateUserScreen({super.key});

  @override
  State<AdminCreateUserScreen> createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final email = TextEditingController();
  final first = TextEditingController();
  final last = TextEditingController();
  final password = TextEditingController();
  String role = "student";

  bool loading = false;

  Future<void> submit() async {
    if (email.text.isEmpty ||
        first.text.isEmpty ||
        last.text.isEmpty ||
        password.text.isEmpty) {
      _msg("All fields are required");
      return;
    }

    setState(() => loading = true);

    try {
      final res = await AdminAPI.createUser(
        email: email.text.trim(),
        firstName: first.text.trim(),
        lastName: last.text.trim(),
        password: password.text.trim(),
        role: role,
      );

      _msg(res['message'] ?? "User created");
      Navigator.pop(context);

    } catch (e) {
      _msg("Failed: $e");
    }

    setState(() => loading = false);
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create User")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: first,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: last,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: "Role"),
              items: const [
                DropdownMenuItem(value: "student", child: Text("Student")),
                DropdownMenuItem(value: "teacher", child: Text("Teacher")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (v) => setState(() => role = v ?? "student"),
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: submit,
                    child: const Text("Create User"),
                  )
          ],
        ),
      ),
    );
  }
}
