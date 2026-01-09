import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          StringConst.kAnalysisHistory,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: getResponsiveFontSize(context, 18),
          ),
        ),
        actions: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              if (state.histories.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _confirmDeleteAll(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<HistoryBloc, HistoryState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == HistoryStatus.failure &&
              state.errorMessage != null) {
            SnackbarHelper.showError(context, state.errorMessage!);
          }
          if (state.status == HistoryStatus.deleted) {
            SnackbarHelper.showSuccess(context, StringConst.kAnalysisDeleted);
          }
          if (state.status == HistoryStatus.deletedAll) {
            SnackbarHelper.showSuccess(context, StringConst.kAllHistoryCleared);
          }
        },
        builder: (context, state) {
          if (state.status == HistoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.histories.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return ListView.builder(
            padding: EdgeInsets.all(getWidth(context, 16)),
            itemCount: state.histories.length,
            itemBuilder: (context, index) {
              final history = state.histories[index];
              return _buildHistoryCard(context, history, theme);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: getWidth(context, 80),
            color: theme.colorScheme.outline,
          ),
          SizedBox(height: getHeight(context, 16)),
          Text(
            StringConst.kNoAnalysisHistory,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: getHeight(context, 8)),
          Text(
            StringConst.kPastAnalysesAppear,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    HistoryEntity history,
    ThemeData theme,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Card(
      margin: EdgeInsets.only(bottom: getHeight(context, 12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (history.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: history.imageUrl,
              height: getHeight(context, 150),
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: getHeight(context, 150),
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: getHeight(context, 150),
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(getWidth(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(history.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _confirmDelete(context, history.id),
                    ),
                  ],
                ),
                if (history.results.isNotEmpty) ...[
                  SizedBox(height: getHeight(context, 8)),
                  _buildTopResult(context, history.results.first, theme),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopResult(
    BuildContext context,
    Map<String, dynamic> result,
    ThemeData theme,
  ) {
    final displayLabel = result['displayLabel'] ?? 'Unknown';
    final confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;
    final riskLevel = result['riskLevel'] ?? 'Unknown';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                riskLevel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${(confidence * 100).toStringAsFixed(1)}%',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(StringConst.kDeleteAnalysis),
        content: const Text(StringConst.kDeleteAnalysisConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(StringConst.kCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HistoryBloc>().add(HistoryDeleteRequested(id));
            },
            child: const Text(StringConst.kDelete),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(StringConst.kClearAllHistory),
        content: const Text(
          StringConst.kClearAllHistoryConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(StringConst.kCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<HistoryBloc>()
                  .add(const HistoryDeleteAllRequested());
            },
            child: const Text(StringConst.kDeleteAll),
          ),
        ],
      ),
    );
  }
}
