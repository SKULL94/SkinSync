part of 'scan_reminders_bloc.dart';

sealed class ScanRemindersEvent extends Equatable {
  const ScanRemindersEvent();

  @override
  List<Object?> get props => [];
}

final class ScanRemindersLoadRequested extends ScanRemindersEvent {
  const ScanRemindersLoadRequested();
}

final class ScanRemindersEnableChanged extends ScanRemindersEvent {
  final bool enabled;
  const ScanRemindersEnableChanged(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

final class ScanRemindersMorningChanged extends ScanRemindersEvent {
  final bool enabled;
  const ScanRemindersMorningChanged(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

final class ScanRemindersStreakAlertsChanged extends ScanRemindersEvent {
  final bool enabled;
  const ScanRemindersStreakAlertsChanged(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

final class ScanRemindersFrequencyChanged extends ScanRemindersEvent {
  final int frequencyIndex;
  const ScanRemindersFrequencyChanged(this.frequencyIndex);

  @override
  List<Object?> get props => [frequencyIndex];
}

final class ScanRemindersDayToggled extends ScanRemindersEvent {
  final int dayIndex;
  const ScanRemindersDayToggled(this.dayIndex);

  @override
  List<Object?> get props => [dayIndex];
}

final class ScanRemindersTimeChanged extends ScanRemindersEvent {
  final TimeOfDay time;
  const ScanRemindersTimeChanged(this.time);

  @override
  List<Object?> get props => [time];
}

final class ScanRemindersSaveRequested extends ScanRemindersEvent {
  const ScanRemindersSaveRequested();
}
