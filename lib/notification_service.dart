import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> scheduleCustomRoutines() async {
    try {
      if (Get.isRegistered<RoutineController>()) {
        final controller = Get.find<RoutineController>();
        final routines = controller.routines;

        const androidDetails = AndroidNotificationDetails(
          'routine_channel',
          'Routine Reminders',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        );

        const platformDetails = NotificationDetails(android: androidDetails);

        for (final routine in routines) {
          await _scheduleDaily(
            hour: routine.time.hour,
            minutes: routine.time.minute,
            id: routine.id.hashCode,
            title: '⏰ ${routine.name} Time!',
            body: routine.description,
            platformDetails: platformDetails,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error scheduling routines: $e");
      }
    }
  }
  // Future<void> scheduleDailyRoutineReminders() async {
  //   const androidDetails = AndroidNotificationDetails(
  //     'routine_channel',
  //     'Routine Reminders',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //     enableVibration: true,
  //   );

  //   const platformDetails = NotificationDetails(android: androidDetails);

  //   // Morning Routine
  //   await _scheduleDaily(
  //     hour: 8,
  //     minutes: 0,
  //     id: 1,
  //     title: '🌞 Morning Cleanser Time!',
  //     body: 'Start your day with Cetaphil Gentle Skin Cleanser',
  //     platformDetails: platformDetails,
  //   );

  //   await _scheduleDaily(
  //     hour: 8,
  //     minutes: 15,
  //     id: 2,
  //     title: '🧴 Apply Toner',
  //     body: 'Use Thayers Witch Hazel Toner',
  //     platformDetails: platformDetails,
  //   );
  // }

  Future<void> _scheduleDaily({
    required int hour,
    required int minutes,
    required int id,
    required String title,
    required String body,
    required NotificationDetails platformDetails,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextTime(hour, minutes),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextTime(int hour, int minutes) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
