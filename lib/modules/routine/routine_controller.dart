import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoutineController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<CustomRoutine> routines = <CustomRoutine>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchRoutines();
    super.onInit();
  }

  Future<String> uploadImage(
      File image, String userId, String routineId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'users/$userId/images/$routineId/$fileName';
      final supabase = Supabase.instance.client;

      await supabase.storage.from('images').upload(filePath, image,
          fileOptions: const FileOptions(contentType: 'image/jpeg'));

      return supabase.storage.from('images').getPublicUrl(filePath);
    } catch (e) {
      Get.snackbar('Upload Error', 'Failed to upload image: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateRoutineImage(String routineId, File image) async {
    try {
      final userId = StorageService.instance.fetch(AppUtils.userId);
      final imageUrl = await uploadImage(image, userId, routineId);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('routines')
          .doc(routineId)
          .update({'imagePath': imageUrl});

      final index = routines.indexWhere((r) => r.id == routineId);
      if (index != -1) {
        routines[index] = routines[index].copyWith(imagePath: imageUrl);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update image: ${e.toString()}');
    }
  }

  Future<void> fetchRoutines() async {
    try {
      isLoading(true);
      final userId = StorageService.instance.fetch(AppUtils.userId);
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('routines')
          .orderBy('createdDate')
          .get();

      routines.assignAll(
        snapshot.docs.map((doc) => CustomRoutine.fromMap(doc.data())).toList(),
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> addCustomRoutine({
    required String name,
    required String description,
    required TimeOfDay time,
    String imagePath = '',
    String localIconPath = '',
  }) async {
    try {
      final userId = StorageService.instance.fetch(AppUtils.userId);
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('routines')
          .doc();

      final newRoutine = CustomRoutine(
          id: docRef.id,
          name: name,
          description: description,
          time: time,
          userId: userId,
          createdDate: DateTime.now(),
          imagePath: imagePath,
          localIconPath: localIconPath);

      await docRef.set(newRoutine.toMap());
      routines.add(newRoutine);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save routine: ${e.toString()}');
    }
  }

  Future<void> deleteRoutine(String id) async {
    try {
      // Delete local icon
      final routine = routines.firstWhere((r) => r.id == id);
      if (routine.localIconPath.isNotEmpty) {
        final file = File(routine.localIconPath);
        if (await file.exists()) await file.delete();
      }

      // Delete from Firestore
      final userId = StorageService.instance.fetch(AppUtils.userId);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('routines')
          .doc(id)
          .delete();

      routines.removeWhere((routine) => routine.id == id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete routine: ${e.toString()}');
    }
  }
}
