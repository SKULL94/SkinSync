import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/modules/routine/custom_routine_screen.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/build_routine_list.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/date_navigation.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/empty_state.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/loading_state.dart';
import 'package:skin_sync/utils/mediaquery.dart';
import 'package:skin_sync/utils/storage.dart';

class RoutineScreen extends StatelessWidget {
  RoutineScreen({super.key});

  final RoutineController controller = Get.find<RoutineController>();
  final DateFormat dateFormat = DateFormat('EEE, MMM d');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${StorageService.instance.fetch('userName') ?? 'Zeeshan'} 👋',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: getResponsiveFontSize(context, 18),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              final newTheme = Get.isDarkMode ? 'light' : 'dark';
              Get.changeThemeMode(
                  newTheme == 'dark' ? ThemeMode.dark : ThemeMode.light);
              StorageService.instance.save('theme', newTheme);
            },
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        final today = DateTime.now();
        final selectedDate = controller.selectedDate.value;
        final isPastDate =
            selectedDate.isBefore(DateTime(today.year, today.month, today.day));
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add_task_rounded),
          label: const Text("New Routine"),
          onPressed: isPastDate
              ? null
              : () => Get.to(() => const CreateRoutineScreen()),
        );
      }),
      body: Column(
        children: [
          RoutineScreenDateNavigation(
              controller: controller, dateFormat: dateFormat),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const RoutineScreenLoadingState();
              }
              return controller.routines.isEmpty
                  ? const RoutineScreenEmptyState()
                  : RoutineScreenRoutineList(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}
