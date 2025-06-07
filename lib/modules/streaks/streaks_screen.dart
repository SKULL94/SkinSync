import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';
import 'package:skin_sync/modules/streaks/widgets/streak_chart_section.dart';
import 'package:skin_sync/modules/streaks/widgets/streak_header.dart';
import 'package:skin_sync/modules/streaks/widgets/streak_motivation_section.dart';
import 'package:skin_sync/modules/streaks/widgets/streak_progress.dart';
import 'package:skin_sync/modules/streaks/widgets/streak_type_selector.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/app_bar.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class StreaksScreen extends StatelessWidget {
  StreaksScreen({super.key});

  final StreaksController controller = Get.find();
  final RoutineController routineController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Streaks',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: CustomAppBar.appBarFontSize,
          ),
        ),
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () => Get.offAllNamed(AppRoutes.authRoute),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Obx(() => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isFetchingStreaksData) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: getHeight(context, 16),
        horizontal: getWidth(context, 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreakTypeSelector(controller: controller),
          SizedBox(height: getHeight(context, 20)),
          StreakHeader(controller: controller),
          SizedBox(height: getHeight(context, 20)),
          StreakProgressCard(
            controller: controller,
            routineController: routineController,
          ),
          SizedBox(height: getHeight(context, 30)),
          StreakChartSection(controller: controller),
          SizedBox(height: getHeight(context, 30)),
          const MotivationSection(),
        ],
      ),
    );
  }
}
