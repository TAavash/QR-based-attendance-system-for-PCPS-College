import 'package:flutter/material.dart';
import '../../widgets/logout_button.dart';
import 'scan_qr_screen.dart';
import 'user_attendance_history_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: const Text("Student Dashboard"),
        actions: const [
          LogoutButton(),
          SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---------------------------
          // Greeting
          // ---------------------------
          Text(
            "Hi, Student 👋",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Welcome back!",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          // ---------------------------
          // Feature Card (Scan QR)
          // ---------------------------
          _bigActionCard(
            context,
            title: "Scan Attendance QR",
            subtitle: "Mark your attendance instantly",
            icon: Icons.qr_code_scanner,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanQRScreen()),
              );
            },
          ),

          const SizedBox(height: 20),

          // ---------------------------
          // Grid Menu (Responsive)
          // ---------------------------
          Text(
            "Quick Actions",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 2;
              final itemHeight = itemWidth * 0.95; // more vertical space
              final aspectRatio = itemWidth / itemHeight;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _gridButton(
                      icon: Icons.history,
                      label: "Attendance History",
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const UserAttendanceHistoryScreen()),
                        );
                      },
                    );
                  }

                  return _gridButton(
                    icon: Icons.info,
                    label: "My Classes",
                    color: Colors.green,
                    onTap: () {},
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  // ----------------------------------------------
  // WIDGETS
  // ----------------------------------------------

  Widget _bigActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.85), color.withOpacity(0.65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 55, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),

              // Prevent text overflow
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
