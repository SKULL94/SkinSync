import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/features/routine/domain/entities/routine_entity.dart';
import 'package:skin_sync/features/routine/domain/usecases/create_routine.dart';
import 'package:skin_sync/features/routine/domain/usecases/delete_routine.dart';
import 'package:skin_sync/features/routine/domain/usecases/get_routines.dart';
import 'package:skin_sync/features/routine/domain/usecases/toggle_routine_completion.dart';
import 'package:skin_sync/core/services/notification_service.dart';

part 'routine_event.dart';
part 'routine_state.dart';

class RoutineBloc extends Bloc<RoutineEvent, RoutineState> {
  final GetRoutines getRoutines;
  final CreateRoutine createRoutine;
  final DeleteRoutine deleteRoutine;
  final ToggleRoutineCompletion toggleRoutineCompletion;
  final StorageService storageService;
  final NotificationService notificationService;

  RoutineBloc({
    required this.getRoutines,
    required this.createRoutine,
    required this.deleteRoutine,
    required this.toggleRoutineCompletion,
    required this.storageService,
    required this.notificationService,
  }) : super(RoutineState()) {
    on<RoutineLoadRequested>(_onLoadRequested);
    on<RoutineDateChanged>(_onDateChanged);
    on<RoutineCreateRequested>(_onCreateRequested);
    on<RoutineDeleteRequested>(_onDeleteRequested);
    on<RoutineCompletionToggled>(_onCompletionToggled);
    on<RoutineFormReset>(_onFormReset);
    on<RoutineTimeChanged>(_onTimeChanged);
    on<RoutineStartDateChanged>(_onStartDateChanged);
    on<RoutineEndDateChanged>(_onEndDateChanged);
    on<RoutineIconChanged>(_onIconChanged);
  }

  String? get _userId => storageService.fetch<String>(AppConstants.userId);

  Future<void> _onLoadRequested(
    RoutineLoadRequested event,
    Emitter<RoutineState> emit,
  ) async {
    if (_userId == null) return;

    emit(state.copyWith(status: RoutineStatus.loading));

    final result = await getRoutines(GetRoutinesParams(userId: _userId!));

    result.fold(
      (failure) => emit(state.copyWith(
        status: RoutineStatus.failure,
        errorMessage: failure.message,
      )),
      (routines) {
        final filtered = _filterRoutinesByDate(routines, state.selectedDate);
        emit(state.copyWith(
          status: RoutineStatus.loaded,
          routines: routines,
          filteredRoutines: filtered,
        ));
        _rescheduleAllNotifications(routines);
      },
    );
  }

  void _onDateChanged(
    RoutineDateChanged event,
    Emitter<RoutineState> emit,
  ) {
    final filtered = _filterRoutinesByDate(state.routines, event.date);
    emit(state.copyWith(
      selectedDate: event.date,
      filteredRoutines: filtered,
    ));
  }

