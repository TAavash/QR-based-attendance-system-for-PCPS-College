import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/users/user_home_screen.dart';
import 'screens/teachers/teacher_home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Secure storage instance
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  // Check if user is logged in and return correct home screen
  Future<Widget> _loadInitialScreen() async {
    final role = await storage.read(key: "role");

    if (role == "teacher") {
      return const TeacherHomeScreen();
    } else if (role == "student") {
      return const UserHomeScreen();
    }

    return const LoginScreen(); // Default screen
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Attendance System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: _loadInitialScreen(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data!;
        },
      ),
    );
  }
}
