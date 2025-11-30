import 'package:flutter/material.dart';
import '../../endpoints/auth_api.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  String role = "student";
  bool loading = false;

  Future<void> handleRegister() async {
    if (username.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    bool ok = await AuthAPI.register(
      username: username.text.trim(),
      email: email.text.trim(),
      password: password.text.trim(),
      role: role,
    );

    setState(() => loading = false);

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Registered successfully")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: username, decoration: const InputDecoration(labelText: "Username")),
            const SizedBox(height: 8),
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 8),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 12),

            Row(
              children: [
                const Text("Register as: "),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(value: "student", child: Text("Student")),
                    DropdownMenuItem(value: "teacher", child: Text("Teacher")),
                  ],
                  onChanged: (value) => setState(() => role = value ?? "student"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: handleRegister,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      child: Text("Register"),
                    ),
                  ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
