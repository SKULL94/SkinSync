import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/modules/layout/layout_screen.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/notification_service.dart';
import 'package:skin_sync/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class RoutineController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<CustomRoutine> routines = <CustomRoutine>[].obs;
  final RxBool isLoading = false.obs;
  final Uuid _uuid = const Uuid();

  // Form state
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  final Rx<File?> localIcon = Rx<File?>(null);
  final Rx<DateTime?> startDate = DateTime.now().obs;
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // Date management
  DateTime get currentDate => DateTime.now();
  final selectedDate = DateTime.now().obs;
  RxList<CustomRoutine> filteredRoutines = <CustomRoutine>[].obs;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      localIcon.value = File(pickedFile.path);
    }
  }

  Future<String?> saveIconLocally(String routineId) async {
    if (localIcon.value == null) return null;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final routineIconsDir = Directory('${directory.path}/routine_icons');
      if (!await routineIconsDir.exists()) {
        await routineIconsDir.create(recursive: true);
      }
      final iconPath = '${routineIconsDir.path}/$routineId.png';
      await localIcon.value!.copy(iconPath);
      return iconPath;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save icon: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100]);
      return null;
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
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
      selectedTime.value = picked;
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      endDate.value = pickedDate;
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      startDate.value = pickedDate;
    }
  }

  Future<void> saveRoutine() async {
    try {
      final routineId = _uuid.v4();
      final localIconPath = await saveIconLocally(routineId);

      final newRoutine = CustomRoutine(
        id: routineId,
        name: nameController.text.trim(),
        description: descController.text.trim(),
        time: selectedTime.value,
        userId: StorageService.instance.fetch(AppUtils.userId),
        createdDate: DateTime.now(),
        localIconPath: localIconPath ?? '',
        startDate: startDate.value!,
        endDate: endDate.value,
        isCompleted: false,
        completionProgress: 0.0,
        completionDates: [],
        imagePath: '',
      );

      await _firestore
          .collection('users')
          .doc(newRoutine.userId)
          .collection('routines')
          .doc(routineId)
          .set(newRoutine.toMap());

      routines.add(newRoutine);
      updateFilteredRoutines();
      await NotificationService().scheduleCustomRoutines();

      Get.off(() => const LayoutScreen());
      Get.showSnackbar(GetSnackBar(
        message: 'Routine created successfully!',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green[400]!,
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
      ));
    } catch (e) {
      Get.snackbar('Error', 'Failed to save routine: ${e.toString()}');
    }
  }

  void updateFilteredRoutines() {
    filteredRoutines.value = routines.where((routine) {
      final selected = selectedDate.value;
      final selectedDateAtMidnight =
          DateTime(selected.year, selected.month, selected.day);

      final startDate = routine.startDate;
      final startDateAtMidnight =
          DateTime(startDate.year, startDate.month, startDate.day);

      final endDate = routine.endDate;
      DateTime? endDateAtMidnight;
      if (endDate != null) {
        endDateAtMidnight = DateTime(endDate.year, endDate.month, endDate.day);
      }

      if (endDateAtMidnight == null) {
        return _isSameDate(startDateAtMidnight, selectedDateAtMidnight);
      } else {
        return selectedDateAtMidnight.isAfter(
                startDateAtMidnight.subtract(const Duration(days: 1))) &&
            selectedDateAtMidnight
                .isBefore(endDateAtMidnight.add(const Duration(days: 1)));
      }
    }).toList();
  }

  bool isDateCompleted(CustomRoutine routine) {
    return routine.completionDates
        .any((d) => _isSameDate(d, selectedDate.value));
  }

  void changeDate(int days) {
    selectedDate.value = selectedDate.value.add(Duration(days: days));
  }

  int get completedRoutinesCount => filteredRoutines
      .where((r) =>
          r.completionDates.any((d) => _isSameDate(d, selectedDate.value)))
      .length;

  @override
  void onInit() {
    ever(selectedDate, (_) => updateFilteredRoutines());
    super.onInit();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
      updateFilteredRoutines();
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleRoutineCompletion(String routineId) async {
    try {
      final userId = StorageService.instance.fetch(AppUtils.userId);
      if (userId == null) throw 'User not logged in';

      final index = routines.indexWhere((r) => r.id == routineId);
      if (index == -1) return;

      final oldRoutine = routines[index];
      final selectedDateDay = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
      );

      List<DateTime> newDates = List.from(oldRoutine.completionDates);
      final isDateCompleted =
          newDates.any((d) => _isSameDate(d, selectedDateDay));
      isDateCompleted
          ? newDates.removeWhere((d) => _isSameDate(d, selectedDateDay))
          : newDates.add(selectedDateDay);

      final progress = _calculateProgress(newDates);
      final updatedRoutine = oldRoutine.copyWith(
        completionDates: newDates,
        completionProgress: progress,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('routines')
          .doc(routineId)
          .update(updatedRoutine.toMap());

      routines[index] = updatedRoutine;
      updateFilteredRoutines();

      await _updateCompletedDays(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle completion: ${e.toString()}');
    }
  }

  double _calculateProgress(List<DateTime> dates) {
    if (dates.isEmpty) return 0.0;
    final now = DateTime.now();
    final thisMonthDates =
        dates.where((d) => d.month == now.month && d.year == now.year).length;
    final totalDays = DateUtils.getDaysInMonth(now.year, now.month);
    return thisMonthDates / totalDays;
  }

  Future<void> updateRoutineImage(String routineId, File image) async {
    try {
      final userId = StorageService.instance.fetch(AppUtils.userId);
      final imageUrl = await _uploadImage(image, userId, routineId);

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

  Future<void> _updateCompletedDays(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    final hasAnyCompleted = filteredRoutines.any((routine) =>
        routine.completionDates.any((d) => _isSameDate(d, selectedDate.value)));

    try {
      if (hasAnyCompleted) {
        await userRef.update({
          'completedDays': FieldValue.arrayUnion([formattedDate])
        });
      } else {
        await userRef.update({
          'completedDays': FieldValue.arrayRemove([formattedDate])
        });
      }
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        await userRef.set({
          'completedDays': hasAnyCompleted ? [formattedDate] : [],
        }, SetOptions(merge: true));
      }
    }
  }

  Future<String> _uploadImage(
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

  Future<void> addCustomRoutine({
    required String name,
    required String description,
    required TimeOfDay time,
    String imagePath = '',
    String localIconPath = '',
    required DateTime startDate,
    DateTime? endDate,
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
        localIconPath: localIconPath,
        isCompleted: false,
        completionProgress: 0.0,
        completionDates: [],
        startDate: startDate,
        endDate: endDate,
      );

      await docRef.set(newRoutine.toMap());
      routines.add(newRoutine);
      updateFilteredRoutines();
      await NotificationService().scheduleCustomRoutines();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save routine: ${e.toString()}');
    }
  }

  Future<void> deleteRoutine(String id) async {
    try {
      final routine = routines.firstWhere((r) => r.id == id);
      if (routine.localIconPath.isNotEmpty) {
        final file = File(routine.localIconPath);
        if (await file.exists()) await file.delete();
      }

      final userId = StorageService.instance.fetch(AppUtils.userId);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('routines')
          .doc(id)
          .delete();

      routines.removeWhere((r) => r.id == id);
      updateFilteredRoutines();
      final endDate = routine.endDate;
      if (endDate == null) {
        await notificationsPlugin.cancel(routine.id.hashCode);
      } else {
        final dates =
            NotificationService().getDatesInRange(routine.startDate, endDate);
        for (final date in dates) {
          await notificationsPlugin.cancel(routine.id.hashCode + date.hashCode);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete routine: ${e.toString()}');
    }
  }
}
