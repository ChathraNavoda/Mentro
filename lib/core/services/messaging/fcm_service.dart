import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class FcmService {
  final msgService = FirebaseMessaging.instance;
  initFCM() async {
    await msgService.requestPermission();

    var token = await msgService.getToken();
    print('Token for 🔥 fcm: $token');

    FirebaseMessaging.onBackgroundMessage(handleNotification);
    FirebaseMessaging.onMessage.listen(handleNotification);
  }
}

// Future<void> handleNotification(RemoteMessage msg) async {
//   await Firebase.initializeApp(); // 👈 Add this
//   print('🔔 BG Notification Received: ${msg.notification?.title}');
// }
Future<void> handleNotification(RemoteMessage message) async {
  print("🔔 BG Notification Received: ${message.notification?.title}");

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel', // channel id
    'High Importance Notifications', // channel name
    channelDescription: 'Used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? 'New Message',
    message.notification?.body ?? '',
    platformChannelSpecifics,
  );
}
