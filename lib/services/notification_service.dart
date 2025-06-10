import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelId = 'routine_channel';
  static const String _channelName = 'Routine Notifications';
  static const String _channelDesc = 'Notifications for skincare routines';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleRoutineNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    final tz.TZDateTime scheduledDate = _convertToTZDateTime(date, time);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  tz.TZDateTime _convertToTZDateTime(DateTime date, TimeOfDay time) {
    final tz.Location location = tz.local;
    return tz.TZDateTime(
      location,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  int _generateNotificationId(String routineId, DateTime date) {
    return Object.hash(routineId, date);
  }

  Future<void> scheduleCustomRoutine(CustomRoutine routine) async {
    // Cancel any existing notifications for this routine
    await _cancelRoutineNotifications(routine.id);

    final dates = _getNotificationDates(routine);

    for (final date in dates) {
      await scheduleRoutineNotification(
        id: _generateNotificationId(routine.id, date),
        title: 'Routine Reminder: ${routine.name}',
        body: routine.description.isNotEmpty
            ? routine.description
            : "It's time for your skincare routine!",
        date: date,
        time: routine.time,
      );
    }
  }

  Future<void> _cancelRoutineNotifications(String routineId) async {
    // In a real app, you'd store notification IDs to cancel them specifically
    // For simplicity, we'll cancel all and reschedule
    await cancelAllNotifications();
  }

  List<DateTime> _getNotificationDates(CustomRoutine routine) {
    final List<DateTime> dates = [];
    final start = DateTime(
      routine.startDate.year,
      routine.startDate.month,
      routine.startDate.day,
    );

    // Add start date
    dates.add(start);

    // Add dates between start and end (if exists)
    if (routine.endDate != null) {
      final end = DateTime(
        routine.endDate!.year,
        routine.endDate!.month,
        routine.endDate!.day,
      );

      DateTime current = start.add(const Duration(days: 1));
      while (!current.isAfter(end)) {
        dates.add(current);
        current = current.add(const Duration(days: 1));
      }
    }

    return dates;
  }
}
