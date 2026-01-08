import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'layout_event.dart';
part 'layout_state.dart';

class LayoutBloc extends Bloc<LayoutEvent, LayoutState> {
  LayoutBloc() : super(const LayoutState()) {
    on<LayoutTabChanged>(_onTabChanged);
  }

  void _onTabChanged(
    LayoutTabChanged event,
    Emitter<LayoutState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }
}
