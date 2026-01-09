import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/features/history/presentation/pages/history_page.dart';
import 'package:skin_sync/features/home-screen/presentation/pages/routine_page.dart';
import 'package:skin_sync/features/streaks/presentation/pages/streaks_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static const double bottomSpacing = 12;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final _screens = [
    const RoutinePage(),
    const StreaksPage(),
    const HistoryPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomSafeArea + HomeShell.bottomSpacing,
            child: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(100)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.2, sigmaY: 15.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            // border: Border.all(
            //   color: ColorConst.white.withValues(alpha: 0.1),
            //   width: 1,
            // ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: const Icon(Icons.home),
                label: StringConst.kRoutines,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: const Icon(Icons.nat),
                label: StringConst.kStreaks,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: const Icon(Icons.history),
                label: StringConst.kHistory,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Icon icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding:
              isActive ? const EdgeInsets.all(16) : const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: (icon)),
    );
  }
}
