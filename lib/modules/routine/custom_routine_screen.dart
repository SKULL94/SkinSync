import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skin_sync/modules/layout/layout_screen.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:uuid/uuid.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
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
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 30),
                _buildIconUploadSection(),
                const SizedBox(height: 30),
                _buildFormFields(),
                const SizedBox(height: 30),
                _buildTimeSelector(),
                const SizedBox(height: 30),
                _buildStartDateSection(),
                const SizedBox(
                  height: 10,
                ),
                _buildEndDateSection(),
                const SizedBox(height: 40),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('New Skin Routine',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                )),
        Text('Create your personalized skincare regimen',
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }

  Widget _buildIconUploadSection() {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: GestureDetector(
              onTap: _pickIcon,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 2,
                  ),
                ),
                child: _localIcon != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_localIcon!, fit: BoxFit.cover),
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
          if (_localIcon != null)
            TextButton(
              onPressed: _pickIcon,
              child: const Text('Change Icon',
                  style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Routine Name',
            hintText: 'e.g., Morning Glow Routine',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
          ),
          style: TextStyle(color: Colors.grey[800], fontSize: 15),
          validator: (value) => value!.isEmpty ? 'Required field' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _descController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            alignLabelWithHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
          ),
          style: TextStyle(color: Colors.grey[800], fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded,
                color: Theme.of(context).primaryColor),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Routine Time',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 4),
                Text(_selectedTime.format(context),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800])),
              ],
            ),
            const Spacer(),
            Text('Change',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline_rounded),
        label: const Text('Save Routine',
            style: TextStyle(fontWeight: FontWeight.w500)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: _saveRoutine,
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

  Widget _buildStartDateSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Set Start Date'),
          value: _startDate != null,
          onChanged: (value) {
            if (value) {
              _selectStartDate();
            } else {
              setState(() => _startDate = null);
            }
          },
        ),
        if (_startDate != null)
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
                'Start Date: ${DateFormat('MMM d, y').format(_startDate!)}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _selectStartDate,
            ),
          ),
      ],
    );
  }

  Widget _buildEndDateSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Set End Date'),
          value: _endDate != null,
          onChanged: (value) {
            if (value) {
              _selectEndDate();
            } else {
              setState(() => _endDate = null);
            }
          },
        ),
        if (_endDate != null)
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title:
                Text('End Date: ${DateFormat('MMM d, y').format(_endDate!)}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _selectEndDate,
            ),
          ),
      ],
    );
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

    final controller = Get.find<RoutineController>();
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

    controller.addCustomRoutine(
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
