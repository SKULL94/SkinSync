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
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: GestureDetector(
              onTap: onPickIcon,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!, width: 2),
                ),
                child: localIcon != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          localIcon!,
                          width: 120,
                          height: 120,
                          cacheWidth: 240,
                          cacheHeight: 240,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              size: 32, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('Add Icon',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13)),
                        ],
                      ),
              ),
            ),
          ),
          if (localIcon != null)
            TextButton(
              onPressed: onPickIcon,
              child: const Text('Change Icon',
                  style: TextStyle(color: Colors.blue, fontSize: 14)),
            ),
        ],
      ),
    );
  }
}
