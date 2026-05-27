import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/core/services/supabase_services.dart';

part 'personal_details_event.dart';
part 'personal_details_state.dart';

class PersonalDetailsBloc
    extends Bloc<PersonalDetailsEvent, PersonalDetailsState> {
  final UserRepository _userRepository;
  final StorageService _storageService;

  PersonalDetailsBloc({
    required UserRepository userRepository,
    required StorageService storageService,
  })  : _userRepository = userRepository,
        _storageService = storageService,
        super(const PersonalDetailsState()) {
    on<PersonalDetailsLoadRequested>(_onLoadRequested);
    on<PersonalDetailsFirstNameChanged>(_onFirstNameChanged);
    on<PersonalDetailsLastNameChanged>(_onLastNameChanged);
    on<PersonalDetailsEmailChanged>(_onEmailChanged);
    on<PersonalDetailsLocationChanged>(_onLocationChanged);
    on<PersonalDetailsAllergiesChanged>(_onAllergiesChanged);
    on<PersonalDetailsGenderChanged>(_onGenderChanged);
    on<PersonalDetailsDateOfBirthChanged>(_onDateOfBirthChanged);
    on<PersonalDetailsFitzpatrickChanged>(_onFitzpatrickChanged);
    on<PersonalDetailsSaveRequested>(_onSaveRequested);
  }

  Future<void> _onLoadRequested(
    PersonalDetailsLoadRequested event,
    Emitter<PersonalDetailsState> emit,
  ) async {
    emit(state.copyWith(status: PersonalDetailsStatus.loading));

    try {
      final profile = await _userRepository.getCurrentUserProfile();
      final phone = SupabaseService.currentUser?.phone;

      if (profile != null) {
        emit(state.copyWith(
          status: PersonalDetailsStatus.loaded,
          firstName: profile.firstName ?? '',
          lastName: profile.lastName ?? '',
          email: profile.email ?? '',
          location: profile.location ?? '',
          allergies: profile.knownAllergies ?? '',
          gender: profile.gender,
          dateOfBirth: profile.dateOfBirth,
          fitzpatrickScale: profile.fitzpatrickScale,
          phone: phone,
        ));
      } else {
        // Fallback to local storage
        final name = _storageService.fetch<String>('user_name');
        final gender = _storageService.fetch<String>('user_gender');
        emit(state.copyWith(
          status: PersonalDetailsStatus.loaded,
          firstName: name ?? '',
          gender: gender,
          phone: phone,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PersonalDetailsStatus.failure,
        errorMessage: 'Failed to load profile',
      ));
    }
  }

  void _onFirstNameChanged(
    PersonalDetailsFirstNameChanged event,
    Emitter<PersonalDetailsState> emit,
  ) {
    emit(state.copyWith(firstName: event.firstName));
  }

  void _onLastNameChanged(
    PersonalDetailsLastNameChanged event,
    Emitter<PersonalDetailsState> emit,
  ) {
    emit(state.copyWith(lastName: event.lastName));
  }

  void _onEmailChanged(
    PersonalDetailsEmailChanged event,
    Emitter<PersonalDetailsState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  void _onLocationChanged(
    PersonalDetailsLocationChanged event,
    Emitter<PersonalDetailsState> emit,
  ) {
    emit(state.copyWith(location: event.location));
  }

  void _onAllergiesChanged(
    PersonalDetailsAllergiesChanged event,
    Emitter<PersonalDetailsState> emit,
  ) {
    emit(state.copyWith(allergies: event.allergies));
  }

  void _onGenderChanged(
    PersonalDetailsGenderChanged event,
    Emitter<PersonalDetailsState> emit,
  ) {
    emit(state.copyWith(gender: event.gender));
  }

  void _onDateOfBirthChanged(
    PersonalDetailsDateOfBirthChanged event,
    Emitter<PersonalDetailsState> emit,
  ) {
    emit(state.copyWith(dateOfBirth: event.dateOfBirth));
  }

  void _onFitzpatrickChanged(
    PersonalDetailsFitzpatrickChanged event,
    Emitter<PersonalDetailsState> emit,
  ) {
    emit(state.copyWith(fitzpatrickScale: event.fitzpatrickScale));
  }

  Future<void> _onSaveRequested(
    PersonalDetailsSaveRequested event,
    Emitter<PersonalDetailsState> emit,
  ) async {
    emit(state.copyWith(status: PersonalDetailsStatus.saving));

    try {
      final updatedProfile = await _userRepository.upsertProfile(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim().isNotEmpty ? state.lastName.trim() : null,
        gender: state.gender,
        dateOfBirth: state.dateOfBirth,
        email: state.email.trim().isNotEmpty ? state.email.trim() : null,
        location: state.location.trim().isNotEmpty ? state.location.trim() : null,
        fitzpatrickScale: state.fitzpatrickScale,
        knownAllergies:
            state.allergies.trim().isNotEmpty ? state.allergies.trim() : null,
      );

      // Also update local storage
      await _storageService.save('user_name', state.firstName.trim());
      if (state.gender != null) {
        await _storageService.save('user_gender', state.gender);
      }

      if (updatedProfile != null) {
        emit(state.copyWith(status: PersonalDetailsStatus.success));
      } else {
        emit(state.copyWith(
          status: PersonalDetailsStatus.failure,
          errorMessage: 'Failed to save. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PersonalDetailsStatus.failure,
        errorMessage: 'Failed to save profile',
      ));
    }
  }
}
