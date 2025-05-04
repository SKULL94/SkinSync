import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/build_form_fields.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/build_icon_upload.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/end_date.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/header.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/save_button.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/start_date.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/time_selector.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CreateRoutineScreen extends StatelessWidget {
  CreateRoutineScreen({super.key});
  final controller = Get.put(RoutineController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Routine'),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: getWidth(context, 20),
              vertical: getHeight(context, 20)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomRoutineHeader(),
                SizedBox(height: getHeight(context, 30)),
                Obx(() => IconUploadSection(
                      localIcon: controller.localIcon.value,
                      onPickIcon: controller.pickImage,
                    )),
                SizedBox(height: getHeight(context, 30)),
                CustomRoutineFormField(
                    controller: controller.nameController,
                    descController: controller.descController,
                    isTablet: isTablet(context)),
                SizedBox(height: getHeight(context, 30)),
                Obx(() => CustomRoutineTimeSelector(
                      onSelectTime: () => controller.selectTime(context),
                      selectedTime: controller.selectedTime.value,
                    )),
                SizedBox(height: getHeight(context, 30)),
                Obx(() => CustomRoutineStartDateSelector(
                      startDate: controller.startDate.value,
                      isEnabled: controller.startDate.value != null,
                      onToggle: (value) => value
                          ? controller.selectStartDate(context)
                          : controller.startDate.value = null,
                      onDateChanged: () => controller.selectStartDate(context),
                    )),
                SizedBox(height: getHeight(context, 30)),
                Obx(() => CustomRoutineEndDateSelector(
                      startDate: controller.endDate.value,
                      isEnabled: controller.endDate.value != null,
                      onToggle: (value) => value
                          ? controller.selectEndDate(
                              context,
                            )
                          : controller.endDate.value = null,
                      onDateChanged: () => controller.selectEndDate(context),
                    )),
                SizedBox(height: getHeight(context, 40)),
                CustomRoutineSaveButton(
                    saveRoutine: () => controller.saveRoutine())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
