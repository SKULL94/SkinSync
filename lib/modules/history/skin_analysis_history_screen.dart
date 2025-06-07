import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:skin_sync/modules/history/skin_analysis_history_controller.dart';
import 'package:skin_sync/utils/app_bar.dart';
import 'package:skin_sync/utils/app_constants.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Analysis History',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: CustomAppBar.appBarFontSize,
          ),
        ),
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => controller.deleteAllHistories(),
          ),
        ],
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.histories.length,
            itemBuilder: (context, index) {
              final history = controller.histories[index];
              final isPlaceholder =
                  history.imageUrl == AppConstants.placeholderImageUrl;
              return ListTile(
                leading: isPlaceholder
                    ? const Icon(Icons.hourglass_top, size: 50)
                    : Image.file(
                        File(history.imageUrl),
                        width: 50,
                        height: 50,
                      ),
                title: Text(history.results[0]['displayLabel']),
                subtitle: Text(history.date.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  // need to work on this.
                  onPressed: () => controller.deleteHistory(history.id),
                ),
              );
            },
          )),
    );
  }
}
