import 'package:flutter/material.dart';
import 'package:skin_sync/core/constants/color_const.dart';

class ArtHeader extends StatelessWidget {
  final String emoji;

  const ArtHeader({super.key, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      color: const Color(0xFF2A2118),
      child: Stack(
        children: [
          // Terracotta radial — top left
          Positioned(
            top: -30,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Rose radial — bottom right
          Positioned(
            bottom: -50,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.rose.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Outline ring
          Positioned(
            top: 40,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          // Concentric rings for texture
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width / 2 - 80,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.04),
                ),
              ),
            ),
          ),
          // Wave line
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 230),
            painter: _WaveLinePainter(),
          ),
          // Emoji centered bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(0, 120);
    path1.quadraticBezierTo(size.width / 2, 80, size.width, 120);
    canvas.drawPath(path1, paint);

    final paint2 = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final path2 = Path();
    path2.moveTo(0, 150);
    path2.quadraticBezierTo(size.width / 2, 110, size.width, 150);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WaveLinePainter _) => false;
}
