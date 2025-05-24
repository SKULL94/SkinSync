import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/modules/layout/layout_screen.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/notification_service.dart';
import 'package:skin_sync/utils/storage.dart';
import 'package:uuid/uuid.dart';

class RoutineController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();
  final RxBool isImageLoading = false.obs;

  final RxList<CustomRoutine> routines = <CustomRoutine>[].obs;
  final RxList<CustomRoutine> filteredRoutines = <CustomRoutine>[].obs;
  final RxBool isLoading = false.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  final Rx<File?> localIcon = Rx<File?>(null);
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  String get _userId => StorageService.instance.fetch(AppUtils.userId);
  CollectionReference get _userRoutines =>
      _firestore.collection('users').doc(_userId).collection('routines');

  @override
  void onInit() {
    super.onInit();
    selectedDate.listen((_) => _filterRoutines());
  }

  Future<XFile?> pickImage(ImageSource source) async {
    isImageLoading.value = true;
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        localIcon.value = File(pickedFile.path);
        return pickedFile;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: ${e.toString()}");
    } finally {
      isImageLoading.value = false;
    }
    return null;
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
            secondary: Theme.of(context).primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) selectedTime.value = picked;
  }

  Future<void> selectDate(BuildContext context,
      {required bool isStartDate}) async {
    final initialDate =
        isStartDate ? startDate.value : endDate.value ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      isStartDate ? startDate.value = picked : endDate.value = picked;
    }
  }

  Future<void> saveRoutine() async {
    try {
      final routineId = _uuid.v4();
      final iconPath = await _saveLocalIcon(routineId);

      final newRoutine = CustomRoutine(
        id: routineId,
        name: nameController.text.trim(),
        description: descController.text.trim(),
        time: selectedTime.value,
        userId: _userId,
        createdDate: DateTime.now(),
        localIconPath: iconPath ?? '',
        startDate: startDate.value,
        endDate: endDate.value,
        isCompleted: false,
        completionProgress: 0.0,
        completionDates: [],
        imagePath: '',
      );

      await _userRoutines.doc(routineId).set(newRoutine.toMap());
      routines.add(newRoutine);
      _filterRoutines();
      await _notificationService.scheduleCustomRoutines();
      _showSuccess('Routine created successfully!');
      Get.off(() => const LayoutScreen());
    } catch (e) {
      _showError('Failed to save routine', e);
    }
  }

  Future<void> fetchRoutines() async {
    try {
      isLoading.value = true;
      final QuerySnapshot<Object?> snapshot =
          await _userRoutines.orderBy('createdDate').get();
      routines.assignAll(snapshot.docs
          .map((d) => CustomRoutine.fromMap(d.data() as Map<String, dynamic>)));
      _filterRoutines();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleRoutineCompletion(String routineId) async {
    try {
      final int index = routines.indexWhere((r) => r.id == routineId);
      if (index == -1) return;

      final CustomRoutine updated =
          routines[index].toggleCompletion(selectedDate.value);
      await _userRoutines.doc(routineId).update(updated.toMap());
      routines[index] = updated;
      // await _updateUserCompletedDays();
      _filterRoutines();
    } catch (e) {
      _showError('Failed to toggle completion', e);
    }
  }

  Future<void> deleteRoutine(String id) async {
    try {
      final CustomRoutine routine = routines.firstWhere((r) => r.id == id);
      await _userRoutines.doc(id).delete();
      await _notificationService.cancelRoutineNotifications(routine);
      routines.removeWhere((r) => r.id == id);
      _filterRoutines();
    } catch (e) {
      _showError('Failed to delete routine', e);
    }
  }

  // void updateSelectedDate(int days) {
  //   selectedDate.value = selectedDate.value.add(Duration(days: days));
  // }

  bool isDateCompleted(CustomRoutine routine) {
    return routine.completionDates
        .any((d) => DateUtils.isSameDay(d, selectedDate.value));
  }

  int get completedCount {
    return filteredRoutines.where((r) => isDateCompleted(r)).length;
  }

  Future<String?> _saveLocalIcon(String routineId) async {
    if (localIcon.value == null) return null;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final iconDir = Directory('${directory.path}/routine_icons');
      if (!await iconDir.exists()) await iconDir.create(recursive: true);

      final path = '${iconDir.path}/$routineId.png';
      await localIcon.value!.copy(path);
      return path;
    } catch (e) {
      _showError('Failed to save icon', e);
      return null;
    }
  }

  void _filterRoutines() {
    filteredRoutines.value = routines.where((routine) {
      final selected = selectedDate.value;
      final start = DateTime(routine.startDate.year, routine.startDate.month,
          routine.startDate.day);
      final end = routine.endDate != null
          ? DateTime(routine.endDate!.year, routine.endDate!.month,
              routine.endDate!.day)
          : null;

      return end == null
          ? DateUtils.isSameDay(start, selected)
          : selected.isAfter(start.subtract(1.days)) &&
              selected.isBefore(end.add(1.days));
    }).toList();
  }

  // Future<void> _updateUserCompletedDays() async {
  //   final String formattedDate =
  //       DateFormat('yyyy-MM-dd').format(selectedDate.value);
  //   final bool hasCompleted = filteredRoutines.any((r) => isDateCompleted(r));

  //   try {
  //     await _firestore.collection('users').doc(_userId).update({
  //       'completedDays': FieldValue.arrayUnion([formattedDate])
  //     });
  //   } on FirebaseException catch (e) {
  //     if (e.code == 'not-found') {
  //       await _firestore.collection('users').doc(_userId).set({
  //         'completedDays': hasCompleted ? [formattedDate] : [],
  //       }, SetOptions(merge: true));
  //     }
  //   }
  // }

  void _showSuccess(String message) => Get.showSnackbar(
        GetSnackBar(
          message: message,
          duration: 2.seconds,
          backgroundColor: Colors.green[400]!,
          snackPosition: SnackPosition.TOP,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        ),
      );

  void _showError(String message, dynamic e) => Get.snackbar(
        'Error',
        '$message: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
}

class DateUtils {
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
