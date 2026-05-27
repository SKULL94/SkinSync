part of 'onboarding_bloc.dart';

enum OnboardingStatus {
  initial,
  loading,
  success,
  failure,
}

class OnboardingState extends Equatable {
  final String name;
  final String? gender;
  final int currentPage;
  final OnboardingStatus status;
  final String? errorMessage;

  const OnboardingState({
    this.name = '',
    this.gender,
    this.currentPage = 0,
    this.status = OnboardingStatus.initial,
    this.errorMessage,
  });

  bool get isNameValid => name.trim().isNotEmpty;
  bool get isGenderValid => gender != null;
  bool get canProceedToGender => isNameValid;
  bool get canComplete => isNameValid && isGenderValid;

  OnboardingState copyWith({
    String? name,
    String? gender,
    int? currentPage,
    OnboardingStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [name, gender, currentPage, status, errorMessage];
}
