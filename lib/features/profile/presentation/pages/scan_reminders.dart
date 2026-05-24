import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/features/profile/presentation/pages/personal_details.dart'
    show SubHeader, SectionLabel, ToggleRow, SaveButton, InfoBox;

class ScanRemindersPage extends StatefulWidget {
  const ScanRemindersPage({super.key});

  @override
  State<ScanRemindersPage> createState() => _ScanRemindersPageState();
}

class _ScanRemindersPageState extends State<ScanRemindersPage> {
  int _selectedFreq = 1; // Every 7 days default
  final _freqOptions = [
    'Daily',
    'Every 7 days',
    'Every 14 days',
    'Monthly',
    'Custom'
  ];

  // Days: Mon(0) and Fri(4) active by default
  final Set<int> _activeDays = {0, 4};

  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SubHeader(
            superText: 'Profile',
            title: 'Scan Reminders',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info box
                  const InfoBox(
                    icon: Icons.notifications_outlined,
                    text:
                        'Regular scans track your skin\'s progress over time. We recommend scanning every 7 days for the most accurate trend data.',
                  ),
                  const SizedBox(height: 14),

                  // Reminders toggles
                  const SectionLabel('Reminders'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: AppColors.cardBorder, width: 1.5),
                    ),
                    child: const Column(
                      children: [
                        ToggleRow(
                          label: 'Enable Reminders',
                          sub: 'Push notifications to your device',
                          initialValue: true,
                        ),
                        ToggleRow(
                          label: 'Morning Reminder',
                          sub: 'Best lighting for accurate results',
                          initialValue: true,
                        ),
                        ToggleRow(
                          label: 'Streak Alerts',
                          sub: 'Stay on track with your routine',
                          initialValue: false,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Reminder time
                  const SectionLabel('Reminder Time'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: AppColors.cardBorder, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preferred Time',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          // Time picker chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.cardBorder, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_outlined,
                                    size: 14, color: AppColors.textTertiary),
                                const SizedBox(width: 6),
                                Text(
                                  '8:30 AM',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Frequency pills
                  const SectionLabel('Frequency'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: AppColors.cardBorder, width: 1.5),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_freqOptions.length, (i) {
                        final sel = _selectedFreq == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFreq = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFFF0D4C2)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _freqOptions[i],
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Days of week
                  const SectionLabel('Days of Week'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: AppColors.cardBorder, width: 1.5),
                    ),
                    child: Row(
                      children: List.generate(_days.length, (i) {
                        final active = _activeDays.contains(i);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              active
                                  ? _activeDays.remove(i)
                                  : _activeDays.add(i);
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                              height: 38,
                              decoration: BoxDecoration(
                                color: active
                                    ? const Color(0xFFF0D4C2)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.cardBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _days[i],
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: active
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                    color: active
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SaveButton(label: 'Save Reminder Settings', onTap: () {}),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
