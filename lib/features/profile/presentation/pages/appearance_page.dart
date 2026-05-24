import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/features/profile/presentation/pages/personal_details.dart'
    show SubHeader, SectionLabel, ToggleRow, SaveButton;

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  int _selectedTheme = 0; // Light selected by default
  int _selectedAccent = 0; // Terracotta selected

  final _themes = [
    _ThemeData(
      name: 'Light',
      desc: 'Warm parchment base',
      bgColor: const Color(0xFFF2EDE6),
      barColor: const Color(0xFFE0D8CC),
      cardColor: const Color(0xFFFAFAF8),
      cardBorderColor: const Color(0xFFE0D8CC),
      nameFg: const Color(0xFF2A2118),
      descFg: const Color(0xFFA89880),
      labelBg: const Color(0xFFF2EDE6),
    ),
    _ThemeData(
      name: 'Dark',
      desc: 'Deep warm dark',
      bgColor: const Color(0xFF1A1410),
      barColor: const Color(0xFF3D2E22),
      cardColor: const Color(0xFF2A2118),
      cardBorderColor: const Color(0xFF3D2E22),
      nameFg: const Color(0xFFF2EDE6),
      descFg: const Color(0xFF7A6A5A),
      labelBg: const Color(0xFF2A2118),
    ),
    _ThemeData(
      name: 'System',
      desc: 'Follows device setting',
      bgColor: const Color(0xFFF2EDE6), // shown as split in HTML
      barColor: Colors.transparent,
      cardColor: Colors.transparent,
      cardBorderColor: Colors.transparent,
      nameFg: const Color(0xFF2A2118),
      descFg: const Color(0xFFA89880),
      labelBg: const Color(0xFFF2EDE6),
      isSystem: true,
    ),
    _ThemeData(
      name: 'Warm Night',
      desc: 'Rich amber dark',
      bgColor: const Color(0xFF2D1F14),
      barColor: const Color(0xFF4A3020),
      cardColor: const Color(0xFF3A2818),
      cardBorderColor: const Color(0xFF4A3020),
      nameFg: const Color(0xFFF2EDE6),
      descFg: const Color(0xFF7A6A5A),
      labelBg: const Color(0xFF2D1F14),
    ),
  ];

  final _accents = [
    _AccentData(name: 'Terracotta', color: const Color(0xFFD4845A)),
    _AccentData(name: 'Rose', color: const Color(0xFFC49898)),
    _AccentData(name: 'Sage', color: const Color(0xFF8FA882)),
    _AccentData(name: 'Amber', color: const Color(0xFFE8A84A)),
    _AccentData(name: 'Lavender', color: const Color(0xFF8B7FD4)),
    _AccentData(name: 'Slate', color: const Color(0xFF6B9FAA)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SubHeader(
            superText: 'Profile',
            title: 'Appearance',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Theme ─────────────────────────────────────────
                  const SectionLabel('Theme'),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 11,
                      crossAxisSpacing: 11,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _themes.length,
                    itemBuilder: (_, i) => _ThemeCard(
                      data: _themes[i],
                      isSelected: _selectedTheme == i,
                      onTap: () => setState(() => _selectedTheme = i),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Accent Colour ─────────────────────────────────
                  const SectionLabel('Accent Colour'),
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(_accents.length, (i) {
                              final sel = _selectedAccent == i;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedAccent = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _accents[i].color,
                                    border: Border.all(
                                      color: sel
                                          ? AppColors.ink
                                          : Colors.transparent,
                                      width: 2.5,
                                    ),
                                    // Scale-up effect via padding trick
                                    boxShadow: sel
                                        ? [
                                            BoxShadow(
                                              color: _accents[i]
                                                  .color
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: sel
                                      ? const Center(
                                          child: Icon(Icons.check,
                                              size: 16, color: Colors.white),
                                        )
                                      : null,
                                ),
                              );
                            }),
                          ),
                        ),
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 18),
                          color: const Color(0xFFEAE3D9),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                          child: Text(
                            '${_accents[_selectedAccent].name} selected — changes button and active colours',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Text Size ─────────────────────────────────────
                  const SectionLabel('Text Size'),
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
                          label: 'Larger Text',
                          initialValue: false,
                        ),
                        ToggleRow(
                          label: 'Bold Text',
                          initialValue: false,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Motion ────────────────────────────────────────
                  const SectionLabel('Motion'),
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
                          label: 'Reduce Motion',
                          sub: 'Minimises animations throughout the app',
                          initialValue: false,
                        ),
                        ToggleRow(
                          label: 'Haptic Feedback',
                          sub: 'Subtle vibrations on interactions',
                          initialValue: true,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SaveButton(label: 'Apply Settings', onTap: () {}),
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

// ─────────────────────────────────────────────────────────────────────────
// Theme card — mini preview + name + desc + selected checkmark dot
// ─────────────────────────────────────────────────────────────────────────
class _ThemeData {
  final String name;
  final String desc;
  final Color bgColor;
  final Color barColor;
  final Color cardColor;
  final Color cardBorderColor;
  final Color nameFg;
  final Color descFg;
  final Color labelBg;
  final bool isSystem;

  const _ThemeData({
    required this.name,
    required this.desc,
    required this.bgColor,
    required this.barColor,
    required this.cardColor,
    required this.cardBorderColor,
    required this.nameFg,
    required this.descFg,
    required this.labelBg,
    this.isSystem = false,
  });
}

class _ThemeCard extends StatelessWidget {
  final _ThemeData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              // Preview area
              Expanded(
                child: Stack(
                  children: [
                    // Background
                    data.isSystem
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [0.5, 0.5],
                                colors: [
                                  Color(0xFFF2EDE6),
                                  Color(0xFF1A1410),
                                ],
                              ),
                            ),
                          )
                        : Container(color: data.bgColor),

                    // Mini UI bars
                    if (!data.isSystem) ...[
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          height: 6,
                          width: 60 * 0.55,
                          decoration: BoxDecoration(
                            color: data.barColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 22,
                        left: 12,
                        child: Container(
                          height: 6,
                          width: 60 * 0.80,
                          decoration: BoxDecoration(
                            color: data.barColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 34,
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: data.cardColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: data.cardBorderColor, width: 1),
                          ),
                        ),
                      ),
                    ],

                    // Selected checkmark dot (terra circle bottom-right)
                    if (isSelected)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const Center(
                            child: Icon(Icons.check,
                                size: 11, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Label row
              Container(
                color: data.labelBg,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: data.nameFg,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            data.desc,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: data.descFg,
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
    );
  }
}

class _AccentData {
  final String name;
  final Color color;
  const _AccentData({required this.name, required this.color});
}
