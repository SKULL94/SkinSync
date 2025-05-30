import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_10y.dart' as tz;

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    DarwinInitializationSettings iosSettings =
        const DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            requestCriticalPermission: true,
            requestProvisionalPermission: true);

    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: iosSettings);

    await notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();

    await _setupNotificationChannels();
  }

  Future<void> _setupNotificationChannels() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'routine_channel',
      'Routine Reminders',
      importance: Importance.max,
      playSound: true,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> safeSchedule(Future<void> Function() callback) async {
    try {
      await callback();
    } on PlatformException catch (e) {
      debugPrint("Notification Error: ${e.message}");
      await Future.delayed(const Duration(seconds: 1));
      await callback();
    }
  }

  Future<void> scheduleCustomRoutines() async {
    await safeSchedule(() async {
      try {
        final RoutineController controller = Get.find();
        final routines = controller.routines;

        AndroidNotificationDetails androidDetails =
            const AndroidNotificationDetails(
          'routine_channel',
          'Routine Reminders',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        );
        NotificationDetails notificationDetails =
            NotificationDetails(android: androidDetails);

        for (final routine in routines) {
          final startDate = routine.startDate;
          final endDate = routine.endDate;
          final time = routine.time;

          if (endDate == null) {
            final now = DateTime.now();
            final todayRoutineTime = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
              time.hour,
              time.minute,
            );

            if (todayRoutineTime.isAfter(now)) {
              await _scheduleSingleNotification(
                id: routine.id.hashCode + startDate.hashCode,
                title: '⏰ ${routine.name} Time!',
                body: routine.description,
                scheduledDate: todayRoutineTime,
                platformDetails: notificationDetails,
              );
            }

            await scheduleRepeatingDaily(
              hour: time.hour,
              minutes: time.minute,
              id: routine.id.hashCode,
              title: '⏰ ${routine.name} Time!',
              body: routine.description,
              startDate: startDate.add(const Duration(days: 1)),
              platformDetails: notificationDetails,
            );
          } else {
            final dates = getDatesInRange(startDate, endDate);
            for (final date in dates) {
              await _scheduleSingleNotification(
                id: routine.id.hashCode + date.hashCode,
                title: '⏰ ${routine.name} Time!',
                body: routine.description,
                scheduledDate: DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ),
                platformDetails: notificationDetails,
              );
            }
          }
        }
      } catch (e) {
        debugPrint("Error scheduling routines: $e");
      }
    });
  }

  List<DateTime> getDatesInRange(DateTime startDate, DateTime endDate) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return dates;
  }

  Future<void> scheduleRepeatingDaily({
    required int hour,
    required int minutes,
    required int id,
    required String title,
    required String body,
    required DateTime startDate,
    required NotificationDetails platformDetails,
  }) async {
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(startDate, tz.local);
    scheduledDate = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      hour,
      minutes,
    );

    final now = tz.TZDateTime.now(tz.local);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationDetails platformDetails,
  }) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (tzScheduledDate.isBefore(now)) return;

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  Future<void> cancelRoutineNotifications(CustomRoutine routine) async {
    if (routine.endDate == null) {
      // Cancel the repeating daily notification
      await notificationsPlugin.cancel(routine.id.hashCode);
      // Cancel the initial single notification (if it exists)
      await notificationsPlugin.cancel(
        routine.id.hashCode + routine.startDate.hashCode,
      );
    } else {
      // Cancel all date-specific notifications in the range
      final dates = getDatesInRange(routine.startDate, routine.endDate!);
      for (final date in dates) {
        await notificationsPlugin.cancel(routine.id.hashCode + date.hashCode);
      }
    }
  }
}