  Future<void> _onCreateRequested(
    RoutineCreateRequested event,
    Emitter<RoutineState> emit,
  ) async {
    if (_userId == null) return;

    emit(state.copyWith(status: RoutineStatus.creating));

    final result = await createRoutine(CreateRoutineParams(
      name: event.name,
      description: event.description,
      time: event.time,
      userId: _userId!,
      startDate: event.startDate,
      endDate: event.endDate,
      iconFile: event.iconFile,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: RoutineStatus.failure,
        errorMessage: failure.message,
      )),
      (routine) {
        final updatedRoutines = [...state.routines, routine];
        final filtered =
            _filterRoutinesByDate(updatedRoutines, state.selectedDate);
        emit(state.copyWith(
          status: RoutineStatus.created,
          routines: updatedRoutines,
          filteredRoutines: filtered,
        ));
        _scheduleNotification(routine);
      },
    );
  }

  Future<void> _onDeleteRequested(
    RoutineDeleteRequested event,
    Emitter<RoutineState> emit,
  ) async {
    if (_userId == null) return;

    emit(state.copyWith(status: RoutineStatus.deleting));

    final routine = state.routines.firstWhere(
      (r) => r.id == event.routineId,
      orElse: () => throw Exception('Routine not found'),
    );

    final result = await deleteRoutine(DeleteRoutineParams(
      userId: _userId!,
      routineId: event.routineId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: RoutineStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedRoutines =
            state.routines.where((r) => r.id != event.routineId).toList();
        final filtered =
            _filterRoutinesByDate(updatedRoutines, state.selectedDate);
        emit(state.copyWith(
          status: RoutineStatus.deleted,
          routines: updatedRoutines,
          filteredRoutines: filtered,
        ));
        _cancelNotification(routine);
      },
    );
  }

  Future<void> _onCompletionToggled(
    RoutineCompletionToggled event,
    Emitter<RoutineState> emit,
  ) async {
    if (_userId == null) return;

    final routineIndex =
        state.routines.indexWhere((r) => r.id == event.routineId);
    if (routineIndex == -1) return;

    final routine = state.routines[routineIndex];
    final result = await toggleRoutineCompletion(ToggleRoutineCompletionParams(
      userId: _userId!,
      routineId: event.routineId,
      date: state.selectedDate,
      completionDates: routine.completionDates,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: RoutineStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedRoutine) {
        final updatedRoutines = List<RoutineEntity>.from(state.routines);
        final toggled = routine.toggleCompletion(state.selectedDate);
        updatedRoutines[routineIndex] = RoutineEntity(
          id: routine.id,
          name: routine.name,
          description: routine.description,
          time: routine.time,
          userId: routine.userId,
          createdDate: routine.createdDate,
          localIconPath: routine.localIconPath,
          completionDates: toggled.completionDates,
          startDate: routine.startDate,
          endDate: routine.endDate,
          imagePath: routine.imagePath,
        );
        final filtered =
            _filterRoutinesByDate(updatedRoutines, state.selectedDate);
        emit(state.copyWith(
          routines: updatedRoutines,
          filteredRoutines: filtered,
        ));
      },
    );
  }

  void _onFormReset(
    RoutineFormReset event,
    Emitter<RoutineState> emit,
  ) {
    emit(state.copyWith(
      selectedTime: TimeOfDay.now(),
      startDate: DateTime.now(),
      clearEndDate: true,
      clearIcon: true,
    ));
  }

  void _onTimeChanged(
    RoutineTimeChanged event,
    Emitter<RoutineState> emit,
  ) {
    emit(state.copyWith(selectedTime: event.time));
  }

  void _onStartDateChanged(
    RoutineStartDateChanged event,
    Emitter<RoutineState> emit,
  ) {
    emit(state.copyWith(startDate: event.date));
  }

  void _onEndDateChanged(
    RoutineEndDateChanged event,
    Emitter<RoutineState> emit,
  ) {
    emit(state.copyWith(
      endDate: event.date,
      clearEndDate: event.date == null,
    ));
  }

  void _onIconChanged(
    RoutineIconChanged event,
    Emitter<RoutineState> emit,
  ) {
    emit(state.copyWith(
      localIcon: event.iconFile,
      clearIcon: event.iconFile == null,
    ));
  }

  List<RoutineEntity> _filterRoutinesByDate(
    List<RoutineEntity> routines,
    DateTime selectedDate,
  ) {
    return routines.where((routine) {
      final start = DateTime(
        routine.startDate.year,
        routine.startDate.month,
        routine.startDate.day,
      );
      final end = routine.endDate != null
          ? DateTime(
              routine.endDate!.year,
              routine.endDate!.month,
              routine.endDate!.day,
            )
          : null;

      return end == null
          ? _isSameDay(start, selectedDate)
          : selectedDate.isAfter(start.subtract(const Duration(days: 1))) &&
              selectedDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _rescheduleAllNotifications(List<RoutineEntity> routines) async {
    for (final routine in routines) {
      await _scheduleNotification(routine);
    }
  }

  Future<void> _scheduleNotification(RoutineEntity routine) async {
    // Notification scheduling logic
  }

  Future<void> _cancelNotification(RoutineEntity routine) async {
    // Notification cancellation logic
  }
}
