part of 'routine_bloc.dart';

enum RoutineStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  deleting,
  deleted,
  failure,
}

final class RoutineState extends Equatable {
  final RoutineStatus status;
  final List<RoutineEntity> routines;
  final List<RoutineEntity> filteredRoutines;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final DateTime startDate;
  final DateTime? endDate;
  final File? localIcon;
  final String? errorMessage;

  RoutineState({
    this.status = RoutineStatus.initial,
    this.routines = const [],
    this.filteredRoutines = const [],
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    DateTime? startDate,
    this.endDate,
    this.localIcon,
    this.errorMessage,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        selectedTime = selectedTime ?? TimeOfDay.now(),
        startDate = startDate ?? DateTime.now();

  RoutineState copyWith({
    RoutineStatus? status,
    List<RoutineEntity>? routines,
    List<RoutineEntity>? filteredRoutines,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    DateTime? startDate,
    DateTime? endDate,
    File? localIcon,
    String? errorMessage,
    bool clearEndDate = false,
    bool clearIcon = false,
  }) {
    return RoutineState(
      status: status ?? this.status,
      routines: routines ?? this.routines,
      filteredRoutines: filteredRoutines ?? this.filteredRoutines,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      localIcon: clearIcon ? null : (localIcon ?? this.localIcon),
      errorMessage: errorMessage,
    );
  }

  int get completedCount {
    return filteredRoutines
        .where((r) => r.isCompletedOnDate(selectedDate))
        .length;
  }

  @override
  List<Object?> get props => [
        status,
        routines,
        filteredRoutines,
        selectedDate,
        selectedTime,
        startDate,
        endDate,
        localIcon,
        errorMessage,
      ];
}
