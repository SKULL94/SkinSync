import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/history/presentation/pages/history_page.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';
import 'package:skin_sync/features/home-screen/presentation/bloc/routine_bloc.dart';
import 'package:skin_sync/features/home-screen/presentation/pages/routine_page.dart';
import 'package:skin_sync/features/streaks/presentation/bloc/streaks_bloc.dart';
import 'package:skin_sync/features/streaks/presentation/pages/streaks_page.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<RoutineBloc>().add(const RoutineLoadRequested());
    context.read<StreaksBloc>().add(const StreaksLoadRequested());
    context.read<HistoryBloc>().add(const HistoryLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoutineBloc, RoutineState>(
      listenWhen: (previous, current) {
        return previous.routines != current.routines;
      },
      listener: (context, state) {
        context.read<StreaksBloc>().add(const StreaksLoadRequested());
      },
      child: BlocBuilder<LayoutBloc, LayoutState>(
        builder: (context, state) {
          return Scaffold(
            body: IndexedStack(
              index: state.currentIndex,
              children: const [
                RoutinePage(),
                StreaksPage(),
                HistoryPage(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: state.currentIndex,
              onDestinationSelected: (index) {
                context.read<LayoutBloc>().add(LayoutTabChanged(index));
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: StringConst.kRoutines,
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_fire_department_outlined),
                  selectedIcon: Icon(Icons.local_fire_department),
                  label: StringConst.kStreaks,
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: StringConst.kHistory,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
