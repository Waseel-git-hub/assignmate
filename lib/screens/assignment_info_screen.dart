import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../widgets/status_helper.dart';
import 'add_assignment_screen.dart';

class AssignmentInfoScreen extends StatelessWidget {
  final Assignment assignment;

  const AssignmentInfoScreen({super.key, required this.assignment});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Assignment?"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // 1. Delete from Hive
              await assignment.delete();
              // 2. Close Dialog
              if (context.mounted) Navigator.pop(context);
              // 3. Go back to Home Screen
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Assignment Details"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // Use primaryContainer for a better themed background behind the icon
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          assignment.subject,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 2. Status and Deadline Row
              Row(
                children: [
                  _buildInfoCard(
                    context,
                    "Status",
                    assignment.status,
                    Icons.info_outline,
                    getStatusColor(context, assignment.status),
                  ),
                  const SizedBox(width: 16),
                  _buildInfoCard(
                    context,
                    "Deadline",
                    DateFormat('MMM dd').format(assignment.deadline),
                    Icons.calendar_today_outlined,
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 3. Description Section
              const Text(
                "Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).cardTheme.color
                      : Theme.of(context).cardTheme.color,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.transparent
                          : Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  assignment.description.isEmpty
                      ? "No description provided."
                      : assignment.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // DELETE BUTTON
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context),
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text("Delete",
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // EDIT BUTTON
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Use your custom "pop" transition logic here
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddAssignmentScreen(assignment: assignment),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Edit Assignment",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ))));
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Use the theme's card color instead of Theme.of(context).cardColor
          color: theme.cardTheme.color,
          // Match the border style from your AssignmentCard
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  isDark ? Colors.transparent : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant, // Better contrast
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
