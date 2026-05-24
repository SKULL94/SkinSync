import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/features/profile/presentation/pages/personal_details.dart'
    show SubHeader, SectionLabel, FormGroup, ToggleRow, InfoBox;

class PrivacyDataPage extends StatelessWidget {
  const PrivacyDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SubHeader(
            superText: 'Profile',
            title: 'Privacy & Data',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info box — shield icon
                  const InfoBox(
                    icon: Icons.shield_outlined,
                    text:
                        'Your skin data is private and encrypted. We never sell your data to third parties. All AI analysis runs on-device where possible.',
                  ),
                  const SizedBox(height: 14),

                  // ── Data Permissions ──────────────────────────────
                  const SectionLabel('Data Permissions'),
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
                          label: 'Camera Access',
                          sub: 'Required for skin scanning',
                          initialValue: true,
                        ),
                        ToggleRow(
                          label: 'Push Notifications',
                          sub: 'Reminders and scan results',
                          initialValue: true,
                        ),
                        ToggleRow(
                          label: 'Analytics',
                          sub: 'Help improve Aura (anonymous)',
                          initialValue: false,
                        ),
                        ToggleRow(
                          label: 'Personalised Tips',
                          sub: 'AI-curated advice based on your scans',
                          initialValue: true,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Your Data ─────────────────────────────────────
                  const SectionLabel('Your Data'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: AppColors.cardBorder, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        _DataRow(
                          title: 'Download My Data',
                          desc:
                              'Export all your scan history, results and profile as a JSON file',
                          actionLabel: 'Export',
                          isDanger: false,
                          onTap: () {},
                          showDivider: true,
                        ),
                        _DataRow(
                          title: 'Scan History',
                          desc: '12 scans stored — oldest from Apr 2, 2026',
                          actionLabel: 'Clear',
                          isDanger: false,
                          onTap: () {},
                          showDivider: true,
                        ),
                        _DataRow(
                          title: 'Delete Account',
                          desc:
                              'Permanently delete your account and all associated data. This cannot be undone.',
                          actionLabel: 'Delete',
                          isDanger: true,
                          onTap: () {},
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Legal ─────────────────────────────────────────
                  const SectionLabel('Legal'),
                  const SizedBox(height: 8),
                  FormGroup(rows: [
                    _LegalRow(label: 'Privacy Policy', onTap: () {}),
                    _LegalRow(label: 'Terms of Service', onTap: () {}),
                    _LegalRow(
                        label: 'Cookie Policy',
                        onTap: () {},
                        showDivider: false),
                  ]),
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

// ── Data row: title + description + action button ────────────────────────
class _DataRow extends StatelessWidget {
  final String title;
  final String desc;
  final String actionLabel;
  final bool isDanger;
  final bool showDivider;
  final VoidCallback onTap;

  const _DataRow({
    required this.title,
    required this.desc,
    required this.actionLabel,
    required this.isDanger,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      desc,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: AppColors.textTertiary,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDanger
                        ? AppColors.rose.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDanger
                          ? AppColors.rose.withValues(alpha: 0.4)
                          : AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDanger ? AppColors.rose : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            color: const Color(0xFFEAE3D9),
          ),
      ],
    );
  }
}

// ── Legal link row ──────────────────────────────────────────────────────
class _LegalRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _LegalRow({
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
          if (showDivider)
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              color: const Color(0xFFEAE3D9),
            ),
        ],
      ),
    );
  }
}
