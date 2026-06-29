import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/routes/app_routes.dart';

class SkinTypeCard extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onTypeChanged;

  const SkinTypeCard({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  static const _types = [
    ('oily', StringConst.kOily),
    ('combo', StringConst.kCombo),
    ('dry', StringConst.kDry),
    ('normal', StringConst.kNormal),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConst.kMySkinType,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.16,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.skinTypeRoute),
                child: Text(
                  StringConst.kEdit,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: _types.asMap().entries.map((e) {
              final idx = e.key;
              final (key, label) = e.value;
              final sel = selectedType == key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(left: idx == 0 ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryTint : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.hairline,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          fontWeight:
                              sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
