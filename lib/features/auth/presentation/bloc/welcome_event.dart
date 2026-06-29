part of 'welcome_bloc.dart';

abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();

  @override
  List<Object?> get props => [];
}

class WelcomePageChanged extends WelcomeEvent {
  final int page;

  const WelcomePageChanged(this.page);

  @override
  List<Object?> get props => [page];
}
