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
  final bool disclaimerAcknowledged;
  final OnboardingStatus status;
  final String? errorMessage;

  const OnboardingState({
    this.name = '',
    this.gender,
    this.currentPage = 0,
    this.disclaimerAcknowledged = false,
    this.status = OnboardingStatus.initial,
    this.errorMessage,
  });

  bool get isNameValid => name.trim().isNotEmpty;
  bool get isGenderValid => gender != null;
  bool get canProceedToGender => isNameValid;
  bool get canProceedToDisclaimer => isNameValid && isGenderValid;
  bool get canComplete => isNameValid && isGenderValid && disclaimerAcknowledged;

  OnboardingState copyWith({
    String? name,
    String? gender,
    int? currentPage,
    bool? disclaimerAcknowledged,
    OnboardingStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      currentPage: currentPage ?? this.currentPage,
      disclaimerAcknowledged:
          disclaimerAcknowledged ?? this.disclaimerAcknowledged,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [name, gender, currentPage, disclaimerAcknowledged, status, errorMessage];
}
