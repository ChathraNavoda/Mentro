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
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

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
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> cancelReminder() async {
    await _notificationsPlugin.cancel(1); // Cancels reminder if all tasks done
  }

  // ✅ These were misplaced outside the class. Move them here:

  static Future<void> scheduleOneHourNudge() async {
    await _notificationsPlugin.zonedSchedule(
      2,
      'Almost There 👣',
      'You’ve done some calm tasks today. Can you complete all 3?',
      tz.TZDateTime.now(tz.local).add(Duration(minutes: 1)),
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

  static Future<void> schedule8PMReminderIfNeeded(int completedCount) async {
    if (completedCount == 1 || completedCount == 2) {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 20); // 8PM

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        3,
        'Gentle Nudge 🧘‍♀️',
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
      await _notificationsPlugin.cancel(3);
    }
  }
}
