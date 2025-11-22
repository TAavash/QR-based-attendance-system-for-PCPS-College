import 'package:flutter/material.dart';
import '../../endpoints/auth_api.dart';
import '../screens/auth/login_screen.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> logout(BuildContext context) async {
    await AuthAPI.logout();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully")),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => logout(context),
    );
  }
}
