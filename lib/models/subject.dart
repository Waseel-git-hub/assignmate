import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int iconCodePoint;

  @HiveField(2)
  int colorValue; // Store color as an integer (e.g., 0xFF42A5F5)

  Subject({
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
  });
}
