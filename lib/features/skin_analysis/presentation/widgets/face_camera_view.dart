import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:skin_sync/core/constants/color_const.dart';

enum FaceDetectionStatus {
  initializing,
  noFace,
  faceOutsideCircle,
  faceTooFar,
  faceTooClose,
  multipleFaces,
  faceReady,
}

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
  FaceDetectionStatus _status = FaceDetectionStatus.initializing;
  List<CameraDescription>? _cameras;
  bool _isFrontCamera = true;

  // Circle bounds for face positioning (relative to preview)
  final double _circleRadiusFactor = 0.35;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initializeFaceDetector();
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
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _status = FaceDetectionStatus.noFace);
        return;
      }

      final camera = _cameras!.firstWhere(
        (c) => c.lensDirection == (_isFrontCamera
            ? CameraLensDirection.front
            : CameraLensDirection.back),
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

      if (mounted) {
        setState(() {});
        _startFaceDetection();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      setState(() => _status = FaceDetectionStatus.noFace);
    }
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: false,
        enableTracking: false,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  void _startFaceDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _cameraController!.startImageStream((image) async {
      if (_isDetecting) return;
      _isDetecting = true;

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

    if (faces.isEmpty) {
      setState(() => _status = FaceDetectionStatus.noFace);
      return;
    }

    if (faces.length > 1) {
      setState(() => _status = FaceDetectionStatus.multipleFaces);
      return;
    }

    final face = faces.first;
    final faceRect = face.boundingBox;

    // Calculate face center and size relative to image
    final faceCenterX = faceRect.center.dx / imageWidth;
    final faceCenterY = faceRect.center.dy / imageHeight;
    final faceSize = (faceRect.width / imageWidth + faceRect.height / imageHeight) / 2;

    // Check if face is within the circle area (center of screen)
    final distanceFromCenter = ((faceCenterX - 0.5).abs() + (faceCenterY - 0.5).abs()) / 2;

    FaceDetectionStatus newStatus;
    if (distanceFromCenter > 0.2) {
      newStatus = FaceDetectionStatus.faceOutsideCircle;
    } else if (faceSize < 0.2) {
      newStatus = FaceDetectionStatus.faceTooFar;
    } else if (faceSize > 0.6) {
      newStatus = FaceDetectionStatus.faceTooClose;
    } else {
      newStatus = FaceDetectionStatus.faceReady;
    }

    setState(() => _status = newStatus);
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_status != FaceDetectionStatus.faceReady) return;

    try {
      // Stop image stream before capturing
      await _cameraController!.stopImageStream();

      final image = await _cameraController!.takePicture();
      widget.onImageCaptured(File(image.path));
    } catch (e) {
      debugPrint('Capture error: $e');
      // Restart detection if capture fails
      _startFaceDetection();
    }
  }

  void _switchCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await _cameraController?.dispose();
    _initializeCamera();
  }

  String _getStatusMessage() {
    switch (_status) {
      case FaceDetectionStatus.initializing:
        return 'Starting camera...';
      case FaceDetectionStatus.noFace:
        return 'Position your face in the circle';
      case FaceDetectionStatus.faceOutsideCircle:
        return 'Move face inside the circle';
      case FaceDetectionStatus.faceTooFar:
        return 'Move closer to the camera';
      case FaceDetectionStatus.faceTooClose:
        return 'Move back a little';
      case FaceDetectionStatus.multipleFaces:
        return 'Only one face please';
      case FaceDetectionStatus.faceReady:
        return 'Perfect! Tap to capture';
    }
  }

  Color _getStatusColor() {
    switch (_status) {
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
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI SKIN LAB',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Position your face',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Switch camera button
                  GestureDetector(
                    onTap: _switchCamera,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios_outlined,
                        size: 20,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Camera preview with overlay
            Expanded(
              child: Container(
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
                      // Camera preview
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

                      // Face circle overlay
                      CustomPaint(
                        painter: _FaceCircleOverlayPainter(
                          status: _status,
                          circleRadiusFactor: _circleRadiusFactor,
                        ),
                        size: Size.infinite,
                      ),

                      // Status message at bottom
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _getStatusColor().withValues(alpha: 0.5),
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
                                  color: _getStatusColor(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _getStatusMessage(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bottom action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  // Back button
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

                  // Capture button
                  Expanded(
                    child: GestureDetector(
                      onTap: _status == FaceDetectionStatus.faceReady
                          ? _captureImage
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 56,
                        decoration: BoxDecoration(
                          color: _status == FaceDetectionStatus.faceReady
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _status == FaceDetectionStatus.faceReady
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
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
                              color: _status == FaceDetectionStatus.faceReady
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Capture',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: _status == FaceDetectionStatus.faceReady
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Face circle overlay painter
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

    // Semi-transparent overlay outside the circle
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Create path for overlay with hole in center
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    // Circle border
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

    // Animated glow effect for ready state
    if (status == FaceDetectionStatus.faceReady) {
      final glowPaint = Paint()
        ..color = AppColors.sage.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(center, radius, glowPaint);
    }

    // Corner guides
    _drawCornerGuides(canvas, center, radius, borderColor);
  }

  void _drawCornerGuides(Canvas canvas, Offset center, double radius, Color color) {
    final guidePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const guideLength = 20.0;
    const offset = 0.707; // cos(45°)

    // Top-left
    final tl = Offset(center.dx - radius * offset, center.dy - radius * offset);
    canvas.drawLine(tl, Offset(tl.dx + guideLength, tl.dy), guidePaint);
    canvas.drawLine(tl, Offset(tl.dx, tl.dy + guideLength), guidePaint);

    // Top-right
    final tr = Offset(center.dx + radius * offset, center.dy - radius * offset);
    canvas.drawLine(tr, Offset(tr.dx - guideLength, tr.dy), guidePaint);
    canvas.drawLine(tr, Offset(tr.dx, tr.dy + guideLength), guidePaint);

    // Bottom-left
    final bl = Offset(center.dx - radius * offset, center.dy + radius * offset);
    canvas.drawLine(bl, Offset(bl.dx + guideLength, bl.dy), guidePaint);
    canvas.drawLine(bl, Offset(bl.dx, bl.dy - guideLength), guidePaint);

    // Bottom-right
    final br = Offset(center.dx + radius * offset, center.dy + radius * offset);
    canvas.drawLine(br, Offset(br.dx - guideLength, br.dy), guidePaint);
    canvas.drawLine(br, Offset(br.dx, br.dy - guideLength), guidePaint);
  }

  @override
  bool shouldRepaint(covariant _FaceCircleOverlayPainter oldDelegate) {
    return oldDelegate.status != status;
  }
}
