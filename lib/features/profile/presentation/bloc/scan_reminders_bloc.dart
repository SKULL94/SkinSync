import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/services/storage_service.dart';

part 'scan_reminders_event.dart';
part 'scan_reminders_state.dart';

class ScanRemindersBloc extends Bloc<ScanRemindersEvent, ScanRemindersState> {
  final StorageService _storageService;

  static const _keyEnableReminders = 'scan_reminders_enabled';
  static const _keyMorningReminder = 'scan_reminders_morning';
  static const _keyStreakAlerts = 'scan_reminders_streak';
  static const _keyFrequency = 'scan_reminders_frequency';
  static const _keyActiveDays = 'scan_reminders_days';
  static const _keyPreferredHour = 'scan_reminders_hour';
  static const _keyPreferredMinute = 'scan_reminders_minute';

  ScanRemindersBloc({
    required StorageService storageService,
  })  : _storageService = storageService,
        super(const ScanRemindersState()) {
    on<ScanRemindersLoadRequested>(_onLoadRequested);
    on<ScanRemindersEnableChanged>(_onEnableChanged);
    on<ScanRemindersMorningChanged>(_onMorningChanged);
    on<ScanRemindersStreakAlertsChanged>(_onStreakAlertsChanged);
    on<ScanRemindersFrequencyChanged>(_onFrequencyChanged);
    on<ScanRemindersDayToggled>(_onDayToggled);
    on<ScanRemindersTimeChanged>(_onTimeChanged);
    on<ScanRemindersSaveRequested>(_onSaveRequested);
  }

  Future<void> _onLoadRequested(
    ScanRemindersLoadRequested event,
    Emitter<ScanRemindersState> emit,
  ) async {
    emit(state.copyWith(status: ScanRemindersStatus.loading));

    try {
      final enableReminders =
          _storageService.fetch<bool>(_keyEnableReminders) ?? true;
      final morningReminder =
          _storageService.fetch<bool>(_keyMorningReminder) ?? true;
      final streakAlerts =
          _storageService.fetch<bool>(_keyStreakAlerts) ?? false;
      final frequency = _storageService.fetch<int>(_keyFrequency) ?? 1;
      final daysString =
          _storageService.fetch<String>(_keyActiveDays) ?? '0,4';
      final hour = _storageService.fetch<int>(_keyPreferredHour) ?? 8;
      final minute = _storageService.fetch<int>(_keyPreferredMinute) ?? 30;

      final activeDays = daysString
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.tryParse(s) ?? 0)
          .toSet();

      emit(state.copyWith(
        status: ScanRemindersStatus.loaded,
        enableReminders: enableReminders,
        morningReminder: morningReminder,
        streakAlerts: streakAlerts,
        selectedFrequency: frequency,
        activeDays: activeDays.isEmpty ? {0, 4} : activeDays,
        preferredTime: TimeOfDay(hour: hour, minute: minute),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScanRemindersStatus.loaded,
      ));
    }
  }

  void _onEnableChanged(
    ScanRemindersEnableChanged event,
    Emitter<ScanRemindersState> emit,
  ) {
    emit(state.copyWith(enableReminders: event.enabled));
  }

  void _onMorningChanged(
    ScanRemindersMorningChanged event,
    Emitter<ScanRemindersState> emit,
  ) {
    emit(state.copyWith(morningReminder: event.enabled));
  }

  void _onStreakAlertsChanged(
    ScanRemindersStreakAlertsChanged event,
    Emitter<ScanRemindersState> emit,
  ) {
    emit(state.copyWith(streakAlerts: event.enabled));
  }

  void _onFrequencyChanged(
    ScanRemindersFrequencyChanged event,
    Emitter<ScanRemindersState> emit,
  ) {
    emit(state.copyWith(selectedFrequency: event.frequencyIndex));
  }

  void _onDayToggled(
    ScanRemindersDayToggled event,
    Emitter<ScanRemindersState> emit,
  ) {
    final newDays = Set<int>.from(state.activeDays);
    if (newDays.contains(event.dayIndex)) {
      newDays.remove(event.dayIndex);
    } else {
      newDays.add(event.dayIndex);
    }
    emit(state.copyWith(activeDays: newDays));
  }

  void _onTimeChanged(
    ScanRemindersTimeChanged event,
    Emitter<ScanRemindersState> emit,
  ) {
    emit(state.copyWith(preferredTime: event.time));
  }

  Future<void> _onSaveRequested(
    ScanRemindersSaveRequested event,
    Emitter<ScanRemindersState> emit,
  ) async {
    emit(state.copyWith(status: ScanRemindersStatus.saving));

    try {
      await _storageService.save(_keyEnableReminders, state.enableReminders);
      await _storageService.save(_keyMorningReminder, state.morningReminder);
      await _storageService.save(_keyStreakAlerts, state.streakAlerts);
      await _storageService.save(_keyFrequency, state.selectedFrequency);
      await _storageService.save(_keyActiveDays, state.activeDays.join(','));
      await _storageService.save(_keyPreferredHour, state.preferredTime.hour);
      await _storageService.save(
        _keyPreferredMinute,
        state.preferredTime.minute,
      );

      emit(state.copyWith(status: ScanRemindersStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ScanRemindersStatus.failure,
        errorMessage: 'Failed to save settings',
      ));
    }
  }
}
