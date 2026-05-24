import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/analysis_result_entity.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/ai_analysis_entity.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';

class SkinAnalysisPage extends StatelessWidget {
  const SkinAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SkinAnalysisBloc, SkinAnalysisState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SkinAnalysisStatus.failure &&
            state.errorMessage != null) {
          SnackbarHelper.showError(context, state.errorMessage!);
        }
        if (state.status == SkinAnalysisStatus.saved) {
          SnackbarHelper.showSuccess(context, 'Analysis saved successfully');
          context.read<HistoryBloc>().add(const HistoryLoadRequested());
        }
      },
      builder: (context, state) {
        if (state.status == SkinAnalysisStatus.validating ||
            state.status == SkinAnalysisStatus.analyzingWithAI) {
          return _ScanningView(
            image: state.selectedImage,
            isAIAnalyzing: state.status == SkinAnalysisStatus.analyzingWithAI,
          );
        }

        if (state.selectedImage != null &&
            (state.results.isNotEmpty || state.aiAnalysis != null)) {
          return _ResultsView(state: state);
        }

        return const _InitialView();
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INITIAL VIEW - AI SKIN LAB
// ═══════════════════════════════════════════════════════════════════════════

class _InitialView extends StatefulWidget {
  const _InitialView();

  @override
  State<_InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends State<_InitialView>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedConcerns = {'Acne'};
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  final _concerns = [
    'Acne',
    'Dryness',
    'Oiliness',
    'Dark spots',
    'Wrinkles',
    'Redness',
    'Pores',
    'Uneven tone',
  ];

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title block
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
                      const SizedBox(height: 6),
                      Text(
                        'Scan your skin,',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'get smart care',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  // Menu button
                  GestureDetector(
                    onTap: () => _showTips(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Camera viewport
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
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
                      // Skin tone gradient background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(0, -0.2),
                            radius: 1.2,
                            colors: [
                              Color(0xFFD4A882),
                              Color(0xFFC49070),
                              Color(0xFFA87858),
                              Color(0xFF7A5038),
                              Color(0xFF4A3020),
                            ],
                            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                          ),
                        ),
                      ),

                      // Hair gradient top
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF3A2818),
                                const Color(0xFF3A2818).withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                        ),
                      ),

                      // Bottom shadow/neck gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFF2A2118).withValues(alpha: 0.8),
                                const Color(0xFF2A2118).withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Face mesh overlay with animation
                      AnimatedBuilder(
                        animation: _scanLineAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _FaceMeshPainter(
                              scanProgress: _scanLineAnimation.value,
                            ),
                            size: Size.infinite,
                          );
                        },
                      ),

                      // Corner brackets
                      const _CornerBrackets(),

                      // Animated scan line
                      AnimatedBuilder(
                        animation: _scanLineAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 +
                                (_scanLineAnimation.value *
                                    (MediaQuery.of(context).size.height * 0.4)),
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary.withValues(alpha: 0.6),
                                    AppColors.primary.withValues(alpha: 0.9),
                                    AppColors.primary.withValues(alpha: 0.6),
                                    Colors.transparent,
                                  ],
                                  stops: const [0, 0.2, 0.5, 0.8, 1],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Metric bubbles at bottom
                      const Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _MetricBubble(
                                label: 'Hydration',
                                value: 'Good',
                                color: Color(0xFF6DBF5E),
                              ),
                              _MetricBubble(
                                label: 'Acne',
                                value: 'Low',
                                color: Color(0xFF5DC4A8),
                              ),
                              _MetricBubble(
                                label: 'Sensitivity',
                                value: 'Medium',
                                color: Color(0xFFD4A84A),
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

            const SizedBox(height: 16),

            // Focus Areas section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FOCUS AREAS',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: _concerns.map((concern) {
                      final isSelected = _selectedConcerns.contains(concern);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedConcerns.remove(concern);
                            } else {
                              _selectedConcerns.add(concern);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            concern,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 52,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Keep Scanning button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickImage(context, ImageSource.camera),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Keep Scanning',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Upload button
                  GestureDetector(
                    onTap: () => _pickImage(context, ImageSource.gallery),
                    child: Container(
                      width: 52,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.ios_share,
                        size: 20,
                        color: AppColors.textSecondary,
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

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null && context.mounted) {
      context.read<SkinAnalysisBloc>().add(
            SkinAnalysisImageSelected(File(pickedFile.path)),
          );
    }
  }

  void _showTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tips for Best Results',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const _TipItem(
                icon: Icons.wb_sunny_outlined, text: 'Use natural lighting'),
            const _TipItem(icon: Icons.face, text: 'Remove makeup if possible'),
            const _TipItem(
                icon: Icons.center_focus_strong,
                text: 'Keep face centered in frame'),
            const _TipItem(
                icon: Icons.photo_camera, text: 'Hold camera steady'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Corner brackets overlay
class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top left
        Positioned(
          top: 16,
          left: 16,
          child: _CornerBracket(isTop: true, isLeft: true),
        ),
        // Top right
        Positioned(
          top: 16,
          right: 16,
          child: _CornerBracket(isTop: true, isLeft: false),
        ),
        // Bottom left
        Positioned(
          bottom: 100,
          left: 16,
          child: _CornerBracket(isTop: false, isLeft: true),
        ),
        // Bottom right
        Positioned(
          bottom: 100,
          right: 16,
          child: _CornerBracket(isTop: false, isLeft: false),
        ),
      ],
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerBracket({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 2)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 2)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 2)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 2)
              : BorderSide.none,
        ),
      ),
    );
  }
}

