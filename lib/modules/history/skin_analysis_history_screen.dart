import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:skin_sync/modules/history/skin_analysis_history_controller.dart';

class HistoryScreen extends GetView<HistoryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
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
              return ListTile(
                leading: Image.network(history.imageUrl, width: 50, height: 50),
                title: Text(history.results[0]['displayLabel']),
                subtitle: Text(history.date.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => controller.deleteHistory(history.id!),
                ),
              );
            },
          )),
    );
  }
}
