import 'package:flutter/material.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';

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

  void _toggleConcern(String concern) {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConst.kMyConcerns,
                style: AppTextStyles.heading3.copyWith(fontSize: 17),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0D4C2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 14, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allConcerns.map((concern) {
              final sel = selectedConcerns.contains(concern);
              return GestureDetector(
                onTap: () => _toggleConcern(concern),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFF0D4C2) : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Text(
                    concern,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 12,
                      color: sel ? AppColors.primary : AppColors.textTertiary,
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
