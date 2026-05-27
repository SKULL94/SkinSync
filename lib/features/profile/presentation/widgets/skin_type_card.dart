import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
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
    {'key': 'oily', 'emoji': '💧', 'label': StringConst.kOily},
    {'key': 'combo', 'emoji': '⚖️', 'label': StringConst.kCombo},
    {'key': 'dry', 'emoji': '🌵', 'label': StringConst.kDry},
    {'key': 'normal', 'emoji': '🌸', 'label': StringConst.kNormal},
  ];

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
                StringConst.kMySkinType,
                style: AppTextStyles.heading3.copyWith(fontSize: 17),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.skinTypeRoute),
                child: Text(
                  StringConst.kEdit,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(_types.length, (i) {
              final type = _types[i];
              final sel = selectedType == type['key'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged(type['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFFF0D4C2) : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.cardBorder,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          type['emoji'] as String,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          type['label'] as String,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: sel
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
