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
        centerTitle: false,
        actions: const [LogoutButton()],
      ),
      body: RefreshIndicator(
        onRefresh: _loadClasses,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                              style: theme.textTheme.titleMedium))
                      : LayoutBuilder(builder: (context, constraints) {
                          // responsive columns
                          final width = constraints.maxWidth;
                          final crossAxisCount = width > 1000
                              ? 4
                              : width > 800
                                  ? 3
                                  : width > 600
                                      ? 2
                                      : 1;

                          return GridView.builder(
                            itemCount: classes.length +
                                1, // +1 for optional "Create" card in future
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.05,
                            ),
                            itemBuilder: (context, index) {
                              if (index < classes.length) {
                                final c = classes[index];
                                return ClassCard(
                                  classData: c,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TeacherGenerateQRScreen(
                                            preSelectedClass: c),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                // Placeholder actionable card for future "Create Class"
                                return InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Create Class (admin only)")));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add_box_outlined,
                                              size: 40, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text("Create Class",
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadClasses,
        child: const Icon(Icons.sync),
        tooltip: "Refresh classes",
      ),
    );
  }
}
