part of 'face_camera_bloc.dart';

sealed class FaceCameraEvent extends Equatable {
  const FaceCameraEvent();

  @override
  List<Object?> get props => [];
}

final class FaceCameraInitRequested extends FaceCameraEvent {
  const FaceCameraInitRequested();
}

final class FaceCameraStatusChanged extends FaceCameraEvent {
  final FaceDetectionStatus status;
  const FaceCameraStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

final class FaceCameraSwitchRequested extends FaceCameraEvent {
  const FaceCameraSwitchRequested();
}

final class FaceCameraCaptureRequested extends FaceCameraEvent {
  const FaceCameraCaptureRequested();
}

final class FaceCameraDisposed extends FaceCameraEvent {
  const FaceCameraDisposed();
}
