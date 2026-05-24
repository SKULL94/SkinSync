import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/theme/theme_extension.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/history/presentation/pages/history_page.dart';
import 'package:skin_sync/features/home/presentation/pages/home_page.dart';
import 'package:skin_sync/features/home/presentation/pages/skin_news_page.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';
import 'package:skin_sync/features/profile/presentation/pages/profile_page.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const HistoryLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<LayoutBloc, LayoutState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          extendBody: true, // lets content flow behind the nav
          body: IndexedStack(
            index: state.currentIndex,
            children: const [
              HomePage(),
              HistoryPage(),
              SkinNewsPage(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: _AuraBottomNav(
            currentIndex: state.currentIndex,
            onTabChanged: (i) =>
                context.read<LayoutBloc>().add(LayoutTabChanged(i)),
            onScanTap: () => context.push(AppRoutes.skinAnalysisRoute),
            colors: colors,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AURA BOTTOM NAV — curved notch, FAB floats above center
// ═══════════════════════════════════════════════════════════════════════════

class _AuraBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onScanTap;
  final AppColorsTheme colors;

  const _AuraBottomNav({
    required this.currentIndex,
    required this.onTabChanged,
    required this.onScanTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Total widget height:
    //   nav bar visible height (58px) + home indicator (bottomPad) + FAB overhang (20px)
    final totalHeight = 58.0 + bottomPad + 20.0;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ── Curved nav bar ─────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _CurvedNavBar(
              height: 58.0 + bottomPad,
              bottomPad: bottomPad,
              currentIndex: currentIndex,
              onTabChanged: onTabChanged,
              colors: colors,
            ),
          ),

          // ── Camera FAB — floats closer to notch ──────────────────
          Positioned(
            bottom: 58.0 + bottomPad - 8,
            child: _ScanFAB(onTap: onScanTap),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// CURVED NAV BAR — CustomPaint draws the notch shape, items sit on top
// ─────────────────────────────────────────────────────────────────────────
class _CurvedNavBar extends StatelessWidget {
  final double height;
  final double bottomPad;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final AppColorsTheme colors;

  const _CurvedNavBar({
    required this.height,
    required this.bottomPad,
    required this.currentIndex,
    required this.onTabChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenW,
      height: height,
      child: Stack(
        children: [
          // Painted background with notch
          CustomPaint(
            size: Size(screenW, height),
            painter: _NavNotchPainter(
              backgroundColor: colors.navBackground,
              borderColor: colors.navBorder,
            ),
          ),

          // Nav items row — sits in the visible 58px bar area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 58,
            child: Row(
              children: [
                // ── Home (left) ──────────────────────────────────────
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'HOME',
                    isActive: currentIndex == 0,
                    onTap: () => onTabChanged(0),
                    colors: colors,
                  ),
                ),

                // ── History (left-center) ────────────────────────────
                Expanded(
                  child: _NavItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: 'HISTORY',
                    isActive: currentIndex == 1,
                    onTap: () => onTabChanged(1),
                    colors: colors,
                  ),
                ),

                // ── Centre gap — 64px wide for FAB ─────────────────
                const SizedBox(width: 64),

                // ── News (right-center) ───────────────────────────────
                Expanded(
                  child: _NavItem(
                    icon: Icons.article_outlined,
                    activeIcon: Icons.article_rounded,
                    label: 'NEWS',
                    isActive: currentIndex == 2,
                    onTap: () => onTabChanged(2),
                    colors: colors,
                  ),
                ),

                // ── Profile (right) ──────────────────────────────────
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person_rounded,
                    label: 'PROFILE',
                    isActive: currentIndex == 3,
                    onTap: () => onTabChanged(3),
                    colors: colors,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// NAV NOTCH PAINTER — draws the curved cutout exactly centered
// Matches the HTML SVG path:
//   M0 18 Q0 0 18 0 L155 0 Q166 0 170 10 C174 22 176 32 195 32
//   C214 32 216 22 220 10 Q224 0 235 0 L372 0 Q390 0 390 18 L390 82 L0 82 Z
// ─────────────────────────────────────────────────────────────────────────
class _NavNotchPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;

  const _NavNotchPainter({
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Notch geometry — always centered regardless of screen width
    // notch center at w/2, notch half-width = 32px each side, depth = 24px
    final cx = w / 2;
    const notchHalfW = 32.0; // half-width of the notch opening
    const notchDepth = 24.0; // how far down the curve goes
    const cornerR = 18.0; // corner radius on bar edges
    const entryX = 8.0; // quadratic control offset for notch entry

    final leftEdge = cx - notchHalfW; // x where notch starts
    final rightEdge = cx + notchHalfW; // x where notch ends

    // ── Fill path ──────────────────────────────────────────────────
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start: top-left corner
    path.moveTo(0, cornerR);
    path.quadraticBezierTo(0, 0, cornerR, 0);

    // Top-left to notch start — straight line
    path.lineTo(leftEdge - entryX, 0);

    // Notch entry curve (left side)
    path.quadraticBezierTo(leftEdge, 0, leftEdge + 4, notchDepth * 0.3);

    // Notch bottom curve (left half → center)
    path.cubicTo(
      leftEdge + 6,
      notchDepth * 0.7,
      cx - 6,
      notchDepth,
      cx,
      notchDepth,
    );

    // Notch bottom curve (center → right half)
    path.cubicTo(
      cx + 6,
      notchDepth,
      rightEdge - 6,
      notchDepth * 0.7,
      rightEdge - 4,
      notchDepth * 0.3,
    );

    // Notch exit curve (right side)
    path.quadraticBezierTo(rightEdge, 0, rightEdge + entryX, 0);

    // Top-right corner
    path.lineTo(w - cornerR, 0);
    path.quadraticBezierTo(w, 0, w, cornerR);

    // Right side down to bottom-right
    path.lineTo(w, h);

    // Bottom
    path.lineTo(0, h);

    // Left side up to start
    path.lineTo(0, cornerR);

    path.close();
    canvas.drawPath(path, fillPaint);

    // ── Border stroke — only top edge (following notch curve) ──────
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final borderPath = Path();
    borderPath.moveTo(0, cornerR);
    borderPath.quadraticBezierTo(0, 0, cornerR, 0);
    borderPath.lineTo(leftEdge - entryX, 0);
    borderPath.quadraticBezierTo(leftEdge, 0, leftEdge + 4, notchDepth * 0.3);
    borderPath.cubicTo(
      leftEdge + 6,
      notchDepth * 0.7,
      cx - 6,
      notchDepth,
      cx,
      notchDepth,
    );
    borderPath.cubicTo(
      cx + 6,
      notchDepth,
      rightEdge - 6,
      notchDepth * 0.7,
      rightEdge - 4,
      notchDepth * 0.3,
    );
    borderPath.quadraticBezierTo(rightEdge, 0, rightEdge + entryX, 0);
    borderPath.lineTo(w - cornerR, 0);
    borderPath.quadraticBezierTo(w, 0, w, cornerR);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(_NavNotchPainter old) =>
      old.backgroundColor != backgroundColor || old.borderColor != borderColor;
}

// ─────────────────────────────────────────────────────────────────────────
// NAV ITEM — icon + label, with active terra color
// ─────────────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppColorsTheme colors;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive ? colors.primary : colors.navInactive,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                color: isActive ? colors.primary : colors.navInactive,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SCAN FAB — 60×60 terra gradient circle, glowing shadow, haptic on tap
// ─────────────────────────────────────────────────────────────────────────
class _ScanFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _ScanFAB({required this.onTap});

  @override
  State<_ScanFAB> createState() => _ScanFABState();
}

class _ScanFABState extends State<_ScanFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary, // #D4845A terra
                AppColors.primaryDark, // #B86E48 terra2
              ],
            ),
            boxShadow: [
              // Main glow
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              // Subtle inner lift
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.20),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            // Outer glow ring
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 3,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.camera_alt_outlined,
              size: 22,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
