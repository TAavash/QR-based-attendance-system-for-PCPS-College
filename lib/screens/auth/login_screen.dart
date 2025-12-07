import 'package:flutter/material.dart';
import 'package:qr_attendance/screens/admin/admin_dashboard_screen.dart';
import '../../endpoints/auth_api.dart';
import '../teachers/teacher_home_screen.dart';
import '../users/user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final uid = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool passwordVisible = false;

  Future<void> handleLogin() async {
    if (uid.text.isEmpty || password.text.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    setState(() => loading = true);

    bool success = await AuthAPI.login(
      uid: uid.text.trim(),
      password: password.text.trim(),
    );

    setState(() => loading = false);

    if (!success) {
      _showMessage("Invalid credentials");
      return;
    }

    String? role = await AuthAPI.getRole();

    _showMessage("Login successful");

    if (!mounted) return;

    if (role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else if (role == "teacher") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomeScreen()),
      );
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLarge = size.width > 500;

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            constraints: BoxConstraints(maxWidth: isLarge ? 420 : size.width),
            child: Column(
              children: [
                // --- APP LOGO / TITLE ---
                Icon(Icons.qr_code_rounded,
                    size: 80, color: Colors.deepPurple.shade400),
                const SizedBox(height: 12),
                Text(
                  "QR Attendance",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 40),

                // ---- LOGIN CARD ----
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // UID FIELD
                        TextField(
                          controller: uid,
                          decoration: InputDecoration(
                            labelText: "UID",
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.deepPurple.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // PASSWORD FIELD
                        TextField(
                          controller: password,
                          obscureText: !passwordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(() {
                                passwordVisible = !passwordVisible;
                              }),
                            ),
                            filled: true,
                            fillColor: Colors.deepPurple.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // LOGIN BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                          onPressed: loading ? null : handleLogin,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // VERSION / FOOTER
                Text(
                  "Powered by PCPS College",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "v1.0.0",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
