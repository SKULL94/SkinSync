import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/routine_screen.dart';
import 'package:uuid/uuid.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateRoutineScreenState createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _localIcon;
  final Uuid _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Routine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRoutine,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildIconUploadSection(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Routine Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter routine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Select Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconUploadSection() {
    return GestureDetector(
      onTap: _pickIcon,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: _localIcon != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_localIcon!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 30),
                  SizedBox(height: 8),
                  Text('Add Icon', style: TextStyle(fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Future<void> _pickIcon() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _localIcon = File(pickedFile.path));
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
      Get.snackbar('Error', 'Failed to save icon: ${e.toString()}');
      return null;
    }
  }

  void _saveRoutine() async {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<RoutineController>();
      final routineId = _uuid.v4();
      final localIconPath = await _saveIconLocally(routineId);

      controller.addCustomRoutine(
        name: _nameController.text,
        description: _descController.text,
        time: _selectedTime,
        localIconPath: localIconPath ?? '',
      );

      Get.snackbar('Saved', 'Routine created successfully');
      await Future.delayed(const Duration(seconds: 1));
      Get.to(const RoutineScreen());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
