import 'package:hive_flutter/hive_flutter.dart';
//  MODELS
import '../models/assignment.dart';
import '../models/subject.dart';
//  SERVCES
import '../services/notification_services.dart';
//--------------------------------------------------------------------

class DatabaseService {
  static const String _assignmentBoxName = "assignmentsBox";
  static const String _subjectBoxName = "subjectsBox";
  static final assignmentBox = Hive.box<Assignment>(_assignmentBoxName);
  static final subjectBox = Hive.box<Subject>(_subjectBoxName);

//---------------ASSIGNMENT-----------------------

  static List<Assignment> getAssignments({
    String completionStatus = 'All',
    dynamic subjectId = 'All',
  }) {
    List<Assignment> assignments = assignmentBox.values.toList();
    List<Assignment> filteredList = assignments.where((task) {
      bool matchesStatus =
          (completionStatus == "All") || (task.status == completionStatus);
      bool matchesSubject =
          (subjectId == "All") || (task.subjectId == subjectId);
      return matchesStatus && matchesSubject;
    }).toList();
    filteredList.sort((a, b) => a.deadline.compareTo(b.deadline));
    return filteredList;
  }

  static Assignment? getAssignmentById(dynamic id) {
    if (id == null) return null;
    return assignmentBox.get(id);
  }

  // Add or Update Assignment
  static Future<void> saveAssignment(Assignment assignment) async {
    if (assignment.isInBox) {
      await assignment.save();
    } else {
      await assignmentBox.put(assignment.id, assignment);
    }
  }

  // Delete an assignment
  static Future<void> deleteAssignment(String id) async {
    NotificationService().cancelNotification(id);
    await assignmentBox.delete(id);
  }

//-------------------SUBJECT------------------------

  // Add or Update Subject
  static Future<void> saveSubject(Subject subject) async {
    if (subject.isInBox) {
      await subject.save();
    } else {
      // If it's new, we add it to the box
      await subjectBox.add(subject);
    }
  }

  // Get a specific subject by its ID (key)
  static Subject? getSubjectById(dynamic id) {
    if (id == null) return null;
    return Hive.box<Subject>(_subjectBoxName).get(id);
  }

  // Delete Subject and associated assignments
  static Future<void> deleteSubject(dynamic subjectId) async {
    final sBox = Hive.box<Subject>(_subjectBoxName);
    final aBox = Hive.box<Assignment>(_assignmentBoxName);
    final linkedAssignments =
        aBox.values.where((a) => a.subjectId == subjectId).toList();

    for (var a in linkedAssignments) {
      await a.delete(); // delete assignment
    }
    await sBox.delete(subjectId); // delete subject
  }
}
