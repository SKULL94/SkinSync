import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skin_sync/features/routine/domain/entities/routine_entity.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';

class RoutineCard extends StatelessWidget {
  final RoutineEntity routine;
  final bool isCompleted;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.isCompleted,
    required this.onToggleCompletion,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: getHeight(context, 12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onToggleCompletion,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(getWidth(context, 16)),
          child: Row(
            children: [
              _buildIcon(context, theme),
              SizedBox(width: getWidth(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (routine.description.isNotEmpty) ...[
                      SizedBox(height: getHeight(context, 4)),
                      Text(
                        routine.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: getHeight(context, 4)),
                    Text(
                      routine.time.format(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCheckbox(context, theme),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ThemeData theme) {
    if (routine.localIconPath.isNotEmpty) {
      final file = File(routine.localIconPath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: getWidth(context, 50),
            height: getWidth(context, 50),
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return Container(
      width: getWidth(context, 50),
      height: getWidth(context, 50),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.face,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, ThemeData theme) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? theme.colorScheme.primary
            : Colors.transparent,
        border: Border.all(
          color: isCompleted
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              size: 18,
              color: Colors.white,
            )
          : null,
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Routine'),
        content: Text('Are you sure you want to delete "${routine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
