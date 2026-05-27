import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'face_camera_event.dart';
part 'face_camera_state.dart';

class FaceCameraBloc extends Bloc<FaceCameraEvent, FaceCameraState> {
  FaceCameraBloc() : super(const FaceCameraState()) {
    on<FaceCameraInitRequested>(_onInitRequested);
    on<FaceCameraStatusChanged>(_onStatusChanged);
    on<FaceCameraSwitchRequested>(_onSwitchRequested);
    on<FaceCameraCaptureRequested>(_onCaptureRequested);
    on<FaceCameraDisposed>(_onDisposed);
  }

  void _onInitRequested(
    FaceCameraInitRequested event,
    Emitter<FaceCameraState> emit,
  ) {
    emit(state.copyWith(
      cameraStatus: FaceCameraStatus.ready,
      detectionStatus: FaceDetectionStatus.initializing,
    ));
  }

  void _onStatusChanged(
    FaceCameraStatusChanged event,
    Emitter<FaceCameraState> emit,
  ) {
    emit(state.copyWith(detectionStatus: event.status));
  }

  void _onSwitchRequested(
    FaceCameraSwitchRequested event,
    Emitter<FaceCameraState> emit,
  ) {
    emit(state.copyWith(
      isFrontCamera: !state.isFrontCamera,
      detectionStatus: FaceDetectionStatus.initializing,
    ));
  }

  void _onCaptureRequested(
    FaceCameraCaptureRequested event,
    Emitter<FaceCameraState> emit,
  ) {
    if (state.detectionStatus != FaceDetectionStatus.faceReady) return;
    emit(state.copyWith(cameraStatus: FaceCameraStatus.capturing));
  }

  void _onDisposed(
    FaceCameraDisposed event,
    Emitter<FaceCameraState> emit,
  ) {
    emit(const FaceCameraState());
  }
}
