import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/build_form_fields.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/build_icon_upload.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/end_date.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/header.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/save_button.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/start_date.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/time_selector.dart';
import 'package:skin_sync/utils/app_bar.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CreateRoutineScreen extends StatelessWidget {
  CreateRoutineScreen({super.key});
  final RoutineController controller = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Routine',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: CustomAppBar.appBarFontSize,
          ),
        ),
        surfaceTintColor: Theme.of(context).colorScheme.surface,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
            cacheExtent: 2000,
            padding: EdgeInsets.symmetric(
                horizontal: getWidth(context, 20),
                vertical: getHeight(context, 20)),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomRoutineHeader(),
                    SizedBox(height: getHeight(context, 30)),
                    Obx(() => IconUploadSection(
                          localIcon: controller.localIcon.value,
                          onPickIcon: () =>
                              controller.pickImage(ImageSource.camera),
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
                          onDateSelected: () =>
                              controller.selectDate(context, isStartDate: true),
                        )),
                    SizedBox(height: getHeight(context, 30)),
                    Obx(() => CustomRoutineEndDateSelector(
                          endDate: controller.endDate.value,
                          isEnabled: controller.endDate.value != null,
                          onToggle: (value) => value
                              ? controller.selectDate(context,
                                  isStartDate: false)
                              : controller.endDate.value = null,
                          onDateSelected: () => controller.selectDate(context,
                              isStartDate: false),
                        )),
                    SizedBox(height: getHeight(context, 40)),
                    CustomRoutineSaveButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          controller.saveRoutine();
                        }
                      },
                    )
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
