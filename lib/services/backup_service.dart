import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
//  MODELS
import 'package:assignmate/models/assignment.dart';
import 'package:assignmate/models/subject.dart';
//  SERVICES
import 'package:assignmate/services/database_service.dart';

class BackupService {
  /// Exports Hive data to a JSON file and opens the Share Sheet
  static Future<void> exportBackup() async {
    try {
      final assignmentBox = DatabaseService.assignmentBox;
      final subjectBox = DatabaseService.subjectBox;
      final subjectsData = subjectBox.keys.map((key) {
        final s = subjectBox.get(key)!;
        return {
          'key': key, // Save the actual Hive key
          'name': s.name,
          'iconCodePoint': s.iconCodePoint,
          'colorValue': s.colorValue,
        };
      }).toList();

      // 2. Export Assignments
      final assignmentsData = assignmentBox.values
          .map((a) => {
                'id': a.id,
                'title': a.title,
                'subjectId': a.subjectId,
                'description': a.description,
                'deadline': a.deadline.toIso8601String(),
                'reminder': a.reminder?.toIso8601String(),
                'status': a.status,
                'submittedAt': a.submittedAt?.toIso8601String(),
              })
          .toList();

      final backupData = {
        'subjects': subjectsData,
        'assignments': assignmentsData,
      };

      String jsonString = jsonEncode(backupData);

      // 3. Save and Share
      final directory = await getTemporaryDirectory();
      final String timestamp =
          DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final File file =
          File('${directory.path}/AssignMate_Full_Backup_$timestamp.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [
          XFile(file.path, mimeType: 'application/json')
        ], // Add the mimeType here
        text: 'AssignMate Full Data Backup',
        subject: 'AssignMate Backup', // Subject helps Android categorize it
      );
    } catch (e) {
      throw Exception("Export failed: $e");
    }
  }

  /// Opens file picker, reads JSON, and saves to Hive
  static Future<bool> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      Map<String, dynamic> backupData = jsonDecode(content);

      // 1. Import Subjects First
      if (backupData.containsKey('subjects')) {
        for (var s in backupData['subjects']) {
          final subject = Subject(
            name: s['name'],
            iconCodePoint: s['iconCodePoint'],
            colorValue: s['colorValue'],
          );
          await DatabaseService.subjectBox.put(s['key'], subject);
        }
      }

      // 2. Import Assignments Second
      if (backupData.containsKey('assignments')) {
        for (var a in backupData['assignments']) {
          final assignment = Assignment(
            id: a['id'],
            title: a['title'],
            deadline: DateTime.parse(a['deadline']),
            status: a['status'],
            subjectId: a['subjectId'],
            description: a['description'] ?? '',
          );
          // Assign nullables separately after construction
          if (a['reminder'] != null) {
            assignment.reminder = DateTime.parse(a['reminder']);
          }
          if (a['submittedAt'] != null) {
            assignment.submittedAt = DateTime.parse(a['submittedAt']);
          }
          await DatabaseService.assignmentBox.put(assignment.id, assignment);
        }
      }
      return true;
    } catch (e) {
      print("Import Error: $e");
      return false;
    }
  }
}
