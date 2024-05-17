import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the plugin (called in your main app)
  Future<void> initialize() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings(
          '@mipmap/ic_launcher'), // Replace with your icon resource ID
    );
    await _notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  // Schedule notification 10 minutes before a given time
  Future<void> showScheduleNotification(
      int id, String title, String body, DateTime tenMinutesFromNow) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(
          seconds: 1)), //schedule the notification to show after 2 seconds.
      const NotificationDetails(
        // Android details
        android: AndroidNotificationDetails('main_channel', 'Main Channel',
            channelDescription: "nikita",
            importance: Importance.max,
            priority: Priority.max),
      ),

      // Type of time interpretation
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle:
          true, // To show notification even when the app is closed
    );
  }

  Future<void> scheduleNotification(
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    // Convert DateTime to TZDateTime
    tz.TZDateTime scheduledDateTime = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      scheduledDateTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
