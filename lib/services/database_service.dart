import 'package:hive_flutter/hive_flutter.dart';
import '../models/assignment.dart';

class DatabaseService {
  // We name the box the same as we did in main.dart
  static const String _boxName = "assignmentsBox";

  // Get all assignments, sorted by deadline (as you requested!)
  List<Assignment> getAllAssignments() {
    final box = Hive.box<Assignment>(_boxName);
    List<Assignment> assignments = box.values.toList();

    // This sorts them so the closest deadline is at the top
    assignments.sort((a, b) => a.deadline.compareTo(b.deadline));
    return assignments;
  }

  List<Assignment> getAssignments({
    String completionStatus = 'All', // e.g. 'PENDING', 'COMPLETED'
    String subject = 'All', // e.g. 'Math', 'Science'
  }) {
    final box = Hive.box<Assignment>(_boxName);
    // 1. Start with the full list
    List<Assignment> assignments = box.values.toList();
    // 2. Apply filtering using .where()
    List<Assignment> filteredList = assignments.where((task) {
      bool matchesStatus =
          (completionStatus == "All") || (task.status == completionStatus);
      bool matchesSubject = (subject == "All") || (task.subject == subject);
      return matchesStatus && matchesSubject;
    }).toList();
    filteredList.sort((a, b) => a.deadline.compareTo(b.deadline));
    return filteredList;
  }

  // Add a new assignment
  Future<void> addAssignment(Assignment assignment) async {
    final box = Hive.box<Assignment>(_boxName);
    await box.put(assignment.id, assignment);
  }

  // Update an existing assignment (status change, etc.)
  Future<void> updateAssignment(Assignment assignment) async {
    await assignment.save(); // Hive lets objects save themselves!
  }

  // Delete an assignment
  Future<void> deleteAssignment(String id) async {
    final box = Hive.box<Assignment>(_boxName);
    await box.delete(id);
  }
}
