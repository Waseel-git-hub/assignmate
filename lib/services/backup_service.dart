import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
//  MODELS
import 'package:assignmate/models/assignment.dart';
import 'package:assignmate/models/subject.dart';
//  SERVICES
import 'package:assignmate/services/database_service.dart';

class BackupService {
  static String _prepareJsonData() {
    final assignments = DatabaseService.assignmentBox.values.toList();
    final subjects = DatabaseService.subjectBox.values.toList();

    final data = {
      'subjects': subjects
          .map((s) => {
                'key': s.key,
                'name': s.name,
                'iconCodePoint': s.iconCodePoint,
                'colorValue': s.colorValue,
              })
          .toList(),
      'assignments': assignments
          .map((a) => {
                'id': a.id,
                'title': a.title,
                'subjectId': a.subjectId,
                'deadline': a.deadline.toIso8601String(),
                'status': a.status,
                'description': a.description,
              })
          .toList(),
    };
    return jsonEncode(data);
  }

  static Future<void> saveToDevice() async {
    final jsonString = _prepareJsonData();
    final fileName =
        "AssignMate_Backup_${DateFormat('yyyyMMdd').format(DateTime.now())}.json";

    await FilePicker.saveFile(
      dialogTitle: 'Select Save Location',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: utf8.encode(jsonString),
    );
  }

  // OPTION B: Share Sheet
  static Future<void> shareBackup() async {
    final jsonString = _prepareJsonData();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/AssignMate_Backup.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'AssignMate Data Backup',
    );
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
