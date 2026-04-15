import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
//  SERVICES
import 'package:assignmate/services/database_service.dart';
//------------------------------------------------------------------------------

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone database
    tz.initializeTimeZones();
    final TimezoneInfo tzObject = await FlutterTimezone.getLocalTimezone();
    final String tzName = tzObject.identifier;

    // Set local timezone
    tz.setLocalLocation(tz.getLocation(tzName));

    // Android Initialization Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/Darwin Settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification tapped: ${details.payload}");
      },
    );

    // Request Android 13+ Permissions explicitly
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // Schedule Reminder Notification
  Future<void> scheduleAssignmentReminder({
    required String id,
    required String title,
    required dynamic subjectId,
    required DateTime reminder,
    required DateTime deadline,
  }) async {
    final String subjectName = DatabaseService.subjectBox.get(subjectId)!.name;
    final scheduleDate = reminder;
    if (scheduleDate.isBefore(DateTime.now())) return;
    final daysLeft = deadline.difference(reminder).inDays;
    String timePhrase = daysLeft == 1 ? "tomorrow" : "in $daysLeft days";
    if (daysLeft == 0) timePhrase = "today";

    await _plugin.zonedSchedule(
      id: id.hashCode,
      title: 'Assignment Reminder: $subjectName',
      // Now the body matches the custom reminder time
      body: 'Your assignment "$title" is due $timePhrase.',
      scheduledDate: tz.TZDateTime.from(scheduleDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'assignmate_channel_id',
          'Assignment Reminders',
          channelDescription: 'Notifications for upcoming assignment deadlines',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id,
    );
  }

  // Test Notification
  Future<void> showInstantTestNotification() async {
    await _plugin.zonedSchedule(
      id: 999,
      title: '🚀 Test Successful!',
      body: 'AssignMate notifications are working on your device.',
      scheduledDate:
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'System Tests',
          channelDescription: 'Used for verifying notification settings',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(String id) async {
    await _plugin.cancel(id: id.hashCode);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