// Face mesh painter
class _FaceMeshPainter extends CustomPainter {
  final double scanProgress;

  _FaceMeshPainter({required this.scanProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.42;
    final faceWidth = size.width * 0.55;
    final faceHeight = size.height * 0.48;

    // Dashed line paint
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw face oval outline (dashed)
    _drawDashedOval(
      canvas,
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: faceWidth,
        height: faceHeight,
      ),
      dashPaint,
    );

    // Draw horizontal lines across face
    final lineY1 = centerY - faceHeight * 0.25; // Eyes level
    final lineY2 = centerY - faceHeight * 0.05; // Nose level
    final lineY3 = centerY + faceHeight * 0.15; // Mouth level

    // Eye level ovals (small)
    _drawSmallOval(canvas, centerX - faceWidth * 0.18, lineY1, dashPaint);
    _drawSmallOval(canvas, centerX + faceWidth * 0.18, lineY1, dashPaint);

    // Nose oval
    _drawSmallOval(canvas, centerX, lineY2, dashPaint, widthScale: 0.6);

    // Mouth line
    _drawSmallOval(canvas, centerX, lineY3, dashPaint, widthScale: 1.2);

    // Draw connecting lines (hexagon-like pattern)
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Define mesh points
    final points = <Offset>[
      // Top
      Offset(centerX, centerY - faceHeight * 0.42),
      // Eyes row
      Offset(centerX - faceWidth * 0.35, lineY1),
      Offset(centerX - faceWidth * 0.18, lineY1),
      Offset(centerX, lineY1 - 10),
      Offset(centerX + faceWidth * 0.18, lineY1),
      Offset(centerX + faceWidth * 0.35, lineY1),
      // Nose row
      Offset(centerX - faceWidth * 0.25, lineY2),
      Offset(centerX, lineY2),
      Offset(centerX + faceWidth * 0.25, lineY2),
      // Mouth row
      Offset(centerX - faceWidth * 0.2, lineY3),
      Offset(centerX, lineY3),
      Offset(centerX + faceWidth * 0.2, lineY3),
      // Chin
      Offset(centerX, centerY + faceHeight * 0.38),
      // Sides
      Offset(centerX - faceWidth * 0.45, centerY),
      Offset(centerX + faceWidth * 0.45, centerY),
    ];

    // Draw connecting lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    canvas.drawLine(points[1], points[5], linePaint);
    canvas.drawLine(points[6], points[8], linePaint);
    canvas.drawLine(points[9], points[11], linePaint);

    // Vertical center line
    canvas.drawLine(points[0], points[3], linePaint);
    canvas.drawLine(points[3], points[7], linePaint);
    canvas.drawLine(points[7], points[10], linePaint);
    canvas.drawLine(points[10], points[12], linePaint);

    // Diagonal lines
    canvas.drawLine(points[0], points[1], linePaint);
    canvas.drawLine(points[0], points[5], linePaint);
    canvas.drawLine(points[1], points[13], linePaint);
    canvas.drawLine(points[5], points[14], linePaint);
    canvas.drawLine(points[13], points[9], linePaint);
    canvas.drawLine(points[14], points[11], linePaint);
    canvas.drawLine(points[9], points[12], linePaint);
    canvas.drawLine(points[11], points[12], linePaint);

    // Draw dots at intersection points
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      // Inner darker dot
      canvas.drawCircle(
        point,
        2,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  void _drawDashedOval(Canvas canvas, Rect rect, Paint paint) {
    final path = Path()..addOval(rect);
    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;

    const dashLength = 8.0;
    const gapLength = 6.0;

    double distance = 0;
    while (distance < totalLength) {
      final start = distance;
      final end = (distance + dashLength).clamp(0, totalLength);
      final extractPath = metrics.extractPath(start, end.toDouble());
      canvas.drawPath(extractPath, paint);
      distance += dashLength + gapLength;
    }
  }

  void _drawSmallOval(Canvas canvas, double x, double y, Paint paint,
      {double widthScale = 1.0}) {
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: 35 * widthScale,
      height: 18,
    );
    _drawDashedOval(canvas, rect, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceMeshPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress;
  }
}

// Metric bubble widget
class _MetricBubble extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricBubble({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.75),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 0.8,
              colors: [
                color.withValues(alpha: 1.0),
                color.withValues(alpha: 0.85),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gloss effect
              Positioned(
                top: 8,
                left: 14,
                child: Container(
                  width: 18,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
              // Value text
              Center(
                child: Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Tip item for bottom sheet
class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SCANNING VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _ScanningView extends StatefulWidget {
  final File? image;
  final bool isAIAnalyzing;

  const _ScanningView({this.image, this.isAIAnalyzing = false});

  @override
  State<_ScanningView> createState() => _ScanningViewState();
}

class _ScanningViewState extends State<_ScanningView>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _progressController;
  int _currentStep = 0;

  List<String> get _steps => widget.isAIAnalyzing
      ? [
          'Connecting to AI...',
          'Analyzing skin texture',
          'Evaluating skin health',
          'Detecting concerns',
          'Generating insights',
          'Preparing recommendations...',
        ]
      : [
          'Validating image...',
          'Detecting skin regions',
          'Initial analysis',
          'Preparing for AI...',
        ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..addListener(() {
        final newStep = (_progressController.value * _steps.length).floor();
        if (newStep != _currentStep && newStep < _steps.length) {
          setState(() => _currentStep = newStep);
        }
      });

    _progressController.forward();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (widget.image != null)
            Opacity(
              opacity: 0.3,
              child: Image.file(
                widget.image!,
                fit: BoxFit.cover,
              ),
            ),

          // Glow effect
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Spinner
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        AnimatedBuilder(
                          animation: _spinController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _spinController.value * 2 * math.pi,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    width: 1.5,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _RingPainter(
                                    color: AppColors.primary,
                                    strokeWidth: 1.5,
                                    sweepAngle: math.pi / 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Middle ring
                        AnimatedBuilder(
                          animation: _spinController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: -_spinController.value * 2 * math.pi * 0.7,
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        AppColors.rose.withValues(alpha: 0.08),
                                    width: 1.5,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _RingPainter(
                                    color: AppColors.rose,
                                    strokeWidth: 1.5,
                                    sweepAngle: math.pi / 3,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Inner ring
                        AnimatedBuilder(
                          animation: _spinController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _spinController.value * 2 * math.pi * 0.5,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        AppColors.sage.withValues(alpha: 0.08),
                                    width: 1,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _RingPainter(
                                    color: AppColors.sage,
                                    strokeWidth: 1,
                                    sweepAngle: math.pi / 4,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Core
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF3D3025),
                          ),
                          child: Icon(
                            Icons.face_outlined,
                            size: 26,
                            color: AppColors.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    widget.isAIAnalyzing ? 'AI Analysing' : 'Validating',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: AppColors.background,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Current step
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _steps[_currentStep],
                      key: ValueKey(_currentStep),
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress bar
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Container(
                        width: 180,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressController.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Step dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= _currentStep
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Ring painter for spinner
class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double sweepAngle;

  _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULTS VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _ResultsView extends StatelessWidget {
  final SkinAnalysisState state;

  const _ResultsView({required this.state});

  int _getMetricFromAI(AIAnalysisEntity? ai, String metric, int defaultValue) {
    if (ai == null) return defaultValue;
    switch (metric.toLowerCase()) {
      case 'hydration':
        return ai.metrics.hydration;
      case 'texture':
        return ai.metrics.texture;
      case 'clarity':
        return ai.metrics.clarity;
      case 'oiliness':
        return ai.metrics.oiliness;
      case 'pores':
      case 'pore_visibility':
        return ai.metrics.poreVisibility;
      case 'firmness':
        return ai.metrics.firmness;
      default:
        return defaultValue;
    }
  }

  int _getMetricValue(
      List<AnalysisResultEntity> results, String label, int defaultValue) {
    final result = results
        .where((r) => r.displayLabel.toLowerCase() == label.toLowerCase())
        .firstOrNull;
    if (result != null) {
      return (result.confidence * 100).toInt();
    }
    return defaultValue;
  }

  int _calculateOverallScore(List<AnalysisResultEntity> results) {
    if (results.isEmpty) return 75;
    final totalConfidence =
        results.fold<double>(0, (sum, r) => sum + r.confidence);
    return ((totalConfidence / results.length) * 100).toInt();
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return AppColors.sage;
      case 'moderate':
        return AppColors.amber;
      case 'severe':
      case 'needs_dermatologist':
        return AppColors.rose;
      default:
        return AppColors.sage;
    }
  }

  String _getHydrationDescription(int value) {
    if (value >= 70) {
      return 'Your skin shows excellent hydration levels. Continue with your current moisturizing routine.';
    } else if (value >= 50) {
      return 'Your skin has moderate hydration. Consider adding a hydrating serum or more frequent moisturizing.';
    } else {
      return 'Your skin appears dehydrated. Increase water intake and use hydrating products with hyaluronic acid.';
    }
  }

  String _getTextureDescription(int value) {
    if (value >= 70) {
      return 'Skin texture is smooth and even. Maintain your current routine.';
    } else if (value >= 50) {
      return 'Skin texture is fairly smooth. Consider gentle exfoliation to improve further.';
    } else {
      return 'Skin texture could use improvement. Try incorporating AHAs or BHAs for gentle exfoliation.';
    }
  }

  String _getClarityDescription(int value) {
    if (value >= 70) {
      return 'Excellent skin clarity with minimal blemishes. Keep up your skincare routine.';
    } else if (value >= 50) {
      return 'Some minor blemishes detected. A consistent cleansing routine can help improve clarity.';
    } else {
      return 'Notable skin concerns detected. Consider targeted treatments and consult a dermatologist if needed.';
    }
  }

  String _getPoreDescription(int value) {
    if (value <= 30) {
      return 'Pores are minimally visible. Your skin texture appears refined.';
    } else if (value <= 60) {
      return 'Normal pore visibility. Niacinamide can help minimize pore appearance.';
    } else {
      return 'Enlarged pores visible. Consider pore-minimizing products and regular cleansing.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = state.results;
    final ai = state.aiAnalysis;
    final overallScore = ai?.overallScore ?? _calculateOverallScore(results);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (state.selectedImage != null)
            Opacity(
              opacity: 0.4,
              child: Image.file(
                state.selectedImage!,
                fit: BoxFit.cover,
              ),
            ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.ink.withValues(alpha: 0.7),
                  AppColors.ink,
                ],
                stops: const [0.0, 0.4, 0.7],
              ),
            ),
          ),

          // Decorative radials
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            child: GestureDetector(
              onTap: () {
                context.read<SkinAnalysisBloc>().add(const SkinAnalysisReset());
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.cardBorder,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Score section
                        Row(
                          children: [
                            // Score ring
                            _ScoreRing(score: overallScore),
                            const SizedBox(width: 18),
                            // Title
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ANALYSIS COMPLETE',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1.5,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Your Skin Health',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMMM d, yyyy').format(DateTime.now()),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.textTertiary,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Skin type and severity badges (if AI analysis available)
                        if (ai != null) ...[
                          Row(
                            children: [
                              _BadgeChip(
                                label: ai.skinType.toUpperCase(),
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              _BadgeChip(
                                label: ai.severity.toUpperCase(),
                                color: _getSeverityColor(ai.severity),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Metric tags
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _MetricTag(
                                label: 'Hydration',
                                value: ai != null
                                    ? '${_getMetricFromAI(ai, 'hydration', 72)}%'
                                    : '${_getMetricValue(results, 'Hydration', 72)}%',
                              ),
                              const SizedBox(width: 8),
                              _MetricTag(
                                label: 'Texture',
                                value: ai != null
                                    ? '${_getMetricFromAI(ai, 'texture', 68)}%'
                                    : '${_getMetricValue(results, 'Texture', 68)}%',
                              ),
                              const SizedBox(width: 8),
                              _MetricTag(
                                label: 'Clarity',
                                value: ai != null
                                    ? '${_getMetricFromAI(ai, 'clarity', 65)}%'
                                    : '${_getMetricValue(results, 'Clarity', 65)}%',
                              ),
                              const SizedBox(width: 8),
                              _MetricTag(
                                label: 'Oiliness',
                                value: ai != null
                                    ? '${_getMetricFromAI(ai, 'oiliness', 45)}%'
                                    : '${_getMetricValue(results, 'Oiliness', 45)}%',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // AI Insight (if available)
                        if (ai?.aiInsight != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.08),
                                  AppColors.rose.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'AI Insight',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ai!.aiInsight!,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Disclaimer
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (ai?.disclaimerRequired ?? false)
                                ? AppColors.rose.withValues(alpha: 0.08)
                                : AppColors.sage.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: (ai?.disclaimerRequired ?? false)
                                  ? AppColors.rose.withValues(alpha: 0.2)
                                  : AppColors.sage.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                (ai?.disclaimerRequired ?? false)
                                    ? Icons.warning_amber_outlined
                                    : Icons.info_outline,
                                size: 16,
                                color: (ai?.disclaimerRequired ?? false)
                                    ? AppColors.rose
                                    : AppColors.sage,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  (ai?.disclaimerRequired ?? false)
                                      ? 'We recommend consulting a dermatologist for professional assessment.'
                                      : 'AI-powered insights. Not medical advice. Consult a dermatologist for concerns.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Detected Concerns (if AI analysis available)
                        if (ai != null && ai.detectedConcerns.isNotEmpty) ...[
                          Text(
                            'Detected Concerns',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ai.detectedConcerns.map((concern) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.rose.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.rose.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  concern,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.rose,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Detailed metrics
                        Text(
                          'Detailed Analysis',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _DetailedMetricCard(
                          title: 'Hydration',
                          value: ai != null
                              ? _getMetricFromAI(ai, 'hydration', 72)
                              : _getMetricValue(results, 'Hydration', 72),
                          description: _getHydrationDescription(
                              ai != null ? _getMetricFromAI(ai, 'hydration', 72) : 72),
                          color: AppColors.sage,
                        ),
                        const SizedBox(height: 12),
                        _DetailedMetricCard(
                          title: 'Texture',
                          value: ai != null
                              ? _getMetricFromAI(ai, 'texture', 68)
                              : _getMetricValue(results, 'Texture', 68),
                          description: _getTextureDescription(
                              ai != null ? _getMetricFromAI(ai, 'texture', 68) : 68),
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        _DetailedMetricCard(
                          title: 'Clarity',
                          value: ai != null
                              ? _getMetricFromAI(ai, 'clarity', 65)
                              : _getMetricValue(results, 'Clarity', 65),
                          description: _getClarityDescription(
                              ai != null ? _getMetricFromAI(ai, 'clarity', 65) : 65),
                          color: AppColors.rose,
                        ),
                        const SizedBox(height: 12),
                        _DetailedMetricCard(
                          title: 'Pore Visibility',
                          value: ai != null
                              ? _getMetricFromAI(ai, 'pore_visibility', 50)
                              : 50,
                          description: _getPoreDescription(
                              ai != null ? _getMetricFromAI(ai, 'pore_visibility', 50) : 50),
                          color: AppColors.amber,
                        ),

                        // Recommendations (if AI analysis available)
                        if (ai != null && ai.recommendations.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Recommendations',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...ai.recommendations.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _RecommendationCard(
                                index: entry.key + 1,
                                text: entry.value,
                              ),
                            );
                          }),
                        ],

                        // Ingredients to look for (if AI analysis available)
                        if (ai != null && ai.ingredientsToLookFor.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Ingredients to Look For',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ai.ingredientsToLookFor.map((ingredient) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.sage.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.sage.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  ingredient,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.sage,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Save button
                        GestureDetector(
                          onTap: () {
                            context
                                .read<SkinAnalysisBloc>()
                                .add(const SkinAnalysisSaveRequested());
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Save Analysis',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Score ring widget
class _ScoreRing extends StatelessWidget {
  final int score;

  const _ScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 86,
            height: 86,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.cardBorder),
            ),
          ),
          // Progress ring
          SizedBox(
            width: 86,
            height: 86,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Score text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '/100',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Metric tag widget
class _MetricTag extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTag({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Detailed metric card
class _DetailedMetricCard extends StatelessWidget {
  final String title;
  final int value;
  final String description;
  final Color color;

  const _DetailedMetricCard({
    required this.title,
    required this.value,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$value%',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 5,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Badge chip for skin type and severity
class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Recommendation card
class _RecommendationCard extends StatelessWidget {
  final int index;
  final String text;

  const _RecommendationCard({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
