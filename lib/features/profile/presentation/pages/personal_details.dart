import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Sub-screen header ──────────────────────────────────────
          SubHeader(
            superText: 'Profile',
            title: 'Personal Details',
            onBack: () => context.pop(),
          ),

          // ── Scrollable body ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar editor card
                  _AvatarCard(),
                  const SizedBox(height: 14),

                  // Basic Info
                  const SectionLabel('Basic Info'),
                  const SizedBox(height: 8),
                  FormGroup(rows: [
                    _FormRow(
                      label: 'First Name',
                      value: 'Priya',
                      trailing: const _EditIcon(),
                    ),
                    _FormRow(
                      label: 'Last Name',
                      value: 'Sharma',
                      trailing: const _EditIcon(),
                    ),
                    _FormRow(
                      label: 'Date of Birth',
                      value: '12 March 1998',
                      trailing: const _EditIcon(),
                    ),
                    _FormRow(
                      label: 'Gender',
                      value: 'Female',
                      trailing: const _ChevronIcon(),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Contact
                  const SectionLabel('Contact'),
                  const SizedBox(height: 8),
                  FormGroup(rows: [
                    _FormRow(
                      label: 'Mobile Number',
                      value: '+91 98765 43210',
                      trailing: _VerifiedBadge(),
                    ),
                    _FormRow(
                      label: 'Email Address',
                      value: 'priya@email.com',
                      trailing: const _EditIcon(),
                    ),
                    _FormRow(
                      label: 'Location',
                      value: 'Mumbai, India',
                      trailing: const _ChevronIcon(),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Skin Background
                  const SectionLabel('Skin Background'),
                  const SizedBox(height: 8),
                  FormGroup(rows: [
                    _FormRow(
                      label: 'Fitzpatrick Scale',
                      value: 'Type III — Medium',
                      trailing: const _ChevronIcon(),
                    ),
                    _FormRow(
                      label: 'Known Allergies',
                      value: 'Fragrance, Lanolin',
                      trailing: const _EditIcon(),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Save button
                  SaveButton(label: 'Save Changes', onTap: () {}),
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

// ── Avatar card ─────────────────────────────────────────────────────────────
class _AvatarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0D4C2), Color(0xFFEDD8D8)],
              ),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Center(
              child: Text(
                'P',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Photo',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tap to update your avatar',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Edit chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0D4C2),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Edit',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS (used across all 4 sub-screens)
// ═══════════════════════════════════════════════════════════════════════════

// Sub-screen sticky header with back button
class SubHeader extends StatelessWidget {
  final String superText;
  final String title;
  final VoidCallback onBack;

  const SubHeader({
    super.key,
    required this.superText,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 16, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
              child: const Icon(Icons.chevron_left,
                  size: 20, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                superText.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Section label — "BASIC INFO" caps style
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

// Form group — white card with dividers between rows
class FormGroup extends StatelessWidget {
  final List<Widget> rows;
  const FormGroup({super.key, required this.rows});

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
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                color: const Color(0xFFEAE3D9), // --bg2
              ),
          ],
        ],
      ),
    );
  }
}

// Single form row: label + value + trailing widget
class _FormRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget trailing;

  const _FormRow({
    required this.label,
    required this.value,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

// Trailing edit (pencil) icon
class _EditIcon extends StatelessWidget {
  const _EditIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.edit_outlined,
        size: 15, color: AppColors.textTertiary);
  }
}

// Trailing chevron icon
class _ChevronIcon extends StatelessWidget {
  const _ChevronIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.chevron_right,
        size: 16, color: AppColors.textTertiary);
  }
}

// Verified badge (sage tinted)
class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD4E3CC), // sagell
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Verified',
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.sage,
        ),
      ),
    );
  }
}

// Save / Apply button — full-width terracotta
class SaveButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SaveButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// Toggle switch — matches HTML .toggle / .toggle.on
class ToggleSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const ToggleSwitch({super.key, this.initialValue = false, this.onChanged});

  @override
  State<ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch>
    with SingleTickerProviderStateMixin {
  late bool _on;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _on = widget.initialValue;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: _on ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _on = !_on);
    _on ? _ctrl.forward() : _ctrl.reverse();
    widget.onChanged?.call(_on);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: _on ? AppColors.primary : AppColors.cardBorder,
        ),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.all(3),
            child: Align(
              alignment: Alignment.lerp(
                  Alignment.centerLeft, Alignment.centerRight, _anim.value)!,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Toggle row — label + optional subtitle + toggle on right
class ToggleRow extends StatelessWidget {
  final String label;
  final String? sub;
  final bool initialValue;
  final bool showDivider;

  const ToggleRow({
    super.key,
    required this.label,
    this.sub,
    this.initialValue = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub!,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ToggleSwitch(initialValue: initialValue),
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

// Info box — sage tinted with icon + text
class InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoBox({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.sage.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sage.withValues(alpha: 0.22),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 14, color: AppColors.sage),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: AppColors.textTertiary,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
