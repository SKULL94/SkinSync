import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
    on<PersonalDetailsImagePickRequested>(_onImagePickRequested);
  }

  final _imagePicker = ImagePicker();

  Future<void> _onLoadRequested(
    PersonalDetailsLoadRequested event,
    Emitter<PersonalDetailsState> emit,
  ) async {
    emit(state.copyWith(status: PersonalDetailsStatus.loading));

    try {
      // Try loading from user_details table first
      final userDetails = await _userRepository.getUserDetails();
      final phone = SupabaseService.currentUser?.phone;

      // Load local avatar path if exists
      final localAvatarPath =
          _storageService.fetch<String>('user_avatar_path');

      if (userDetails != null) {
        emit(state.copyWith(
          status: PersonalDetailsStatus.loaded,
          firstName: userDetails['first_name'] as String? ?? '',
          lastName: userDetails['last_name'] as String? ?? '',
          email: userDetails['email'] as String? ?? '',
          location: userDetails['location'] as String? ?? '',
          gender: userDetails['gender'] as String?,
          dateOfBirth: userDetails['date_of_birth'] != null
              ? DateTime.parse(userDetails['date_of_birth'] as String)
              : null,
          phone: phone,
          avatarUrl: userDetails['avatar_url'] as String?,
          localAvatarPath: localAvatarPath,
        ));
      } else {
        // Fallback to users table (legacy) then local storage
        final profile = await _userRepository.getCurrentUserProfile();
        if (profile != null) {
          emit(state.copyWith(
            status: PersonalDetailsStatus.loaded,
            firstName: profile.firstName ?? '',
            lastName: profile.lastName ?? '',
            email: profile.email ?? '',
            location: profile.location ?? '',
            gender: profile.gender,
            dateOfBirth: profile.dateOfBirth,
            phone: phone,
            avatarUrl: profile.avatarUrl,
            localAvatarPath: localAvatarPath,
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
            localAvatarPath: localAvatarPath,
          ));
        }
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
      // Save to user_details table
      final result = await _userRepository.upsertUserDetails(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim().isNotEmpty ? state.lastName.trim() : null,
        gender: state.gender,
        dateOfBirth: state.dateOfBirth,
        email: state.email.trim().isNotEmpty ? state.email.trim() : null,
        location: state.location.trim().isNotEmpty ? state.location.trim() : null,
        avatarUrl: state.avatarUrl,
      );

      // Also update local storage
      await _storageService.save('user_name', state.firstName.trim());
      if (state.gender != null) {
        await _storageService.save('user_gender', state.gender);
      }

      if (result != null) {
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

  Future<void> _onImagePickRequested(
    PersonalDetailsImagePickRequested event,
    Emitter<PersonalDetailsState> emit,
  ) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      emit(state.copyWith(isUploadingImage: true));

      // Save locally first
      final appDir = await getApplicationDocumentsDirectory();
      final localPath = '${appDir.path}/avatar.${pickedFile.path.split('.').last}';
      final localFile = await File(pickedFile.path).copy(localPath);

      // Save local path to storage
      await _storageService.save('user_avatar_path', localPath);

      emit(state.copyWith(localAvatarPath: localPath));

      // Upload to Supabase
      final avatarUrl = await _userRepository.uploadAvatar(localFile);

      if (avatarUrl != null) {
        // Update user_details table with new avatar URL
        await _userRepository.updateUserDetailsAvatar(avatarUrl);

        emit(state.copyWith(
          avatarUrl: avatarUrl,
          isUploadingImage: false,
        ));
      } else {
        emit(state.copyWith(
          isUploadingImage: false,
          errorMessage: 'Failed to upload image',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isUploadingImage: false,
        errorMessage: 'Failed to pick image',
      ));
    }
  }
}
