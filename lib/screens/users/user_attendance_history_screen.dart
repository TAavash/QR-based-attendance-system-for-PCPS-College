import 'package:flutter/material.dart';
import '../../endpoints/session_api.dart';

class UserAttendanceHistoryScreen extends StatefulWidget {
  const UserAttendanceHistoryScreen({super.key});

  @override
  State<UserAttendanceHistoryScreen> createState() =>
      _UserAttendanceHistoryScreenState();
}

class _UserAttendanceHistoryScreenState
    extends State<UserAttendanceHistoryScreen> {
  bool loading = true;
  String? errorMsg;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = await SessionAPI.getStudentHistory();
      setState(() => history = data);
    } catch (e) {
      setState(() => errorMsg = e.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())

          // ERROR UI
          : errorMsg != null
              ? Center(
                  child: Text(
                    errorMsg!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                )

              // EMPTY UI
              : history.isEmpty
                  ? const Center(
                      child: Text(
                        "No attendance records found.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    )

                  // SUCCESS UI
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final h = history[i];

                        final className = h["class"] ?? "Unknown Class";
                        final date = h["date"] ?? "Unknown Date";
                        final status = (h["status"] ?? "").toString();

                        final isPresent = status.toLowerCase() == "present";

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(1, 3),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPresent ? Icons.check_circle : Icons.cancel,
                                size: 34,
                                color: isPresent ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      className,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Date: $date",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
