part of 'streaks_bloc.dart';

sealed class StreaksEvent extends Equatable {
  const StreaksEvent();

  @override
  List<Object?> get props => [];
}

final class StreaksLoadRequested extends StreaksEvent {
  const StreaksLoadRequested();
}

final class StreaksTypeChanged extends StreaksEvent {
  final StreakType type;

  const StreaksTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}
