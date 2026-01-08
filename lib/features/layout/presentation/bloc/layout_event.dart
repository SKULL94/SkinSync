part of 'layout_bloc.dart';

sealed class LayoutEvent extends Equatable {
  const LayoutEvent();

  @override
  List<Object?> get props => [];
}

final class LayoutTabChanged extends LayoutEvent {
  final int index;

  const LayoutTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}
