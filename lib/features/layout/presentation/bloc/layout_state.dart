part of 'layout_bloc.dart';

final class LayoutState extends Equatable {
  final int currentIndex;

  const LayoutState({this.currentIndex = 0});

  LayoutState copyWith({int? currentIndex}) {
    return LayoutState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [currentIndex];
}
