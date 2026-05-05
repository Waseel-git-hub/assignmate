import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//  MODELS
import '../../models/assignment.dart';
//  SCREENS
import '../../screens/assignment/add_assignment_screen.dart';
//  WIDGETS
import '../../widgets/status_helper.dart';
//  SERVICES
import '../../services/database_service.dart';
//------------------------------------------------------------

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
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final subject = DatabaseService.subjectBox.get(assignment.subjectId);

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
                      color: Color(
                              subject?.colorValue ?? colorScheme.primary.value)
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      IconData(
                        subject?.iconCodePoint ?? Icons.assignment.codePoint,
                        fontFamily: 'MaterialIcons',
                      ),
                      color: Color(
                          subject?.colorValue ?? colorScheme.primary.value),
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
                          subject?.name ?? 'Extra',
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
                    getUrgencyColor(assignment.deadline, assignment.status),
                  ),
                  const SizedBox(width: 16),
                  _buildInfoCard(
                    context,
                    "Deadline",
                    DateFormat('MMM dd').format(assignment.deadline),
                    Icons.calendar_today_outlined,
                    colorScheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 3. Description Section
              Text(
                "Description",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.7),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
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
                    color: colorScheme.onSurface,
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
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
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

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
