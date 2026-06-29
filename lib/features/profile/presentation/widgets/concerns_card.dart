import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';

class ConcernsCard extends StatelessWidget {
  final List<String> selectedConcerns;
  final ValueChanged<List<String>> onConcernsChanged;

  const ConcernsCard({
    super.key,
    required this.selectedConcerns,
    required this.onConcernsChanged,
  });

  static const _allConcerns = [
    StringConst.kAcne,
    StringConst.kDarkSpots,
    StringConst.kPores,
    StringConst.kWrinkles,
    StringConst.kDryness,
    StringConst.kRedness,
  ];

  void _toggle(String concern) {
    final updated = List<String>.from(selectedConcerns);
    if (updated.contains(concern)) {
      updated.remove(concern);
    } else {
      updated.add(concern);
    }
    onConcernsChanged(updated);
  }

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
                StringConst.kMyConcerns,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.16,
                ),
              ),
              Text(
                '${selectedConcerns.length} selected',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allConcerns.map((concern) {
              final sel = selectedConcerns.contains(concern);
              return GestureDetector(
                onTap: () => _toggle(concern),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primaryTint : AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.hairline,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    concern,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      fontWeight:
                          sel ? FontWeight.w600 : FontWeight.w400,
                      color: sel
                          ? AppColors.primaryTintInk
                          : AppColors.textTertiary,
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
