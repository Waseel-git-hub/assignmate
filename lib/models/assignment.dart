import 'package:hive/hive.dart';

part 'assignment.g.dart';

@HiveType(typeId: 1)
class Assignment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  dynamic subjectId;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime deadline;

  @HiveField(5)
  DateTime? reminder;

  @HiveField(6)
  String status; // PENDING, COMPLETED, SUBMITTED, CORRECTED

  @HiveField(7)
  DateTime? submittedAt;

  Assignment({
    required this.id,
    required this.title,
    required this.subjectId,
    this.description = "",
    required this.deadline,
    this.reminder,
    this.status = 'PENDING',
    this.submittedAt,
  });
}
