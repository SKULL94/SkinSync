import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skin_sync/modules/layout/layout_screen.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/build_form_fields.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/build_icon_upload.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/end_date.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/header.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/save_button.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/start_date.dart';
import 'package:skin_sync/modules/routine/widgets/custom_routine_screen_widget.dart/time_selector.dart';
import 'package:skin_sync/utils/mediaquery.dart';
import 'package:uuid/uuid.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final controller = Get.find<RoutineController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _localIcon;
  final Uuid _uuid = const Uuid();
  DateTime? _endDate;
  DateTime? _startDate = DateTime.now();

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
                IconUploadSection(localIcon: _localIcon, onPickIcon: _pickIcon),
                SizedBox(height: getHeight(context, 30)),
                CustomRoutineFormField(
                    controller: _nameController,
                    descController: _descController,
                    isTablet: isTablet(context)),
                SizedBox(height: getHeight(context, 30)),
                CustomRoutineTimeSelector(
                    onSelectTime: _selectTime, selectedTime: _selectedTime),
                SizedBox(height: getHeight(context, 30)),
                CustomRoutineStartDateSelector(
                  startDate: _startDate,
                  isEnabled: _startDate != null,
                  onToggle: (value) => setState(() {
                    if (value) {
                      _selectStartDate();
                    } else {
                      _startDate = null;
                    }
                  }),
                  onDateChanged: _selectStartDate,
                ),
                SizedBox(height: getHeight(context, 30)),
                CustomRoutineEndDateSelector(
                  startDate: _endDate,
                  isEnabled: _endDate != null,
                  onToggle: (value) => setState(() {
                    if (value) {
                      _selectEndDate();
                    } else {
                      _endDate = null;
                    }
                  }),
                  onDateChanged: _selectEndDate,
                ),
                SizedBox(height: getHeight(context, 40)),
                CustomRoutineSaveButton(saveRoutine: _saveRoutine),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickIcon() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _localIcon = File(pickedFile.path));
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
            secondary: Theme.of(context).primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<String?> _saveIconLocally(String routineId) async {
    if (_localIcon == null) return null;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final routineIconsDir = Directory('${directory.path}/routine_icons');
      if (!await routineIconsDir.exists()) {
        await routineIconsDir.create(recursive: true);
      }
      final iconPath = '${routineIconsDir.path}/$routineId.png';
      await _localIcon!.copy(iconPath);
      return iconPath;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save icon: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100]);
      return null;
    }
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => _startDate = pickedDate);
    }
  }

  Future<void> _selectEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _endDate = pickedDate);
    }
  }

  void _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;
    final routineId = _uuid.v4();
    final localIconPath = await _saveIconLocally(routineId);
    final startDate = _startDate != null
        ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day)
        : DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);

    DateTime? endDate;
    if (_endDate != null) {
      endDate = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
    }

    await controller.addCustomRoutine(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      time: _selectedTime,
      localIconPath: localIconPath ?? '',
      startDate: startDate,
      endDate: endDate,
    );

    Get.off(() => const LayoutScreen());
    Get.showSnackbar(GetSnackBar(
      message: 'Routine created successfully!',
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green[400]!,
      snackPosition: SnackPosition.TOP,
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
