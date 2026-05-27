part of 'face_camera_bloc.dart';

enum FaceDetectionStatus {
  initializing,
  noFace,
  faceOutsideCircle,
  faceTooFar,
  faceTooClose,
  multipleFaces,
  faceReady,
}

enum FaceCameraStatus { initial, ready, capturing, captured, error }

final class FaceCameraState extends Equatable {
  final FaceCameraStatus cameraStatus;
  final FaceDetectionStatus detectionStatus;
  final bool isFrontCamera;
  final File? capturedImage;
  final String? errorMessage;

  const FaceCameraState({
    this.cameraStatus = FaceCameraStatus.initial,
    this.detectionStatus = FaceDetectionStatus.initializing,
    this.isFrontCamera = true,
    this.capturedImage,
    this.errorMessage,
  });

  bool get isReady => detectionStatus == FaceDetectionStatus.faceReady;

  FaceCameraState copyWith({
    FaceCameraStatus? cameraStatus,
    FaceDetectionStatus? detectionStatus,
    bool? isFrontCamera,
    File? capturedImage,
    String? errorMessage,
    bool clearImage = false,
  }) {
    return FaceCameraState(
      cameraStatus: cameraStatus ?? this.cameraStatus,
      detectionStatus: detectionStatus ?? this.detectionStatus,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      capturedImage: clearImage ? null : (capturedImage ?? this.capturedImage),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        cameraStatus,
        detectionStatus,
        isFrontCamera,
        capturedImage,
        errorMessage,
      ];
}
