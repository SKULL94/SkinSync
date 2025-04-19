import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/storage.dart';

class AuthController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  PhoneAuthCredential? confirmationResult;

  final Rx<TextEditingController> _otpController = Rx(TextEditingController());
  final Rx<TextEditingController> _mobileNumberController =
      Rx(TextEditingController());
  final RxBool _isOtpSent = RxBool(false);
  final RxBool _isLoading = RxBool(false);
  final RxString _verificationIdd = RxString("");
  final RxString _userPhoneNumber = RxString("");
  final Rx<GlobalKey<FormState>> _authFormKey = Rx(GlobalKey<FormState>());

  GlobalKey<FormState> get authFormKey => _authFormKey.value;
  String get userPhoneNumber => _userPhoneNumber.value;
  String get verificationIdd => _verificationIdd.value;
  bool get isLoading => _isLoading.value;
  bool get isOtpSent => _isOtpSent.value;
  TextEditingController get mobileNumberController =>
      _mobileNumberController.value;
  TextEditingController get otpController => _otpController.value;

  @override
  void dispose() {
    otpController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  void updateIsOtpSent(bool value) => _isOtpSent.value = value;
  void updateIsLoading(bool value) => _isLoading.value = value;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    if (!authFormKey.currentState!.validate()) return;

    updateIsLoading(true);
    try {
      _userPhoneNumber.value = phoneNumber;
      await auth.verifyPhoneNumber(
        phoneNumber: "+91$phoneNumber",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async =>
            await _handleVerificationComplete(credential),
        verificationFailed: (e) => _handleVerificationFailed(e),
        codeSent: (verificationId, _) => _handleCodeSent(verificationId),
        codeAutoRetrievalTimeout: (verificationId) =>
            _verificationIdd.value = verificationId,
      );
    } catch (e) {
      updateIsLoading(false);
      Get.snackbar("Error", "Failed to verify phone number: $e");
    }
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    updateIsLoading(true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationIdd,
        smsCode: smsCode,
      );

      final userCredential = await auth.signInWithCredential(credential);
      final userId = userCredential.user!.uid;

      await _handleNewUserSetup(userId);
      await _postAuthentication(userId);
    } on FirebaseAuthException catch (error) {
      if (error.code == "invalid-verification-code") {
        Get.snackbar("Error", "Wrong OTP, please try again");
      }
    } catch (e) {
      updateIsLoading(false);
      Get.snackbar("Error", "Failed to sign in: ${e.toString()}");
    }
  }

  Future<void> _handleVerificationComplete(
      PhoneAuthCredential credential) async {
    await auth.signInWithCredential(credential);
    updateIsOtpSent(true);
  }

  void _handleVerificationFailed(FirebaseAuthException e) {
    updateIsLoading(false);
    Get.snackbar("Error", "Verification failed: ${e.message}");
  }

  void _handleCodeSent(String verificationId) {
    _verificationIdd.value = verificationId;
    updateIsLoading(false);
    updateIsOtpSent(true);
  }

  Future<void> _handleNewUserSetup(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      await _firestore.collection('users').doc(userId).set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'streakCount': 0,
        'lastUpdatedDay': DateTime.now().toString().split(' ')[0],
      });
    }
  }

  Future<void> _postAuthentication(String userId) async {
    StorageService.instance.save(AppUtils.userId, userId);
    updateIsLoading(false);
    Get.snackbar("Success", "Authentication successful");
    await checkExistingRoutines(userId);
  }

// modules/auth/auth_controller.dart
  Future<void> checkExistingRoutines(String userId) async {
    try {
      // Initialize controller before checking routines
      Get.put(RoutineController());
      final routineController = Get.find<RoutineController>();
      await routineController.fetchRoutines();

      if (routineController.routines.isEmpty) {
        Get.offAllNamed(AppRoutes.createRoutineRoute);
      } else {
        Get.offAllNamed(AppRoutes.layoutRoute);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.layoutRoute);
    }
  }
}
