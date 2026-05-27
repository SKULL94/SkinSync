import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/models/user_profile.dart';
import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final StorageService _storageService;

  ProfileBloc({
    required UserRepository userRepository,
    required StorageService storageService,
  })  : _userRepository = userRepository,
        _storageService = storageService,
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileSkinTypeChanged>(_onSkinTypeChanged);
    on<ProfileConcernsChanged>(_onConcernsChanged);
    on<ProfileSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final profile = await _userRepository.getCurrentUserProfile();
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Failed to load profile',
      ));
    }
  }

  Future<void> _onSkinTypeChanged(
    ProfileSkinTypeChanged event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      final updated = await _userRepository.updateFields({
        'skin_type': event.skinType,
      });

      if (updated != null) {
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
        ));
      } else {
        emit(state.copyWith(status: ProfileStatus.loaded));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Failed to update skin type',
      ));
    }
  }

  Future<void> _onConcernsChanged(
    ProfileConcernsChanged event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      final updated = await _userRepository.updateFields({
        'concerns': event.concerns,
      });

      if (updated != null) {
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
        ));
      } else {
        emit(state.copyWith(status: ProfileStatus.loaded));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Failed to update concerns',
      ));
    }
  }

  Future<void> _onSignOutRequested(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      await Supabase.instance.client.auth.signOut();
      await _storageService.clearAll();
      // Navigation will be handled in the UI layer
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Failed to sign out',
      ));
    }
  }
}
