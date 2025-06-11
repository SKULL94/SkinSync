import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/build_routine_list.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/camera_button.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/custom_floating_button.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/date_navigation.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/empty_state.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/loading_state.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/theme_toggle.dart';
import 'package:skin_sync/modules/skin-analysis/controller/camera_service_controller.dart';
import 'package:skin_sync/utils/app_bar.dart';
import 'package:skin_sync/utils/app_constants.dart';
import 'package:skin_sync/utils/mediaquery.dart';
import 'package:skin_sync/services/storage.dart';

class RoutineScreen extends GetView<RoutineController> {
  RoutineScreen({super.key});

  static final _dateFormat = DateFormat('EEE, MMM d');
  final userName =
      StorageService.instance.fetch(AppConstants.userName) ?? 'Zeeshan';
  final RoutineController controller = Get.find();
  final CameraServiceController cameraService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, $userName',
          style: TextStyle(
            fontWeight: FontWeight.w600, // Increased weight for professionalism
            fontSize: CustomAppBar.appBarFontSize,
          ),
        ),
        centerTitle: false,
        surfaceTintColor: Colors.transparent, // More modern appearance
        actions: [
          CameraButton(controller: controller, cameraService: cameraService),
          SizedBox(width: getWidth(context, 8)),
          const ThemeToggleButton(),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(controller: controller),
      body: Column(
        children: [
          RoutineScreenDateNavigation(
            controller: controller,
            dateFormat: _dateFormat,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24))),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const RoutineScreenLoadingState();
                }
                return controller.filteredRoutines.isEmpty
                    ? const RoutineScreenEmptyState()
                    : RoutineScreenRoutineList(controller: controller);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
