import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize timezone database
    tz.initializeTimeZones();
    final TimezoneInfo tzObject = await FlutterTimezone.getLocalTimezone();
    final String tzName = tzObject.identifier;

    // 3. Set local timezone
    tz.setLocalLocation(tz.getLocation(tzName));

    // 4. Android Initialization Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 5. iOS/Darwin Settings
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

    // 6. Request Android 13+ Permissions explicitly
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Schedules a reminder 24 hours before the assignment deadline.
  Future<void> scheduleAssignmentReminder({
    required String id,
    required String title,
    required DateTime deadline,
  }) async {
    final scheduleDate = deadline.subtract(const Duration(days: 1));

    // Safety: don't schedule in the past
    if (scheduleDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: id.hashCode,
      title: 'Assignment Due Soon!',
      body: 'Your assignment "$title" is due tomorrow.',
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

  /// Fires a test notification 5 seconds after being called.
  Future<void> showInstantTestNotification() async {
    await _plugin.zonedSchedule(
      id: 999,
      title: '🚀 Test Successful!',
      body: 'AssignMate notifications are working on your device.',
      scheduledDate:
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
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
