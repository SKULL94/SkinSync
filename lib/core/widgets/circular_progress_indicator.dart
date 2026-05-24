import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:skin_sync/core/constants/color_const.dart';

/// A custom circular progress indicator with percentage display
class CircularProgressWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.child,
    this.showPercentage = true,
    this.percentageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveProgressColor = progressColor ?? AppColors.primary;
    final effectiveBackgroundColor = backgroundColor ??
        (isDark ? AppColors.darkCardBorder : AppColors.cardBorder);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveBackgroundColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center content
          if (child != null)
            child!
          else if (showPercentage)
            Text(
              '${(progress * 100).toInt()}%',
              style: percentageStyle ??
                  TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
                  ),
            ),
        ],
      ),
    );
  }
}

/// A custom painted circular progress with gradient support
class GradientCircularProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final Widget? child;

  const GradientCircularProgress({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.gradientColors,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveGradientColors = gradientColors ??
        [AppColors.primaryLight, AppColors.primary];
    final effectiveBackgroundColor = backgroundColor ??
        (isDark ? AppColors.darkCardBorder : AppColors.cardBorder);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GradientCircularProgressPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              gradientColors: effectiveGradientColors,
              backgroundColor: effectiveBackgroundColor,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  _GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc with gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: gradientColors,
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// A mini circular indicator for metrics
class MiniCircularIndicator extends StatelessWidget {
  final double progress;
  final double size;
  final Color? color;

  const MiniCircularIndicator({
    super.key,
    required this.progress,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressWidget(
      progress: progress,
      size: size,
      strokeWidth: 4,
      progressColor: color,
      showPercentage: false,
    );
  }
}
