import 'package:flutter/material.dart';
import '../../endpoints/auth_api.dart';
import 'admin_create_user_screen.dart';
import 'admin_create_class_screen.dart';
import 'admin_assign_users_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthAPI.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/", (route) => false);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 550 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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

  Widget _adminCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Widget screen}) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade200,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
