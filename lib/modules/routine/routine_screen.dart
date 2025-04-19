import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/modules/routine/custom_routine_screen.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoutineController());

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Custom Daily Routine"),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Get.to(() => const CreateRoutineScreen()),
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (controller.routines.isEmpty) {
              return const Center(
                child: Text(
                  "Your routine list is empty - let's add one!",
                  style: TextStyle(fontSize: 16),
                ),
              );
            } else {
              return _buildRoutineList(controller);
            }
          }),
        ));
  }

  Widget _buildImageWidget(
      CustomRoutine routine, RoutineController controller) {
    return GestureDetector(
      onTap: () async => await _handleImageUpload(routine.id, controller),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: routine.imagePath.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  routine.imagePath,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.camera_alt, color: Colors.grey),
      ),
    );
  }

  Future<void> _handleImageUpload(
      String routineId, RoutineController controller) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await controller.updateRoutineImage(routineId, imageFile);
    }
  }

  Widget _buildRoutineList(RoutineController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.routines.length,
      itemBuilder: (context, index) {
        final routine = controller.routines[index];
        return Dismissible(
          key: Key(routine.id),
          background: Container(color: Colors.red),
          onDismissed: (_) => controller.deleteRoutine(routine.id),
          child: Stack(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildLocalIcon(routine),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(routine.name,
                                    style: const TextStyle(fontSize: 18)),
                                Text(routine.description),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (routine.imagePath.isNotEmpty)
                        _buildSupabaseImage(routine),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          routine.time.format(context),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(child: _buildImageWidget(routine, controller)),
                    ],
                  ),
                ),
              ),

              // Positioned Delete Icon (top-right cross)
              Positioned(
                right: -17,
                top: -17,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => controller.deleteRoutine(routine.id),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocalIcon(CustomRoutine routine) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: routine.localIconPath.isNotEmpty
            ? DecorationImage(
                image: FileImage(File(routine.localIconPath)),
                fit: BoxFit.cover)
            : null,
      ),
      child: routine.localIconPath.isEmpty
          ? const Icon(Icons.photo_camera, size: 30)
          : null,
    );
  }

  Widget _buildSupabaseImage(CustomRoutine routine) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: routine.imagePath,
        placeholder: (context, url) =>
            Container(height: 200, color: Colors.grey[200]),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
      ),
    );
  }
}
