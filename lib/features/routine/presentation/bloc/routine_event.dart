part of 'routine_bloc.dart';

sealed class RoutineEvent extends Equatable {
  const RoutineEvent();

  @override
  List<Object?> get props => [];
}

final class RoutineLoadRequested extends RoutineEvent {
  const RoutineLoadRequested();
}

final class RoutineDateChanged extends RoutineEvent {
  final DateTime date;

  const RoutineDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

final class RoutineCreateRequested extends RoutineEvent {
  final String name;
  final String description;
  final TimeOfDay time;
  final DateTime startDate;
  final DateTime? endDate;
  final File? iconFile;

  const RoutineCreateRequested({
    required this.name,
    required this.description,
    required this.time,
    required this.startDate,
    this.endDate,
    this.iconFile,
  });

  @override
  List<Object?> get props =>
      [name, description, time, startDate, endDate, iconFile];
}

final class RoutineDeleteRequested extends RoutineEvent {
  final String routineId;

  const RoutineDeleteRequested(this.routineId);

  @override
  List<Object?> get props => [routineId];
}

final class RoutineCompletionToggled extends RoutineEvent {
  final String routineId;

  const RoutineCompletionToggled(this.routineId);

  @override
  List<Object?> get props => [routineId];
}

final class RoutineFormReset extends RoutineEvent {
  const RoutineFormReset();
}

final class RoutineTimeChanged extends RoutineEvent {
  final TimeOfDay time;

  const RoutineTimeChanged(this.time);

  @override
  List<Object?> get props => [time];
}

final class RoutineStartDateChanged extends RoutineEvent {
  final DateTime date;

  const RoutineStartDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

final class RoutineEndDateChanged extends RoutineEvent {
  final DateTime? date;

  const RoutineEndDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

final class RoutineIconChanged extends RoutineEvent {
  final File? iconFile;

  const RoutineIconChanged(this.iconFile);

  @override
  List<Object?> get props => [iconFile];
}
