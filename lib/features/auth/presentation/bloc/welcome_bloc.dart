import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'welcome_event.dart';
part 'welcome_state.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(const WelcomeState()) {
    on<WelcomePageChanged>(_onPageChanged);
  }

  void _onPageChanged(WelcomePageChanged event, Emitter<WelcomeState> emit) {
    emit(WelcomeState(currentPage: event.page));
  }
}
