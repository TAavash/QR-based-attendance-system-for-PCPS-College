import 'package:flutter/material.dart';
import '../../endpoints/auth_api.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  bool loading = false;

  Future<void> _change() async {
    if (oldCtrl.text.isEmpty || newCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fill both fields")));
      return;
    }
    setState(() => loading = true);
    try {
      final ok = await AuthAPI.changePassword(oldPassword: oldCtrl.text.trim(), newPassword: newCtrl.text.trim());
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password changed")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Change failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: oldCtrl, decoration: const InputDecoration(labelText: "Old password"), obscureText: true),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, decoration: const InputDecoration(labelText: "New password"), obscureText: true),
            const SizedBox(height: 18),
            loading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _change, child: const Text("Change"))
          ],
        ),
      ),
    );
  }
}
