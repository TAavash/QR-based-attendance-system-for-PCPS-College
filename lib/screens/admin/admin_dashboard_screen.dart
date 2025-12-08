import 'package:flutter/material.dart';
import '../../endpoints/auth_api.dart';
import 'admin_create_user_screen.dart';
import 'admin_create_class_screen.dart';
import 'admin_assign_users_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6A4CFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await AuthAPI.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
              }
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          crossAxisCount:
              MediaQuery.of(context).size.width > 550 ? 3 : 2,

          children: [
            _adminCard(
              context,
              icon: Icons.person_add,
              title: "Create User",
              subtitle: "Add Admin/Teacher/Student",
              screen: const AdminCreateUserScreen(),
            ),
            _adminCard(
              context,
              icon: Icons.class_,
              title: "Create Class",
              subtitle: "Make class entries",
              screen: const AdminCreateClassScreen(),
            ),
            _adminCard(
              context,
              icon: Icons.group_add,
              title: "Assign Users",
              subtitle: "Assign students/teachers",
              screen: const AdminAssignUsersScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6A4CFF),
              const Color(0xFF8D6CFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),

        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 45, color: Colors.white),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
