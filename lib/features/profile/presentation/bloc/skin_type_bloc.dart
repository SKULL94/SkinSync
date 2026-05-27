import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/core/services/storage_service.dart';

part 'skin_type_event.dart';
part 'skin_type_state.dart';

class SkinTypeBloc extends Bloc<SkinTypeEvent, SkinTypeState> {
  final UserRepository _userRepository;
  final StorageService _storageService;

  static const _keyFitzpatrick = 'skin_fitzpatrick_index';

  SkinTypeBloc({
    required UserRepository userRepository,
    required StorageService storageService,
  })  : _userRepository = userRepository,
        _storageService = storageService,
        super(const SkinTypeState()) {
    on<SkinTypeLoadRequested>(_onLoadRequested);
    on<SkinTypeSelected>(_onTypeSelected);
    on<SkinTypeFitzpatrickChanged>(_onFitzpatrickChanged);
    on<SkinTypeSaveRequested>(_onSaveRequested);
  }

  Future<void> _onLoadRequested(
    SkinTypeLoadRequested event,
    Emitter<SkinTypeState> emit,
  ) async {
    emit(state.copyWith(status: SkinTypeStatus.loading));

    try {
      final profile = await _userRepository.getCurrentUserProfile();
      final fitzpatrick = _storageService.fetch<int>(_keyFitzpatrick) ?? 2;

      emit(state.copyWith(
        status: SkinTypeStatus.loaded,
        selectedType: profile?.skinType,
        selectedFitzpatrick: fitzpatrick,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SkinTypeStatus.loaded,
      ));
    }
  }

  void _onTypeSelected(
    SkinTypeSelected event,
    Emitter<SkinTypeState> emit,
  ) {
    emit(state.copyWith(selectedType: event.skinType));
  }

  void _onFitzpatrickChanged(
    SkinTypeFitzpatrickChanged event,
    Emitter<SkinTypeState> emit,
  ) {
    emit(state.copyWith(selectedFitzpatrick: event.fitzpatrickIndex));
  }

  Future<void> _onSaveRequested(
    SkinTypeSaveRequested event,
    Emitter<SkinTypeState> emit,
  ) async {
    if (state.selectedType == null) return;

    emit(state.copyWith(status: SkinTypeStatus.saving));

    try {
      await _userRepository.updateFields({'skin_type': state.selectedType});
      await _storageService.save(_keyFitzpatrick, state.selectedFitzpatrick);

      emit(state.copyWith(status: SkinTypeStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SkinTypeStatus.failure,
        errorMessage: 'Failed to save skin profile',
      ));
    }
  }
}
