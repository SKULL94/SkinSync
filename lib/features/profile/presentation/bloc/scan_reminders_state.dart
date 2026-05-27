part of 'scan_reminders_bloc.dart';

enum ScanRemindersStatus { initial, loading, loaded, saving, success, failure }

final class ScanRemindersState extends Equatable {
  final ScanRemindersStatus status;
  final bool enableReminders;
  final bool morningReminder;
  final bool streakAlerts;
  final int selectedFrequency;
  final Set<int> activeDays;
  final TimeOfDay preferredTime;
  final String? errorMessage;

  const ScanRemindersState({
    this.status = ScanRemindersStatus.initial,
    this.enableReminders = true,
    this.morningReminder = true,
    this.streakAlerts = false,
    this.selectedFrequency = 1,
    this.activeDays = const {0, 4},
    this.preferredTime = const TimeOfDay(hour: 8, minute: 30),
    this.errorMessage,
  });

  String get formattedTime {
    final hour = preferredTime.hourOfPeriod == 0 ? 12 : preferredTime.hourOfPeriod;
    final minute = preferredTime.minute.toString().padLeft(2, '0');
    final period = preferredTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  ScanRemindersState copyWith({
    ScanRemindersStatus? status,
    bool? enableReminders,
    bool? morningReminder,
    bool? streakAlerts,
    int? selectedFrequency,
    Set<int>? activeDays,
    TimeOfDay? preferredTime,
    String? errorMessage,
  }) {
    return ScanRemindersState(
      status: status ?? this.status,
      enableReminders: enableReminders ?? this.enableReminders,
      morningReminder: morningReminder ?? this.morningReminder,
      streakAlerts: streakAlerts ?? this.streakAlerts,
      selectedFrequency: selectedFrequency ?? this.selectedFrequency,
      activeDays: activeDays ?? this.activeDays,
      preferredTime: preferredTime ?? this.preferredTime,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        enableReminders,
        morningReminder,
        streakAlerts,
        selectedFrequency,
        activeDays,
        preferredTime,
        errorMessage,
      ];
}
