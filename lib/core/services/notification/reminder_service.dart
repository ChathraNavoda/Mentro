import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
  }

  static Future<void> oneHourReminder() async {
    await _plugin.zonedSchedule(
      101, // Unique ID
      'Keep up your calm journey 🧘',
      'You still have more tasks to complete today. Let’s go!',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 30)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Task Reminders',
          channelDescription: 'Reminds to complete calm tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> daily8PMReminder(int completedCount) async {
    if (completedCount == 1 || completedCount == 2) {
      final now = tz.TZDateTime.now(tz.local);
      final today8PM =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);

      // If it's already past 8PM, skip
      if (now.isBefore(today8PM)) {
        await _plugin.zonedSchedule(
          102,
          '🌙 Don’t forget your final calm moment!',
          'You’re almost there. One more activity to go today 💫',
          today8PM,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminder_channel',
              'Task Reminders',
              channelDescription: 'Evening reminder for pending tasks',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  static Future<void> noReminder() async {
    await _plugin.cancel(101); // cancel one-hour reminder
    await _plugin.cancel(102); // cancel 8PM reminder
  }
}
