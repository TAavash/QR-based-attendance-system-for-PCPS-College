import 'package:flutter/material.dart';
import '../../widgets/logout_button.dart';
import 'scan_qr_screen.dart';
import 'user_attendance_history_screen.dart';
import 'profile_screen.dart';
import 'routine_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int index = 0;

  final pages = const [
    _UserHomeContent(),
    RoutineScreen(),
    UserAttendanceHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          ["Dashboard", "Routine", "History", "Profile"][index],
          style: const TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [LogoutButton()],
      ),

      body: pages[index],

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        indicatorColor: const Color(0xFF6A4CFF).withOpacity(0.2),
        height: 65,
        backgroundColor: Colors.white,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF6A4CFF)),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF6A4CFF)),
            label: "Routine",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Color(0xFF6A4CFF)),
            label: "History",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF6A4CFF)),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _UserHomeContent extends StatelessWidget {
  const _UserHomeContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Hi, Student 👋",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),

        Text(
          "Welcome back!",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 25),

        _bigActionCard(
          context,
          title: "Scan Attendance QR",
          subtitle: "Mark your attendance instantly",
          icon: Icons.qr_code_scanner,
          color: const Color(0xFF6A4CFF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanQRScreen()),
            );
          },
        ),

        const SizedBox(height: 25),

        Text(
          "Quick Actions",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF444444),
          ),
        ),
        const SizedBox(height: 10),

        LayoutBuilder(builder: (context, constraints) {
          return GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.1,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _gridButton(
                icon: Icons.history,
                label: "Attendance History",
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UserAttendanceHistoryScreen()),
                  );
                },
              ),
              _gridButton(
                icon: Icons.info,
                label: "My Classes",
                color: Colors.green,
                onTap: () {},
              ),
            ],
          );
        }),
      ],
    );
  }

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
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 55, color: Colors.white),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white70)),
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
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              )
            ],
          ),
        ),
      ),
    );
  }
}
