import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final Map<String, dynamic> classData;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.classData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String classCode = classData["class_code"] ?? "";
    final String subject = classData["subject"] ?? classData["program"] ?? "Unknown Subject";
    final String year = classData["year"]?.toString() ?? classData["semester"]?.toString() ?? "—";
    final String section = classData["section"] ?? "—";

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(section,
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.white24,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ---- SUBJECT
              Text(
                subject,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // ---- CLASS CODE
              Text(
                classCode,
                style:
                    theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 6),

              // ---- YEAR OR SEMESTER
              Text(
                "Level: $year",
                style:
                    theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),

              const Spacer(),

              // ---- FOOTER
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      "Open",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
