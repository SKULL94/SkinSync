import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
import 'package:skin_sync/core/routes/app_routes.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.person_outline,
            iconBg: const Color(0xFFF0D4C2),
            iconColor: AppColors.primary,
            label: StringConst.kPersonalDetails,
            value: StringConst.kNameAgeGender,
            onTap: () => context.push(AppRoutes.personalDetailsRoute),
          ),
          const _Divider(),
          _SettingRow(
            icon: Icons.notifications_outlined,
            iconBg: const Color(0xFFEDD8D8),
            iconColor: AppColors.rose,
            label: StringConst.kScanReminders,
            value: StringConst.kEveryDays,
            onTap: () => context.push(AppRoutes.scanRemindersRoute),
          ),
          const _Divider(),
          // _SettingRow(
          //   icon: Icons.shield_outlined,
          //   iconBg: const Color(0xFFD4E3CC),
          //   iconColor: AppColors.sage,
          //   label: StringConst.kPrivacyData,
          //   value: StringConst.kManageYourData,
          //   onTap: () => context.push(AppRoutes.privacyRoute),
          // ),
          // const _Divider(),
          // _SettingRow(
          //   icon: Icons.wb_sunny_outlined,
          //   iconBg: const Color(0xFFF5DCA8),
          //   iconColor: AppColors.amber,
          //   label: StringConst.kAppearance,
          //   value: StringConst.kLightMode,
          //   onTap: () => context.push(AppRoutes.appearanceRoute),
          // ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      height: 1,
      color: AppColors.cardBorder,
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, size: 16, color: iconColor)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
