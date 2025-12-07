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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Classes"),
        actions: const [LogoutButton()],
      ),

      // refresh by pull-down
      body: RefreshIndicator(
        onRefresh: _loadClasses,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Failed to load classes",
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(error!, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadClasses,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : classes.isEmpty
                    ? Center(
                        child: Text("No classes assigned",
                            style: theme.textTheme.titleMedium),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final cross = width > 900
                                ? 4
                                : width > 700
                                    ? 3
                                    : width > 500
                                        ? 2
                                        : 1;

                            return GridView.builder(
                              padding: EdgeInsets.zero,
                              physics: const BouncingScrollPhysics(),
                              itemCount: classes.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cross,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.6, // 🔵 FIXED HEIGHT
                              ),
                              itemBuilder: (_, i) {
                                final c = classes[i];

                                return ClassCard(
                                  classData: c,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TeacherGenerateQRScreen(
                                          preSelectedClass: c,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
      ),

      // better positioned fab
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: _loadClasses,
          tooltip: "Refresh classes",
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }
}
