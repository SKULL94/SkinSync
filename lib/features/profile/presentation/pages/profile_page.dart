import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/models/user_profile.dart';
import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/core/theme/theme_extension.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userRepository = sl<UserRepository>();
    final profile = await userRepository.getCurrentUserProfile();

    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSkinType(String skinType) async {
    if (_profile == null) return;

    final userRepository = sl<UserRepository>();
    final updated = await userRepository.updateFields({'skin_type': skinType});

    if (updated != null && mounted) {
      setState(() => _profile = updated);
    }
  }

  Future<void> _updateConcerns(List<String> concerns) async {
    if (_profile == null) return;

    final userRepository = sl<UserRepository>();
    final updated = await userRepository.updateFields({'concerns': concerns});

    if (updated != null && mounted) {
      setState(() => _profile = updated);
    }
  }

  Future<void> _signOut() async {
    final storageService = sl<StorageService>();
    await Supabase.instance.client.auth.signOut();
    await storageService.clearAll();
    if (mounted) context.go(AppRoutes.splashScreen);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHero(
              userName: _profile?.fullName ?? _profile?.firstName ?? 'User',
              memberSince: _profile?.createdAt,
            ),
            _StatsStrip(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  _SkinTypeCard(
                    selectedType: _profile?.skinType,
                    onTypeChanged: _updateSkinType,
                  ),
                  const SizedBox(height: 16),
                  _ConcernsCard(
                    selectedConcerns: _profile?.concerns ?? [],
                    onConcernsChanged: _updateConcerns,
                  ),
                  const SizedBox(height: 16),
                  const _SettingsCard(),
                  const SizedBox(height: 24),
                  _SignOutButton(onTap: _signOut),
                  const SizedBox(height: 108),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final String userName;
  final DateTime? memberSince;

  const _ProfileHero({required this.userName, this.memberSince});

  String _formatMemberSince(DateTime? date) {
    if (date == null) return 'Member';
    return 'Member since ${DateFormat('MMM yyyy').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = userName.isNotEmpty ? userName : 'User';
    final avatarInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Container(
      color: AppColors.ink,
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.rose.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF0D4C2), Color(0xFFEDD8D8)],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        avatarInitial,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
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
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFFF2EDE6),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatMemberSince(memberSince),
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFFF2EDE6).withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
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
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Free Plan',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
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

class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  int _calculateScore(dynamic results) {
    try {
      if (results != null && results is List && results.isNotEmpty) {
        final topConfidence = (results.first['confidence'] as num?)?.toDouble() ?? 0.5;
        return (50 + (topConfidence * 50)).toInt().clamp(0, 100);
      }
    } catch (_) {}
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      buildWhen: (prev, curr) => prev.histories != curr.histories,
      builder: (context, state) {
        final histories = state.histories;
        final totalScans = histories.length;

        int bestScore = 0;
        int firstScore = 0;
        int latestScore = 0;

        if (histories.isNotEmpty) {
          // Calculate scores
          for (final h in histories) {
            final score = _calculateScore(h.results);
            if (score > bestScore) bestScore = score;
          }

          // First scan score (oldest)
          firstScore = _calculateScore(histories.last.results);
          // Latest scan score
          latestScore = _calculateScore(histories.first.results);
        }

        final improvement = totalScans > 1 ? latestScore - firstScore : 0;
        final improvementText = improvement >= 0 ? '+$improvement' : '$improvement';

        return Container(
          color: const Color(0xFF3D2E22),
          child: Row(
            children: [
              _StatCell(value: '$totalScans', label: 'SCANS'),
              _StatDivider(),
              _StatCell(value: bestScore > 0 ? '$bestScore' : '-', label: 'BEST SCORE'),
              _StatDivider(),
              _StatCell(
                value: totalScans > 1 ? improvementText : '-',
                label: 'IMPROVEMENT',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFF2EDE6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
                color: const Color(0xFFF2EDE6).withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}

class _SkinTypeCard extends StatelessWidget {
  final String? selectedType;
  final Function(String) onTypeChanged;

  const _SkinTypeCard({
    required this.selectedType,
    required this.onTypeChanged,
  });

  static const _types = [
    {'key': 'oily', 'emoji': '💧', 'label': 'Oily'},
    {'key': 'combo', 'emoji': '⚖️', 'label': 'Combo'},
    {'key': 'dry', 'emoji': '🌵', 'label': 'Dry'},
    {'key': 'normal', 'emoji': '🌸', 'label': 'Normal'},
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
                'My Skin Type',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.skinTypeRoute),
                child: Text(
                  'Edit',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
                  onTap: () => onTypeChanged(type['key']!),
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
                        Text(type['emoji']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 6),
                        Text(
                          type['label']!,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: sel ? AppColors.primary : AppColors.textSecondary,
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

class _ConcernsCard extends StatelessWidget {
  final List<String> selectedConcerns;
  final Function(List<String>) onConcernsChanged;

  const _ConcernsCard({
    required this.selectedConcerns,
    required this.onConcernsChanged,
  });

  static const _allConcerns = [
    'Acne',
    'Dark spots',
    'Pores',
    'Wrinkles',
    'Dryness',
    'Redness',
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
                'My Concerns',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
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
            children: _allConcerns.map((c) {
              final sel = selectedConcerns.contains(c);
              return GestureDetector(
                onTap: () {
                  final updated = List<String>.from(selectedConcerns);
                  if (sel) {
                    updated.remove(c);
                  } else {
                    updated.add(c);
                  }
                  onConcernsChanged(updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
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
                    c,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

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
            label: 'Personal Details',
            value: 'Name, age, gender',
            onTap: () => context.push(AppRoutes.personalDetailsRoute),
          ),
          _Divider(),
          _SettingRow(
            icon: Icons.notifications_outlined,
            iconBg: const Color(0xFFEDD8D8),
            iconColor: AppColors.rose,
            label: 'Scan Reminders',
            value: 'Every 7 days',
            onTap: () => context.push(AppRoutes.scanRemindersRoute),
          ),
          _Divider(),
          _SettingRow(
            icon: Icons.shield_outlined,
            iconBg: const Color(0xFFD4E3CC),
            iconColor: AppColors.sage,
            label: 'Privacy & Data',
            value: 'Manage your data',
            onTap: () => context.push(AppRoutes.privacyRoute),
          ),
          _Divider(),
          _SettingRow(
            icon: Icons.wb_sunny_outlined,
            iconBg: const Color(0xFFF5DCA8),
            iconColor: AppColors.amber,
            label: 'Appearance',
            value: 'Light mode',
            onTap: () => context.push(AppRoutes.appearanceRoute),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
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
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.rose.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            'Sign Out',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.rose,
            ),
          ),
        ),
      ),
    );
  }
}
