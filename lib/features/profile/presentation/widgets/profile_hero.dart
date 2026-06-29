import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';

class ProfileHero extends StatelessWidget {
  final String userName;
  final DateTime? memberSince;

  const ProfileHero({
    super.key,
    required this.userName,
    this.memberSince,
  });

  String _memberText(DateTime? date) {
    if (date == null) return StringConst.kMember;
    return '${StringConst.kMemberSince} ${DateFormat('MMM yyyy').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = userName.isNotEmpty ? userName : StringConst.kUser;
    final initial = displayName[0].toUpperCase();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepStart, AppColors.deepEnd],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Row(
                children: [
                  // Avatar circle
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.deepCore,
                      border: Border.all(
                        color: AppColors.accentBright.withValues(alpha: 0.45),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentBright,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _memberText(memberSince),
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.50),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Plan badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentBright.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.accentBright.withValues(alpha: 0.30),
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
                                  color: AppColors.accentBright,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                StringConst.kFreePlan,
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: AppColors.accentBright,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
