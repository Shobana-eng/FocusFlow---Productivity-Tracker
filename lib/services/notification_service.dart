// PART 1/3
// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
NotificationService._();

static final NotificationService instance =
NotificationService._();

final FlutterLocalNotificationsPlugin
_notifications = FlutterLocalNotificationsPlugin();

Future<void> initialize() async {
tz.initializeTimeZones();

const AndroidInitializationSettings androidSettings =
AndroidInitializationSettings('@mipmap/ic_launcher');

const InitializationSettings settings =
InitializationSettings(
android: androidSettings,
);

await _notifications.initialize(settings);

const AndroidNotificationChannel channel =
AndroidNotificationChannel(
'focusflow_channel',
'FocusFlow Notifications',
description: 'Task reminders and productivity alerts',
importance: Importance.high,
);

await _notifications
.resolvePlatformSpecificImplementation<
AndroidFlutterLocalNotificationsPlugin>()
?.createNotificationChannel(channel);

await _notifications
.resolvePlatformSpecificImplementation<
AndroidFlutterLocalNotificationsPlugin>()
?.requestNotificationsPermission();
}

Future<void> showNotification({
required int id,
required String title,
required String body,
}) async {
const AndroidNotificationDetails androidDetails =
AndroidNotificationDetails(
'focusflow_channel',
'FocusFlow Notifications',
channelDescription:
'Task reminders and productivity alerts',
importance: Importance.high,
priority: Priority.high,
);

const NotificationDetails details =
NotificationDetails(
android: androidDetails,
);

await _notifications.show(
id,
title,
body,
details,
);
}
Future<void> scheduleNotification({
required int id,
required String title,
required String body,
required DateTime scheduledTime,
}) async {
const AndroidNotificationDetails androidDetails =
AndroidNotificationDetails(
'focusflow_channel',
'FocusFlow Notifications',
channelDescription:
'Task reminders and productivity alerts',
importance: Importance.high,
priority: Priority.high,
);

const NotificationDetails details = NotificationDetails(
android: androidDetails,
);

await _notifications.zonedSchedule(
id,
title,
body,
tz.TZDateTime.from(scheduledTime, tz.local),
details,
androidScheduleMode:
AndroidScheduleMode.exactAllowWhileIdle,
uiLocalNotificationDateInterpretation:
UILocalNotificationDateInterpretation.absoluteTime,
);
}

Future<void> cancelNotification(int id) async {
await _notifications.cancel(id);
}

Future<void> cancelAllNotifications() async {
await _notifications.cancelAll();
}
}
