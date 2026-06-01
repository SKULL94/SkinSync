import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/face_camera_bloc.dart';

class FaceCameraView extends StatefulWidget {
  final Function(File imageFile) onImageCaptured;
  final VoidCallback onBack;

  const FaceCameraView({
    super.key,
    required this.onImageCaptured,
    required this.onBack,
  });

  @override
  State<FaceCameraView> createState() => _FaceCameraViewState();
}

class _FaceCameraViewState extends State<FaceCameraView>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  List<CameraDescription>? _cameras;
  DateTime? _lastDetectionTime;

  final double _circleRadiusFactor = 0.38; // Slightly larger circle for easier positioning
  static const _detectionInterval = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFaceDetector();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final bloc = context.read<FaceCameraBloc>();

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        bloc.add(const FaceCameraStatusChanged(FaceDetectionStatus.noFace));
        return;
      }

      // Always use front camera for skin analysis
      final camera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      // Apply raw capture settings to minimize beautification filters
      await _applyRawCaptureSettings();

      if (mounted) {
        bloc.add(const FaceCameraInitRequested());
        _startFaceDetection();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      bloc.add(const FaceCameraStatusChanged(FaceDetectionStatus.noFace));
    }
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: false,
        enableTracking: false,
        minFaceSize: 0.2, // Require proper face size to avoid false positives
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  /// Applies camera settings to capture raw, unfiltered images.
  /// This minimizes OEM beautification filters for accurate skin analysis.
  Future<void> _applyRawCaptureSettings() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // 1. Disable flash for consistent, natural lighting
      await _cameraController!.setFlashMode(FlashMode.off);

      // 2. Lock exposure to prevent auto-brightening/smoothing
      await _cameraController!.setExposureMode(ExposureMode.locked);

      // 3. Lock focus to prevent softening effects
      await _cameraController!.setFocusMode(FocusMode.locked);

      // 4. Set exposure offset to neutral (0.0) for true-to-life capture
      final minExposure = await _cameraController!.getMinExposureOffset();
      final maxExposure = await _cameraController!.getMaxExposureOffset();
      // Use 0.0 if within range, otherwise use midpoint
      double neutralExposure = 0.0;
      if (neutralExposure < minExposure || neutralExposure > maxExposure) {
        neutralExposure = (minExposure + maxExposure) / 2;
      }
      await _cameraController!.setExposureOffset(neutralExposure);

      debugPrint('Raw capture settings applied: flash=off, exposure=locked, focus=locked, offset=$neutralExposure');
    } catch (e) {
      // Some settings may not be supported on all devices - continue anyway
      debugPrint('Could not apply all raw capture settings: $e');
    }
  }

  void _startFaceDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _cameraController!.startImageStream((image) async {
      if (_isDetecting) return;

      // Throttle face detection to reduce CPU usage
      final now = DateTime.now();
      if (_lastDetectionTime != null &&
          now.difference(_lastDetectionTime!) < _detectionInterval) {
        return;
      }

      _isDetecting = true;
      _lastDetectionTime = now;

      try {
        final inputImage = _convertCameraImage(image);
        if (inputImage == null) {
          _isDetecting = false;
          return;
        }

        final faces = await _faceDetector!.processImage(inputImage);
        _analyzeFacePosition(faces, image.width, image.height);
      } catch (e) {
        debugPrint('Face detection error: $e');
      }

      _isDetecting = false;
    });
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final camera = _cameraController!.description;
      final rotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );

      if (rotation == null) return null;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  void _analyzeFacePosition(List<Face> faces, int imageWidth, int imageHeight) {
    if (!mounted) return;

    final bloc = context.read<FaceCameraBloc>();

    if (faces.isEmpty) {
      bloc.add(const FaceCameraStatusChanged(FaceDetectionStatus.noFace));
      return;
    }

    if (faces.length > 1) {
      bloc.add(const FaceCameraStatusChanged(FaceDetectionStatus.multipleFaces));
      return;
    }

    final face = faces.first;
    final faceRect = face.boundingBox;

    final faceCenterX = faceRect.center.dx / imageWidth;
    final faceCenterY = faceRect.center.dy / imageHeight;
    final faceSize =
        (faceRect.width / imageWidth + faceRect.height / imageHeight) / 2;

    // Check if face is roughly in frame (not at extreme edges)
    final isInFrame = faceCenterX > 0.15 && faceCenterX < 0.85 &&
                      faceCenterY > 0.15 && faceCenterY < 0.85;

    FaceDetectionStatus newStatus;
    // Balanced thresholds - needs proper face but not pixel-perfect positioning
    if (faceSize < 0.18) {
      newStatus = FaceDetectionStatus.faceTooFar;
    } else if (faceSize > 0.80) {
      newStatus = FaceDetectionStatus.faceTooClose;
    } else if (!isInFrame) {
      newStatus = FaceDetectionStatus.faceOutsideCircle;
    } else {
      newStatus = FaceDetectionStatus.faceReady;
    }

    bloc.add(FaceCameraStatusChanged(newStatus));
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final bloc = context.read<FaceCameraBloc>();
    if (bloc.state.detectionStatus != FaceDetectionStatus.faceReady) return;

    try {
      await _cameraController!.stopImageStream();
      final image = await _cameraController!.takePicture();
      widget.onImageCaptured(File(image.path));
    } catch (e) {
      debugPrint('Capture error: $e');
      _startFaceDetection();
    }
  }

  String _getStatusMessage(FaceDetectionStatus status) {
    switch (status) {
      case FaceDetectionStatus.initializing:
        return StringConst.kStartingCamera;
      case FaceDetectionStatus.noFace:
        return StringConst.kPositionFaceInCircle;
      case FaceDetectionStatus.faceOutsideCircle:
        return StringConst.kMoveFaceInsideCircle;
      case FaceDetectionStatus.faceTooFar:
        return StringConst.kMoveCloserToCamera;
      case FaceDetectionStatus.faceTooClose:
        return StringConst.kMoveBackALittle;
      case FaceDetectionStatus.multipleFaces:
        return StringConst.kOnlyOneFacePlease;
      case FaceDetectionStatus.faceReady:
        return StringConst.kPerfectTapToCapture;
    }
  }

  Color _getStatusColor(FaceDetectionStatus status) {
    switch (status) {
      case FaceDetectionStatus.faceReady:
        return AppColors.sage;
      case FaceDetectionStatus.initializing:
        return AppColors.textTertiary;
      default:
        return AppColors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaceCameraBloc, FaceCameraState>(
      buildWhen: (previous, current) =>
          previous.detectionStatus != current.detectionStatus ||
          previous.cameraStatus != current.cameraStatus,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.ink,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildCameraPreview(state)),
                const SizedBox(height: 20),
                _buildActionBar(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.kAiSkinLab,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            StringConst.kPositionYourFace,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(FaceCameraState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_cameraController != null &&
                _cameraController!.value.isInitialized)
              CameraPreview(_cameraController!)
            else
              Container(
                color: AppColors.ink,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            CustomPaint(
              painter: _FaceCircleOverlayPainter(
                status: state.detectionStatus,
                circleRadiusFactor: _circleRadiusFactor,
              ),
              size: Size.infinite,
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _buildStatusBadge(state.detectionStatus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(FaceDetectionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(status),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _getStatusMessage(status),
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(FaceCameraState state) {
    final isReady = state.detectionStatus == FaceDetectionStatus.faceReady;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 52,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: isReady ? _captureImage : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  color: isReady
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isReady
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      size: 20,
                      color: isReady ? Colors.white : Colors.white54,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      StringConst.kCapture,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isReady ? Colors.white : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceCircleOverlayPainter extends CustomPainter {
  final FaceDetectionStatus status;
  final double circleRadiusFactor;

  _FaceCircleOverlayPainter({
    required this.status,
    required this.circleRadiusFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 20);
    final radius = size.width * circleRadiusFactor;

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    final borderColor = switch (status) {
      FaceDetectionStatus.faceReady => AppColors.sage,
      FaceDetectionStatus.initializing => Colors.white38,
      _ => AppColors.amber,
    };

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, borderPaint);

    if (status == FaceDetectionStatus.faceReady) {
      final glowPaint = Paint()
        ..color = AppColors.sage.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(center, radius, glowPaint);
    }

    _drawCornerGuides(canvas, center, radius, borderColor);
  }

  void _drawCornerGuides(
      Canvas canvas, Offset center, double radius, Color color) {
    final guidePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const guideLength = 20.0;
    const offset = 0.707;

    final tl = Offset(center.dx - radius * offset, center.dy - radius * offset);
    canvas.drawLine(tl, Offset(tl.dx + guideLength, tl.dy), guidePaint);
    canvas.drawLine(tl, Offset(tl.dx, tl.dy + guideLength), guidePaint);

    final tr = Offset(center.dx + radius * offset, center.dy - radius * offset);
    canvas.drawLine(tr, Offset(tr.dx - guideLength, tr.dy), guidePaint);
    canvas.drawLine(tr, Offset(tr.dx, tr.dy + guideLength), guidePaint);

    final bl = Offset(center.dx - radius * offset, center.dy + radius * offset);
    canvas.drawLine(bl, Offset(bl.dx + guideLength, bl.dy), guidePaint);
    canvas.drawLine(bl, Offset(bl.dx, bl.dy - guideLength), guidePaint);

    final br = Offset(center.dx + radius * offset, center.dy + radius * offset);
    canvas.drawLine(br, Offset(br.dx - guideLength, br.dy), guidePaint);
    canvas.drawLine(br, Offset(br.dx, br.dy - guideLength), guidePaint);
  }

  @override
  bool shouldRepaint(covariant _FaceCircleOverlayPainter oldDelegate) {
    return oldDelegate.status != status;
  }
}
