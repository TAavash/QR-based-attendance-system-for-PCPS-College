import 'package:flutter/material.dart';
import '../../widgets/logout_button.dart';
import '../../endpoints/session_api.dart';
import '../../widgets/class_card.dart';
import 'teacher_generate_qr_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  bool loading = true;
  List<Map<String, dynamic>> classes = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final list = await SessionAPI.fetchTeacherClasses();
      setState(() => classes = list);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "My Classes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        actions: const [
          LogoutButton(),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadClasses,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildError()
                : _buildGrid(),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A4CFF),
        elevation: 4,
        onPressed: _loadClasses,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 45, color: Colors.red),
          const SizedBox(height: 10),
          const Text("Failed to load classes",
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadClasses,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cross = w > 900 ? 4 : w > 700 ? 3 : w > 500 ? 2 : 1;

        return GridView.builder(
          itemCount: classes.length,
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (_, i) {
            final c = classes[i];
            return ClassCard(
              classData: c,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TeacherGenerateQRScreen(preSelectedClass: c),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
