import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern to access the plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the plugin (run this in main.dart)
  static Future<void> init() async {
    tz.initializeTimeZones(); // Initialize time zone database

    // Android settings (icon must exist in android/app/src/main/res/drawable)
    // '@mipmap/ic_launcher' uses the default app icon
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings (default permissions)
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

    await _notificationsPlugin.initialize(settings);
    
    // Explicitly request permission for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Schedule a notification for a specific date/time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Convert DateTime to TimeZone aware DateTime
    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // If the date is in the past, don't schedule it (or schedule for next year if strictly recurring)
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return; 
    }

    await _notificationsPlugin.zonedSchedule(
      id, // Unique ID for the notification (hash code of course code usually)
      title,
      body,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'exam_channel_id', // Channel ID
          'Exam Reminders',   // Channel Name
          channelDescription: 'Notifications for upcoming exams',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Deliver exactly at time even in low power mode
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel a specific notification (e.g., if exam date changes)
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}