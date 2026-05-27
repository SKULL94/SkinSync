import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/features/profile/presentation/bloc/scan_reminders_bloc.dart';
import 'package:skin_sync/features/profile/presentation/widgets/info_box.dart';
import 'package:skin_sync/features/profile/presentation/widgets/save_button.dart';
import 'package:skin_sync/features/profile/presentation/widgets/section_label.dart';
import 'package:skin_sync/features/profile/presentation/widgets/sub_header.dart';
import 'package:skin_sync/features/profile/presentation/widgets/toggle_widgets.dart';

class ScanRemindersPage extends StatelessWidget {
  const ScanRemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ScanRemindersBloc>()..add(const ScanRemindersLoadRequested()),
      child: const _ScanRemindersView(),
    );
  }
}

class _ScanRemindersView extends StatelessWidget {
  const _ScanRemindersView();

  static const _freqOptions = [
    StringConst.kDailyFreq,
    StringConst.kEvery7Days,
    StringConst.kEvery14Days,
    StringConst.kMonthlyFreq,
    StringConst.kCustom,
  ];

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _selectTime(BuildContext context, TimeOfDay currentTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      context.read<ScanRemindersBloc>().add(ScanRemindersTimeChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanRemindersBloc, ScanRemindersState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ScanRemindersStatus.success) {
          context.pop();
        }
      },
      builder: (context, state) {
        if (state.status == ScanRemindersStatus.loading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              SubHeader(
                superText: StringConst.kProfile,
                title: StringConst.kScanReminders,
                onBack: () => context.pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InfoBox(
                        icon: Icons.notifications_outlined,
                        text: StringConst.kScanRemindersInfo,
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel(StringConst.kReminders),
                      const SizedBox(height: 8),
                      _buildRemindersCard(context, state),
                      const SizedBox(height: 14),
                      const SectionLabel(StringConst.kReminderTime),
                      const SizedBox(height: 8),
                      _buildTimeCard(context, state),
                      const SizedBox(height: 14),
                      const SectionLabel(StringConst.kFrequency),
                      const SizedBox(height: 8),
                      _buildFrequencyCard(context, state),
                      const SizedBox(height: 14),
                      const SectionLabel(StringConst.kDaysOfWeek),
                      const SizedBox(height: 8),
                      _buildDaysCard(context, state),
                      const SizedBox(height: 24),
                      SaveButton(
                        label: StringConst.kSaveReminderSettings,
                        isLoading: state.status == ScanRemindersStatus.saving,
                        onTap: () => context
                            .read<ScanRemindersBloc>()
                            .add(const ScanRemindersSaveRequested()),
                      ),
                      const SizedBox(height: 16),
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

  Widget _buildRemindersCard(BuildContext context, ScanRemindersState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ToggleRow(
            label: StringConst.kEnableReminders,
            sub: StringConst.kPushNotifications,
            value: state.enableReminders,
            onChanged: (v) => context
                .read<ScanRemindersBloc>()
                .add(ScanRemindersEnableChanged(v)),
          ),
          ToggleRow(
            label: StringConst.kMorningReminder,
            sub: StringConst.kBestLighting,
            value: state.morningReminder,
            onChanged: (v) => context
                .read<ScanRemindersBloc>()
                .add(ScanRemindersMorningChanged(v)),
          ),
          ToggleRow(
            label: StringConst.kStreakAlerts,
            sub: StringConst.kStayOnTrack,
            value: state.streakAlerts,
            onChanged: (v) => context
                .read<ScanRemindersBloc>()
                .add(ScanRemindersStreakAlertsChanged(v)),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(BuildContext context, ScanRemindersState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              StringConst.kPreferredTime,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: () => _selectTime(context, state.preferredTime),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.formattedTime,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyCard(BuildContext context, ScanRemindersState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(_freqOptions.length, (i) {
          final sel = state.selectedFrequency == i;
          return GestureDetector(
            onTap: () => context
                .read<ScanRemindersBloc>()
                .add(ScanRemindersFrequencyChanged(i)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFF0D4C2) : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? AppColors.primary : AppColors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                _freqOptions[i],
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12,
                  color: sel ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDaysCard(BuildContext context, ScanRemindersState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        children: List.generate(_days.length, (i) {
          final active = state.activeDays.contains(i);
          return Expanded(
            child: GestureDetector(
              onTap: () => context
                  .read<ScanRemindersBloc>()
                  .add(ScanRemindersDayToggled(i)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                height: 38,
                decoration: BoxDecoration(
                  color:
                      active ? const Color(0xFFF0D4C2) : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.cardBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _days[i],
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                      color: active ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
