import 'dart:io';
import 'package:flutter/material.dart';

class IconUploadSection extends StatelessWidget {
  final File? localIcon;
  final VoidCallback onPickIcon;

  const IconUploadSection({
    super.key,
    required this.localIcon,
    required this.onPickIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
            child: GestureDetector(
              onTap: onPickIcon,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: localIcon != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.file(
                          localIcon!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.add_a_photo_rounded,
                        size: 32,
                        color: theme.primaryColor,
                      ),
              ),
            ),
          ),
          if (localIcon != null)
            TextButton.icon(
              icon: Icon(Icons.edit, size: 18),
              label: const Text('Change Icon'),
              onPressed: onPickIcon,
              style: TextButton.styleFrom(
                foregroundColor: theme.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
