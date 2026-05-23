import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/history/presentation/pages/history_page.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';
import 'package:skin_sync/features/skin_analysis/presentation/pages/skin_analysis_page.dart';

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
    context.read<HistoryBloc>().add(const HistoryLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutBloc, LayoutState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentIndex,
            children: const [
              SkinAnalysisPage(),
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
                icon: Icon(Icons.face_retouching_natural_outlined),
                selectedIcon: Icon(Icons.face_retouching_natural),
                label: StringConst.kAnalyze,
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
    );
  }
}
