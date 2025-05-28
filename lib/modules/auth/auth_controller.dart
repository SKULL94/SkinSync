import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/custom_snackbar.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/storage.dart';

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RoutineController routineController = Get.find<RoutineController>();

  final RxBool isLogin = true.obs;
  final RxBool showPhoneAuth = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isOtpSent = false.obs;
  final RxString verificationId = ''.obs;
  RxString phoneNumber = ''.obs;
  final RxBool useEmailMethod = true.obs;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void toggleAuthType(bool isLoginValue) => isLogin.value = isLoginValue;

  Future<void> handleAuth() async {
    await handlePhoneAuth();
  }

  Future<void> handlePhoneAuth() async {
    if (isOtpSent.value) {
      await verifyOtp();
    } else {
      await verifyPhoneNumber();
    }
  }

  Future<void> verifyPhoneNumber() async {
    if (phoneNumber.value.isEmpty) {
      showErrorSnackbar('Error', 'Please enter a valid phone number');
      return;
    }
    isLoading(true);
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.value,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          await auth.signInWithCredential(credential);
          await handleSuccessfulAuth(auth.currentUser!.uid);
          isLoading(false);
        },
        verificationFailed: (e) {
          showErrorSnackbar('Error', 'Verification failed: ${e.message}');
          isLoading(false);
        },
        codeSent: (verificationId, [forceResendingToken]) {
          this.verificationId.value = verificationId;
          isOtpSent(true);
          isLoading(false);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          this.verificationId.value = verificationId;
        },
      );
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to verify phone number: $e');
      isLoading(false);
    }
  }

  Future<void> verifyOtp() async {
    isLoading(true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otpController.text,
      );
      final userCredential = await auth.signInWithCredential(credential);
      await handleSuccessfulAuth(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      showErrorSnackbar('Error', 'Invalid OTP: ${e.message}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> handleSuccessfulAuth(String userId) async {
    StorageService.instance.save(AppUtils.userId, userId);
    showErrorSnackbar('Success', 'Authentication successful');
    await checkExistingRoutines(userId);
  }

  Future<void> checkExistingRoutines(String userId) async {
    try {
      await routineController.fetchRoutines();
      Get.offAllNamed(AppRoutes.layoutRoute);
    } catch (e) {
      Get.offAllNamed(AppRoutes.layoutRoute);
    }
  }
}
