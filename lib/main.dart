import 'package:assignmate/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignmate/services/apptheme.dart';
import 'models/assignment.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  // Ensure Flutter is ready for native calls (Like Hive)
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize Hive for Flutter
  await Hive.initFlutter();

  //await NotificationService().init();

  // 2. Register the Assignment blueprint so Hive knows how to handle it
  Hive.registerAdapter(AssignmentAdapter());

  await Hive.openBox<Assignment>('assignmentsBox');
  final settingsBox = await Hive.openBox('settingsBox');
  // Load the saved theme index
  final int savedThemeIndex = settingsBox.get(
    'themeMode',
    defaultValue: ThemeMode.system.index,
  );
  themeNotifier.value = ThemeMode.values[savedThemeIndex];

  runApp(const AssignmentsApp());
}

class AssignmentsApp extends StatelessWidget {
  const AssignmentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder "rebuilds" the app whenever themeNotifier changes
    return ListenableBuilder(
      listenable: AppTheme(), // Access the singleton instance
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
