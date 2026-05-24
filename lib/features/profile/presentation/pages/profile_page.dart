import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/models/user_profile.dart';
import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/services/storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  String _userName = '';
  DateTime? _memberSince;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userRepository = sl<UserRepository>();
    final storageService = sl<StorageService>();

    // Try Supabase first
    final profile = await userRepository.getCurrentUserProfile();

    if (profile != null) {
      setState(() {
        _profile = profile;
        _userName = profile.fullName.isNotEmpty
            ? profile.fullName
            : profile.firstName ?? '';
        _memberSince = profile.createdAt;
      });
    } else {
      // Fallback to local storage
      final name = storageService.fetch<String>('user_name');
      if (name != null) {
        setState(() => _userName = name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Dark hero ───────────────────────────────────────────
            _ProfileHero(userName: _userName, memberSince: _memberSince),

            // ── Stats strip ─────────────────────────────────────────
            const _StatsStrip(),

            // ── Scrollable body ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  const _SkinTypeCard(),
                  const SizedBox(height: 16),
                  const _ConcernsCard(),
                  const SizedBox(height: 16),
                  const _SettingsCard(),
                  const SizedBox(height: 24),
                  _SignOutButton(
                    onTap: () {
                      final storageService = sl<StorageService>();
                      storageService.clearAll();
                      context.go(AppRoutes.splashScreen);
                    },
                  ),
                  const SizedBox(height: 108), // nav clearance
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE HERO — dark with terracotta + rose radial washes
// ═══════════════════════════════════════════════════════════════════════════
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
      color: AppColors.ink, // #2A2118
      child: Stack(
        children: [
          // Terracotta radial — top right
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
          // Rose radial — bottom left
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
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Row(
                children: [
                  // Avatar — 76×76 circle, gradient terral→rosell
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF0D4C2), // terral
                          Color(0xFFEDD8D8), // rosell
                        ],
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
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name — Playfair italic
                        Text(
                          displayName,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFFF2EDE6), // --bg
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Joined text
                        Text(
                          _formatMemberSince(memberSince),
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            color:
                                const Color(0xFFF2EDE6).withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Premium badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
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
                                'Premium Plan',
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

// ═══════════════════════════════════════════════════════════════════════════
// STATS STRIP — 3 columns on dark background
// ═══════════════════════════════════════════════════════════════════════════
class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF3D2E22), // dark-mid
      child: Row(
        children: [
          _StatCell(value: '12', label: 'SCANS'),
          _StatDivider(),
          _StatCell(value: '75', label: 'BEST SCORE'),
          _StatDivider(),
          _StatCell(value: '+18', label: 'IMPROVEMENT'),
        ],
      ),
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

// ═══════════════════════════════════════════════════════════════════════════
// SKIN TYPE CARD — 4 options in a row + Edit button
// ═══════════════════════════════════════════════════════════════════════════
class _SkinTypeCard extends StatefulWidget {
  const _SkinTypeCard();

  @override
  State<_SkinTypeCard> createState() => _SkinTypeCardState();
}

class _SkinTypeCardState extends State<_SkinTypeCard> {
  int _selected = 1; // Combo

  final _types = [
    {'emoji': '💧', 'label': 'Oily'},
    {'emoji': '⚖️', 'label': 'Combo'},
    {'emoji': '🌵', 'label': 'Dry'},
    {'emoji': '🌸', 'label': 'Normal'},
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
          // Header row
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
          // Type pills
          Row(
            children: List.generate(_types.length, (i) {
              final sel = _selected == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFF0D4C2) // terral
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.cardBorder,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _types[i]['emoji']!,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _types[i]['label']!,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
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

// ═══════════════════════════════════════════════════════════════════════════
// CONCERNS CARD — tag cloud, toggle on/off
// ═══════════════════════════════════════════════════════════════════════════
class _ConcernsCard extends StatefulWidget {
  const _ConcernsCard();

  @override
  State<_ConcernsCard> createState() => _ConcernsCardState();
}

class _ConcernsCardState extends State<_ConcernsCard> {
  final _active = {'Acne', 'Dark spots', 'Pores'};
  final _all = [
    'Acne',
    'Dark spots',
    'Pores',
    'Wrinkles',
    'Dryness',
    'Redness'
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
                  color: const Color(0xFFF0D4C2), // terral
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
            children: _all.map((c) {
              final sel = _active.contains(c);
              return GestureDetector(
                onTap: () => setState(() {
                  sel ? _active.remove(c) : _active.add(c);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFFF0D4C2) // terral
                        : AppColors.background,
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

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS CARD — rows with tinted icon pills + chevrons
// ═══════════════════════════════════════════════════════════════════════════
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
            // Tinted icon pill — 34×34 border-radius 10
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, size: 16, color: iconColor),
              ),
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

// ═══════════════════════════════════════════════════════════════════════════
// SIGN OUT BUTTON — rose-outlined
// ═══════════════════════════════════════════════════════════════════════════
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
