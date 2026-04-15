import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignmate/navigation_menu.dart';
//  MODELS
import 'package:assignmate/models/assignment.dart';
import 'package:assignmate/models/subject.dart';
//  SERVICES
import 'package:assignmate/services/apptheme.dart';
import 'package:assignmate/services/notification_services.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Notification
  await NotificationService().init();
  // Initialize Hive
  await Hive.initFlutter();
  // Register the Blueprint so Hive knows how to handle it
  Hive.registerAdapter(AssignmentAdapter());
  Hive.registerAdapter(SubjectAdapter());
  // Open Boxes
  await Hive.openBox<Assignment>('assignmentsBox');
  await Hive.openBox<Subject>('subjectsBox');

  final settingsBox = await Hive.openBox('settingsBox');
  final int savedThemeIndex = settingsBox.get(
    'themeMode',
    defaultValue: ThemeMode.system.index,
  );
  themeNotifier.value = ThemeMode.values[savedThemeIndex];
  AppTheme().init();

  runApp(const AssignmentsApp());
}

class AssignmentsApp extends StatelessWidget {
  const AssignmentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder "rebuilds" the app whenever themeNotifier changes
    return ListenableBuilder(
      listenable: AppTheme(),
      builder: (context, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, ThemeMode currentMode, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'AssignMate',
              // 2. Use the instance getters instead of static calls
              theme: AppTheme().lightTheme,
              darkTheme: AppTheme().darkTheme,
              themeMode: currentMode,
              home: const NavigationMenu(),
            );
          },
        );
      },
    );
  }
}
