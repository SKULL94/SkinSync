import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/face_camera_bloc.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';
import 'package:skin_sync/features/skin_analysis/presentation/widgets/face_camera_view.dart';

class SkinAnalysisPage extends StatelessWidget {
  const SkinAnalysisPage({super.key});

  int _getSeverityColorValue(String severity) {
    return switch (severity.toLowerCase()) {
      'mild' => 0xFF4CAF50,
      'moderate' => 0xFFFF9800,
      'severe' => 0xFFF44336,
      'needs_dermatologist' => 0xFF9C27B0,
      _ => 0xFF9E9E9E,
    };
  }

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
          SnackbarHelper.showSuccess(
              context, StringConst.kAnalysisSavedSuccess);

          // Optimistically add to history with local image path
          if (state.selectedImage != null && state.aiAnalysis != null) {
            final ai = state.aiAnalysis!;
            final historyEntity = HistoryEntity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              imageUrl: state.selectedImage!.path,
              results: [
                {
                  'displayLabel': 'Skin Health Score',
                  'confidence': ai.overallScore / 100.0,
                  'riskLevel': ai.severity,
                  'riskColorValue': _getSeverityColorValue(ai.severity),
                },
              ],
              date: DateTime.now(),
              aiAnalysis: ai.toJson(),
            );
            context
                .read<HistoryBloc>()
                .add(HistoryAddOptimistic(historyEntity));
          }

          context.read<LayoutBloc>().add(const LayoutTabChanged(1));
          context.go(AppRoutes.layoutRoute);
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

        if (state.selectedImage != null && state.aiAnalysis != null) {
          return _ResultsView(state: state);
        }

        return BlocProvider(
          create: (_) => sl<FaceCameraBloc>(),
          child: FaceCameraView(
            onImageCaptured: (imageFile) {
              context.read<SkinAnalysisBloc>().add(
                    SkinAnalysisImageSelected(imageFile),
                  );
            },
            onBack: () => context.pop(),
          ),
        );
      },
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

  List<String> get _steps => widget.isAIAnalyzing
      ? [
          StringConst.kConnectingToAi,
          StringConst.kAnalyzingSkinTexture,
          StringConst.kEvaluatingSkinHealth,
          StringConst.kDetectingConcerns,
          StringConst.kGeneratingInsights,
          StringConst.kPreparingRecommendations,
        ]
      : [
          StringConst.kValidatingImage,
          StringConst.kDetectingSkinRegions,
          StringConst.kInitialAnalysis,
          StringConst.kPreparingForAi,
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
        final bloc = context.read<SkinAnalysisBloc>();
        if (newStep != bloc.state.scanningStep && newStep < _steps.length) {
          bloc.add(SkinAnalysisScanningStepChanged(newStep));
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
    return BlocBuilder<SkinAnalysisBloc, SkinAnalysisState>(
      buildWhen: (previous, current) =>
          previous.scanningStep != current.scanningStep,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.ink,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.image != null)
                Opacity(
                  opacity: 0.3,
                  child: Image.file(widget.image!, fit: BoxFit.cover),
                ),
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
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSpinner(),
                      const SizedBox(height: 32),
                      Text(
                        widget.isAIAnalyzing
                            ? StringConst.kAiAnalysing
                            : StringConst.kValidating,
                        style: AppTextStyles.heading2.copyWith(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          color: AppColors.background,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _steps[
                              state.scanningStep.clamp(0, _steps.length - 1)],
                          key: ValueKey(state.scanningStep),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildProgressBar(),
                      const SizedBox(height: 16),
                      _buildStepDots(state.scanningStep),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpinner() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
                      color: AppColors.primary.withValues(alpha: 0.1),
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
                      color: AppColors.rose.withValues(alpha: 0.08),
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
                      color: AppColors.sage.withValues(alpha: 0.08),
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
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF3D3025),
            ),
            child: Icon(
              Icons.face_outlined,
              size: 26,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
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
    );
  }

  Widget _buildStepDots(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _steps.length,
        (index) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= currentStep
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }
}

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

  // int _getMetricFromAI(AIAnalysisModel? ai, String metric, int defaultValue) {
  //   if (ai == null) return defaultValue;
  //   switch (metric.toLowerCase()) {
  //     case 'hydration':
  //       return ai.metrics.hydration;
  //     case 'texture':
  //       return ai.metrics.texture;
  //     case 'clarity':
  //       return ai.metrics.clarity;
  //     case 'oiliness':
  //       return ai.metrics.oiliness;
  //     case 'pores':
  //     case 'pore_visibility':
  //       return ai.metrics.poreVisibility;
  //     case 'firmness':
  //       return ai.metrics.firmness;
  //     default:
  //       return defaultValue;
  //   }
  // }

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
      return StringConst.kHydrationExcellent;
    } else if (value >= 50) {
      return StringConst.kHydrationModerate;
    } else {
      return StringConst.kHydrationLow;
    }
  }

  String _getTextureDescription(int value) {
    if (value >= 70) {
      return StringConst.kTextureExcellent;
    } else if (value >= 50) {
      return StringConst.kTextureModerate;
    } else {
      return StringConst.kTextureLow;
    }
  }

  String _getClarityDescription(int value) {
    if (value >= 70) {
      return StringConst.kClarityExcellent;
    } else if (value >= 50) {
      return StringConst.kClarityModerate;
    } else {
      return StringConst.kClarityLow;
    }
  }

  String _getPoreDescription(int value) {
    if (value <= 30) {
      return StringConst.kPoreMinimal;
    } else if (value <= 60) {
      return StringConst.kPoreNormal;
    } else {
      return StringConst.kPoreEnlarged;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ai = state.aiAnalysis!;
    final overallScore = ai.overallScore;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (state.selectedImage != null)
            Opacity(
              opacity: 0.4,
              child: Image.file(state.selectedImage!, fit: BoxFit.cover),
            ),
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
                        _buildScoreHeader(overallScore),
                        const SizedBox(height: 20),
                        _buildBadges(ai),
                        const SizedBox(height: 16),
                        _buildMetricTags(ai),
                        const SizedBox(height: 20),
                        if (ai.aiInsight != null) ...[
                          _buildAIInsight(ai),
                          const SizedBox(height: 16),
                        ],
                        _buildDisclaimer(ai),
                        const SizedBox(height: 24),
                        if (ai.detectedConcerns.isNotEmpty) ...[
                          _buildDetectedConcerns(ai),
                          const SizedBox(height: 24),
                        ],
                        _buildDetailedAnalysis(ai),
                        if (ai.recommendations.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildRecommendations(ai),
                        ],
                        if (ai.ingredientsToLookFor.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildIngredients(ai),
                        ],
                        const SizedBox(height: 24),
                        _buildSaveButton(context),
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

  Widget _buildScoreHeader(int overallScore) {
    return Row(
      children: [
        _ScoreRing(score: overallScore),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
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
                      StringConst.kAnalysisComplete,
                      style: AppTextStyles.caption.copyWith(
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
                StringConst.kYourSkinHealth,
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM d, yyyy').format(DateTime.now()),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(AIAnalysisModel ai) {
    return Row(
      children: [
        _BadgeChip(label: ai.skinType.toUpperCase(), color: AppColors.primary),
        const SizedBox(width: 8),
        _BadgeChip(
          label: ai.severity.toUpperCase(),
          color: _getSeverityColor(ai.severity),
        ),
      ],
    );
  }

  Widget _buildMetricTags(AIAnalysisModel ai) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MetricTag(
            label: StringConst.kHydrationMetric,
            value: '${ai.metrics.hydration}%',
          ),
          const SizedBox(width: 8),
          _MetricTag(
            label: StringConst.kTextureMetric,
            value: '${ai.metrics.texture}%',
          ),
          const SizedBox(width: 8),
          _MetricTag(
            label: StringConst.kClarityMetric,
            value: '${ai.metrics.clarity}%',
          ),
          const SizedBox(width: 8),
          _MetricTag(
            label: StringConst.kOilinessMetric,
            value: '${ai.metrics.oiliness}%',
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight(AIAnalysisModel ai) {
    return Container(
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
                  StringConst.kAiInsight,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ai.aiInsight!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(AIAnalysisModel ai) {
    final needsWarning = ai.disclaimerRequired;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: needsWarning
            ? AppColors.rose.withValues(alpha: 0.08)
            : AppColors.sage.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: needsWarning
              ? AppColors.rose.withValues(alpha: 0.2)
              : AppColors.sage.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            needsWarning ? Icons.warning_amber_outlined : Icons.info_outline,
            size: 16,
            color: needsWarning ? AppColors.rose : AppColors.sage,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              needsWarning
                  ? StringConst.kConsultDermatologist
                  : StringConst.kAiDisclaimer,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedConcerns(AIAnalysisModel ai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.kDetectedConcerns,
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.rose.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.rose.withValues(alpha: 0.2)),
              ),
              child: Text(
                concern,
                style:
                    AppTextStyles.labelMedium.copyWith(color: AppColors.rose),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailedAnalysis(AIAnalysisModel ai) {
    final hydrationValue = ai.metrics.hydration;
    final textureValue = ai.metrics.texture;
    final clarityValue = ai.metrics.clarity;
    final poreValue = ai.metrics.poreVisibility;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.kDetailedAnalysis,
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _DetailedMetricCard(
          title: StringConst.kHydrationMetric,
          value: hydrationValue,
          description: _getHydrationDescription(hydrationValue),
          color: AppColors.sage,
        ),
        const SizedBox(height: 12),
        _DetailedMetricCard(
          title: StringConst.kTextureMetric,
          value: textureValue,
          description: _getTextureDescription(textureValue),
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _DetailedMetricCard(
          title: StringConst.kClarityMetric,
          value: clarityValue,
          description: _getClarityDescription(clarityValue),
          color: AppColors.rose,
        ),
        const SizedBox(height: 12),
        _DetailedMetricCard(
          title: StringConst.kPoreVisibility,
          value: poreValue,
          description: _getPoreDescription(poreValue),
          color: AppColors.amber,
        ),
      ],
    );
  }

  Widget _buildRecommendations(AIAnalysisModel ai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.kRecommendations,
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...ai.recommendations.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RecommendationCard(index: entry.key + 1, text: entry.value),
          );
        }),
      ],
    );
  }

  Widget _buildIngredients(AIAnalysisModel ai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.kIngredientsToLookFor,
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.sage.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.sage.withValues(alpha: 0.3)),
              ),
              child: Text(
                ingredient,
                style:
                    AppTextStyles.labelMedium.copyWith(color: AppColors.sage),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SkinAnalysisBloc>().add(const SkinAnalysisSaveRequested());
      },
      child: Container(
        width: double.infinity,
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
        child: Center(
          child: Text(
            StringConst.kSaveAnalysis,
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

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
          const SizedBox(
            width: 86,
            height: 86,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cardBorder),
            ),
          ),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 28,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '/100',
                style: AppTextStyles.caption.copyWith(
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
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

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
                style: AppTextStyles.labelMedium.copyWith(
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
                  style: AppTextStyles.labelSmall.copyWith(
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

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
        style: AppTextStyles.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

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
                style: AppTextStyles.labelSmall.copyWith(
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
              style: AppTextStyles.bodySmall.copyWith(
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
