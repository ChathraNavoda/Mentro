// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     final AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await _notificationsPlugin.initialize(initializationSettings);
//     tz.initializeTimeZones();
//   }

//   static Future<void> scheduleUnfinishedTaskReminder() async {
//     await _notificationsPlugin.zonedSchedule(
//       1,
//       'Gentle Nudge 🧘‍♀️',
//       'You haven’t finished all your tasks today. Ready to complete them?',
//       tz.TZDateTime.now(tz.local).add(const Duration(hours: 24)),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'reminder_channel_id',
//           'Daily Task Reminder',
//           channelDescription: 'Reminds you if daily tasks not completed',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }

//   static Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'instant_channel_id',
//       'Instant Notifications',
//       channelDescription: 'Shows immediate notifications for task status',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const notificationDetails = NotificationDetails(android: androidDetails);

//     await _notificationsPlugin.show(
//       0, // Notification ID
//       title,
//       body,
//       notificationDetails,
//     );
//   }

//   static Future<void> cancelReminder() async {
//     await _notificationsPlugin.cancel(1); // Cancels reminder if all tasks done
//   }
// }

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones(); // MANDATORY
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);
  }

  // ✅ Initialize the notification plugin and time zones
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

  // ✅ Show an instant notification
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel_id',
      'Instant Notifications',
      channelDescription: 'Shows immediate notifications for task status',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // ID for instant notification
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> scheduleOneMinuteTestNotification() async {
    final now = DateTime.now();
    final scheduledDate = tz.TZDateTime.from(
      now.add(const Duration(minutes: 1)),
      tz.getLocation('Asia/Colombo'),
    );

    await _notificationsPlugin.zonedSchedule(
      777, // Use a test ID
      '🔔 Scheduled Test',
      'This notification was scheduled 1 minute ago.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          channelDescription: 'Used for scheduled testing',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ✅ Cancel all scheduled reminders
  static Future<void> cancelReminder() async {
    await _notificationsPlugin.cancel(1); // Unfinished daily task reminder
    await _notificationsPlugin.cancel(2); // 1-hour calm nudge
    await _notificationsPlugin.cancel(3); // 8PM daily reminder
  }

  // ✅ Schedule a 24-hour reminder if tasks unfinished
  static Future<void> scheduleUnfinishedTaskReminder() async {
    await _notificationsPlugin.zonedSchedule(
      1,
      'Gentle Nudge 🧘‍♀️',
      'You haven’t finished all your tasks today. Ready to complete them?',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 24)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel_id',
          'Daily Task Reminder',
          channelDescription: 'Reminds you if daily tasks not completed',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ✅ Schedule a 1-hour nudge if some tasks are completed
  static Future<void> scheduleOneHourNudge() async {
    await _notificationsPlugin.zonedSchedule(
      2,
      'Almost There 👣',
      'You’ve done some calm tasks today. Can you complete all 3?',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 1)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'nudge_channel_id',
          '1 Hour Calm Task Nudge',
          channelDescription: 'Gently reminds after partial task completion',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ✅ Schedule a daily 8PM reminder if 1 or 2 tasks completed
  static Future<void> schedule8PMReminderIfNeeded(int completedCount) async {
    if (completedCount == 1 || completedCount == 2) {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        20,
      ); // 8:00 PM today

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        3,
        'Evening Reminder 🌙',
        'You haven’t completed all calm tasks today. There’s still time!',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'evening_channel_id',
            '8PM Daily Reminder',
            channelDescription: 'Reminds you to complete your calm tasks daily',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      // Cancel if all tasks completed
      await _notificationsPlugin.cancel(3);
    }
  }

  static Future<void> scheduleTestNotificationAt1130PM() async {
    final now = DateTime.now();
    final targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      23, // 11 PM
      57, // 30 minutes
    );

    final scheduledTime = now.isAfter(targetTime)
        ? targetTime.add(Duration(days: 1))
        : targetTime;

    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(scheduledTime, tz.getLocation('Asia/Colombo'));

    await _notificationsPlugin.zonedSchedule(
      99, // unique ID for test
      '🎯 Test Notification',
      'It’s 11:30 PM now in Colombo!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> quickDebugScheduledNotification() async {
    final scheduledDate =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    await _notificationsPlugin.zonedSchedule(
      999,
      '🔔 Test Now + 5 Seconds',
      'This should appear in 5 seconds!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          channelDescription: 'Used for debug test',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleTestNotification() async {
    final scheduledDate =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    await _notificationsPlugin.zonedSchedule(
      12345,
      'Test Notification',
      'This should appear after 10 seconds!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
