import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/core/services/storage_service.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final StorageService _storageService;
  final UserRepository _userRepository;

  OnboardingBloc({
    required StorageService storageService,
    required UserRepository userRepository,
  })  : _storageService = storageService,
        _userRepository = userRepository,
        super(const OnboardingState()) {
    on<OnboardingNameChanged>(_onNameChanged);
    on<OnboardingGenderSelected>(_onGenderSelected);
    on<OnboardingNextPage>(_onNextPage);
    on<OnboardingCompleteRequested>(_onCompleteRequested);
  }

  void _onNameChanged(
    OnboardingNameChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(name: event.name, clearError: true));
  }

  void _onGenderSelected(
    OnboardingGenderSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(gender: event.gender, clearError: true));
  }

  void _onNextPage(
    OnboardingNextPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (!state.canProceedToGender) return;
    emit(state.copyWith(currentPage: state.currentPage + 1));
  }

  Future<void> _onCompleteRequested(
    OnboardingCompleteRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.canComplete) return;

    emit(state.copyWith(status: OnboardingStatus.loading));

    try {
      final firstName = state.name.trim();
      final gender = state.gender;

      // Save to local storage (for quick access)
      await _storageService.save('user_name', firstName);
      await _storageService.save('user_gender', gender);
      await _storageService.save('onboarding_completed', true);

      // Save to Supabase (for sync across devices)
      await _userRepository.upsertProfile(
        firstName: firstName,
        gender: gender,
      );

      emit(state.copyWith(status: OnboardingStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: 'Failed to save profile: $e',
      ));
    }
  }
}
