import 'package:hive/hive.dart';

// This line is needed for Hive to generate code for us later
part 'assignment.g.dart';

@HiveType(typeId: 0)
class Assignment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subject;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime deadline;

  @HiveField(5)
  String status; // PENDING, COMPLETED, SUBMITTED, CORRECTED

  @HiveField(6)
  DateTime? submittedAt;

  @HiveField(7)
  DateTime? reminderDateTime;

  Assignment({
    required this.id,
    required this.title,
    required this.subject,
    this.description = "",
    required this.deadline,
    this.status = 'PENDING',
    this.submittedAt,
    this.reminderDateTime,
  });
}
