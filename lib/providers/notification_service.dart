import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the plugin (called in your main app)
  static initialize() {
    _notificationsPlugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')));

    //  await _notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  static scheduledNotification(
      String title, String body, DateTime dateTime) async {
    // Calculate the time 10 minutes before the given dateTime
    DateTime notificationTime = dateTime.subtract(Duration(minutes: 10));
    var androidDetails = AndroidNotificationDetails(
        'important_notification', 'My Channel',
        importance: Importance.max, priority: Priority.high);

    var notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(1, title, body,
        tz.TZDateTime.from(notificationTime, tz.local), notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  // Show a notification (called from your widgets)
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            channelDescription: 'your_channel_description');

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }
}
