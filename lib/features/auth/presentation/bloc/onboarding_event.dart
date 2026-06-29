part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingNameChanged extends OnboardingEvent {
  final String name;

  const OnboardingNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class OnboardingGenderSelected extends OnboardingEvent {
  final String gender;

  const OnboardingGenderSelected(this.gender);

  @override
  List<Object?> get props => [gender];
}

class OnboardingNextPage extends OnboardingEvent {
  const OnboardingNextPage();
}

class OnboardingCompleteRequested extends OnboardingEvent {
  const OnboardingCompleteRequested();
}

class OnboardingDisclaimerToggled extends OnboardingEvent {
  final bool acknowledged;

  const OnboardingDisclaimerToggled(this.acknowledged);

  @override
  List<Object?> get props => [acknowledged];
}
