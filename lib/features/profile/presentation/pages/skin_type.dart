import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/features/profile/presentation/pages/personal_details.dart'
    show SubHeader, SectionLabel, SaveButton, InfoBox;

class SkinTypeEditorPage extends StatefulWidget {
  const SkinTypeEditorPage({super.key});

  @override
  State<SkinTypeEditorPage> createState() => _SkinTypeEditorPageState();
}

class _SkinTypeEditorPageState extends State<SkinTypeEditorPage> {
  // Combination selected by default (index 1)
  int _selectedType = 1;
  // Fitzpatrick III selected by default (index 2)
  int _selectedFitz = 2;

  final _skinTypes = [
    _SkinTypeData(
      emoji: '💧',
      name: 'Oily',
      desc: 'Excess sebum, shine, enlarged pores',
      fullWidth: false,
    ),
    _SkinTypeData(
      emoji: '⚖️',
      name: 'Combination',
      desc: 'Oily T-zone, drier cheeks',
      fullWidth: false,
    ),
    _SkinTypeData(
      emoji: '🌵',
      name: 'Dry',
      desc: 'Tight, flaky, lacks moisture',
      fullWidth: false,
    ),
    _SkinTypeData(
      emoji: '🌸',
      name: 'Normal',
      desc: 'Balanced, minimal concerns',
      fullWidth: false,
    ),
    _SkinTypeData(
      emoji: '🌿',
      name: 'Sensitive',
      desc: 'Reactive, redness-prone, easily irritated by products or weather',
      fullWidth: true,
    ),
  ];

  // Fitzpatrick scale swatches
  final _fitzColors = [
    const Color(0xFFFDDCC4), // Type I
    const Color(0xFFF5C5A3), // Type II
    const Color(0xFFE8A882), // Type III — default
    const Color(0xFFC48A5A), // Type IV
    const Color(0xFF8B5E3C), // Type V
    const Color(0xFF4A2C1A), // Type VI
  ];

  final _fitzLabels = [
    'Type I — Very Light',
    'Type II — Light',
    'Type III — Medium Beige',
    'Type IV — Olive',
    'Type V — Brown',
    'Type VI — Deep',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          SubHeader(
            superText: 'Profile',
            title: 'My Skin Type',
            onBack: () => context.pop(),
          ),

          // ── Body ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info box
                  InfoBox(
                    icon: Icons.info_outline_rounded,
                    text:
                        'Your skin type helps us fine-tune analysis results and recommendations. Not sure? Complete a scan first — Aura will detect it automatically.',
                  ),
                  const SizedBox(height: 14),

                  // ── Skin type grid ─────────────────────────────────
                  const SectionLabel('Select Your Skin Type'),
                  const SizedBox(height: 8),
                  _buildSkinTypeGrid(),
                  const SizedBox(height: 14),

                  // ── Fitzpatrick scale ──────────────────────────────
                  const SectionLabel('Skin Tone'),
                  const SizedBox(height: 8),
                  _buildFitzpatrickCard(),
                  const SizedBox(height: 24),

                  // Save
                  SaveButton(
                    label: 'Save Skin Profile',
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2-col grid + full-width last card ────────────────────────────────
  Widget _buildSkinTypeGrid() {
    // Separate the full-width card (Sensitive) from the 2-col cards
    final gridCards = _skinTypes.where((t) => !t.fullWidth).toList();
    final fullCard = _skinTypes.firstWhere((t) => t.fullWidth);
    final fullIndex = _skinTypes.indexOf(fullCard);

    return Column(
      children: [
        // 2×2 grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            childAspectRatio: 1.05,
          ),
          itemCount: gridCards.length,
          itemBuilder: (_, i) {
            final typeIndex = _skinTypes.indexOf(gridCards[i]);
            return _SkinTypeCard(
              data: gridCards[i],
              isSelected: _selectedType == typeIndex,
              onTap: () => setState(() => _selectedType = typeIndex),
            );
          },
        ),
        const SizedBox(height: 11),
        // Full-width Sensitive card
        _SkinTypeCardFull(
          data: fullCard,
          isSelected: _selectedType == fullIndex,
          onTap: () => setState(() => _selectedType = fullIndex),
        ),
      ],
    );
  }

  // ── Fitzpatrick colour swatches ──────────────────────────────────────
  Widget _buildFitzpatrickCard() {
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
          Text(
            'Fitzpatrick Scale',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          // 6 colour swatches in a row
          Row(
            children: List.generate(_fitzColors.length, (i) {
              final sel = _selectedFitz == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFitz = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                    height: 32,
                    decoration: BoxDecoration(
                      color: _fitzColors[i],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: sel ? AppColors.primary : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: _fitzColors[i].withValues(alpha: 0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // Label for selected shade
          Text(
            _fitzLabels[_selectedFitz],
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w300,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────
class _SkinTypeData {
  final String emoji;
  final String name;
  final String desc;
  final bool fullWidth;

  const _SkinTypeData({
    required this.emoji,
    required this.name,
    required this.desc,
    required this.fullWidth,
  });
}

// ─────────────────────────────────────────────────────────────────────────
// SKIN TYPE CARD — square (2-col grid item)
// Matches HTML .skin-edit-card:
//   border-radius:16px, border:1.5px --bg3, bg:--white, padding:18px 14px
//   .sel → terral bg + terra border + checkmark badge top-right
// ─────────────────────────────────────────────────────────────────────────
class _SkinTypeCard extends StatelessWidget {
  final _SkinTypeData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkinTypeCard({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF0D4C2) // --terral
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Selected checkmark — top right
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Center(
                    child: Icon(Icons.check, size: 11, color: Colors.white),
                  ),
                ),
              ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 10),
                Text(
                  data.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.desc,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SKIN TYPE CARD FULL — spans full width (Sensitive option)
// Matches HTML: grid-column:1/-1, flex row, emoji left + text right
// ─────────────────────────────────────────────────────────────────────────
class _SkinTypeCardFull extends StatelessWidget {
  final _SkinTypeData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkinTypeCardFull({
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0D4C2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Emoji
            Text(
              data.emoji,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.desc,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textTertiary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Checkmark on right when selected
            if (isSelected) ...[
              const SizedBox(width: 12),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 11, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
