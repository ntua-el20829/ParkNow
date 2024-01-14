import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('notification_logo');

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: 
          (NotificationResponse notificationResponse) async {});
  }

  Future scheduleNotification(
      {int id = 0,
      String? title,
      String? body,
      required int hoursToAdd}) async {
    await notificationsPlugin.zonedSchedule(
    0,
    title,
    body,
    tz.TZDateTime.now(tz.local).add(Duration(minutes: hoursToAdd)),
    const NotificationDetails(
        android: AndroidNotificationDetails(
            'Reservations Channel ID', 'Reservations Channel Name',
            channelDescription: 'Notifications sent via this channel are about reservations status')),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }
}