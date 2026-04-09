import 'dart:ui';
import 'package:assignmate/main.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:assignmate/services/apptheme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        children: [
          // Inside your SettingsScreen ListView
          _buildSectionHeader("Appearance"),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Accent Color",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal List of Color Options
          SizedBox(
            height: 50,
            child: ListenableBuilder(
              listenable:
                  AppTheme(), // Listen for changes to highlight the selection
              builder: (context, _) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildColorOption(
                      context,
                      const Color(0xFF6366F1),
                    ), // Indigo
                    _buildColorOption(context, const Color(0xFFF43F5E)), // Rose
                    _buildColorOption(
                      context,
                      const Color(0xFF10B981),
                    ), // Emerald
                    _buildColorOption(
                      context,
                      const Color(0xFFF59E0B),
                    ), // Amber
                    _buildColorOption(context, const Color(0xFF3B82F6)), // Blue
                    _buildColorOption(
                      context,
                      const Color(0xFF8B5CF6),
                    ), // Violet
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Theme Mode",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.settings_suggest_outlined),
                            label: Text("System"),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text("Light"),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text("Dark"),
                          ),
                        ],
                        selected: {currentMode},
                        onSelectionChanged: (Set<ThemeMode> newSelection) {
                          final selectedMode = newSelection.first;

                          // 1. Update UI
                          themeNotifier.value = selectedMode;

                          // 2. Save to Hive safely
                          try {
                            var box = Hive.box('settingsBox');
                            box.put('themeMode', selectedMode.index);
                          } catch (e) {
                            debugPrint("Hive Error: $e");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),
          // Inside your SettingsScreen ListView
          _buildSectionHeader("Notifications"),

          ListTile(
            leading: const Icon(Icons.notification_important_outlined),
            title: const Text("Send Test Notification"),
            subtitle: const Text("Alert in 5 seconds"),
            onTap: () async {
              // Calling with explicit named arguments
              /* await NotificationService().scheduleNotification(
                id: 1,
                title: "AssignMate Test",
                body: "Notifications are now active! 🚀",
                scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
              );*/
            },
          ),

          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text("Reminder Lead Time"),
            subtitle: const Text("Remind me 1 hour before due date"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open a dialog to choose: 15 mins, 1 hour, 1 day, etc.
            },
          ),

          const Divider(),
        ],
      ),
    );
  }

  // Helper to keep the code clean
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, Color color) {
    // Check if this color is the one currently active in the service
    final bool isSelected = AppTheme().appAccentColor.value == color.value;

    return GestureDetector(
      onTap: () {
        AppTheme().updateAccentColor(color);
        // Optional: Save to Hive here if you want it to persist
        try {
          var box = Hive.box('settingsBox');
          box.put('accentColor', color.value);
        } catch (e) {
          debugPrint("Hive Error: $e");
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
