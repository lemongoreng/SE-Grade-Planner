import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  // Singleton pattern to access the plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the plugin (run this in main.dart)
  static Future<void> init() async {
    // 1. Initialize Time Zones properly
    tz.initializeTimeZones(); 
    
    // FIXED: Capture the TimezoneInfo object, then extract its identifier
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier)); 

    // Android settings 
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings 
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

    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return; 
    }

    await _notificationsPlugin.zonedSchedule(
      id, 
      title,
      body,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'exam_alarm_channel_id', // Channel ID
          'Exam Alarms',   
          channelDescription: 'Full-screen alarms for upcoming exams',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          
          // --- ALARM CLOCK FEATURES ---
          fullScreenIntent: true, // Wakes up the screen / shows over lock screen
          category: AndroidNotificationCategory.alarm, // Bypasses Do Not Disturb
          audioAttributesUsage: AudioAttributesUsage.alarm, // Uses the Alarm volume
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive, 
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}