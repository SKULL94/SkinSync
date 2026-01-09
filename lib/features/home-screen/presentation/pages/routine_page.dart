import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/home-screen/presentation/bloc/routine_bloc.dart';
import 'package:skin_sync/features/home-screen/presentation/widgets/routine_card.dart';
import 'package:skin_sync/features/home-screen/presentation/widgets/routine_date_navigation.dart';
import 'package:skin_sync/features/home-screen/presentation/widgets/routine_empty_state.dart';
import 'package:skin_sync/features/home-screen/presentation/widgets/routine_header.dart';
import 'package:skin_sync/features/settings/presentation/widgets/theme_selector_dialog.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';
import 'package:skin_sync/features/streaks/presentation/bloc/streaks_bloc.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({super.key});

  static final _dateFormat = DateFormat('EEE, MMM d');

  @override
  Widget build(BuildContext context) {
    final storageService = sl<StorageService>();
    final userName =
        storageService.fetch<String>(AppConstants.userName) ?? 'Zeeshan';
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<RoutineBloc, RoutineState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == RoutineStatus.failure &&
              state.errorMessage != null) {
            SnackbarHelper.showError(context, state.errorMessage!);
          }
          if (state.status == RoutineStatus.deleted) {
            SnackbarHelper.showSuccess(context, 'Routine deleted');
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: getHeight(context, 260),
                floating: false,
                pinned: true,
                backgroundColor: theme.colorScheme.primaryContainer,
                surfaceTintColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.palette_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    tooltip: 'Change theme',
                    onPressed: () => ThemeSelectorDialog.show(context),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => context.push(AppRoutes.skinAnalysisRoute),
                  ),
                  SizedBox(width: getWidth(context, 8)),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: RoutineHeader(userName: userName),
                ),
              ),
              SliverToBoxAdapter(
                child: RoutineDateNavigation(
                  selectedDate: state.selectedDate,
                  dateFormat: _dateFormat,
                  onDateChanged: (date) {
                    context.read<RoutineBloc>().add(RoutineDateChanged(date));
                  },
                ),
              ),
              SliverFillRemaining(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: _buildContent(context, state),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createRoutineRoute),
        icon: const Icon(Icons.add),
        label: const Text('Add Routine'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RoutineState state) {
    if (state.status == RoutineStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.filteredRoutines.isEmpty) {
      return const RoutineEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(getWidth(context, 16)),
      itemCount: state.filteredRoutines.length,
      itemBuilder: (context, index) {
        final routine = state.filteredRoutines[index];
        return RoutineCard(
          routine: routine,
          isCompleted: routine.isCompletedOnDate(state.selectedDate),
          onToggleCompletion: () {
            context.read<RoutineBloc>().add(
                  RoutineCompletionToggled(routine.id),
                );
            context.read<StreaksBloc>().add(
                  const StreaksLoadRequested(),
                );
          },
          onDelete: () {
            context.read<RoutineBloc>().add(
                  RoutineDeleteRequested(routine.id),
                );
          },
        );
      },
    );
  }
}
