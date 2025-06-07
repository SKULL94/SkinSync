import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/utils/app_constants.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/services/storage.dart';

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // TextEditingControllers
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RoutineController get routineController => Get.find<RoutineController>();

  // Observables
  final RxBool isLogin = true.obs;
  final RxBool showPhoneAuth = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isOtpSent = false.obs;
  final RxString verificationId = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxBool useEmailMethod = true.obs;

  @override
  void dispose() {
    // Disposing all controllers in one place
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
      showCustomSnackbar('Error', 'Please enter a valid phone number');
      return;
    }
    isLoading(true);
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.value,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          await _signInWithCredential(credential);
          isLoading(false);
        },
        verificationFailed: (e) {
          showCustomSnackbar('Error', 'Verification failed: ${e.message}');
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
      showCustomSnackbar('Error', 'Failed to verify phone number: $e');
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
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      showCustomSnackbar('Error', 'Invalid OTP: ${e.message}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _signInWithCredential(AuthCredential credential) async {
    final userCredential = await auth.signInWithCredential(credential);
    await handleSuccessfulAuth(userCredential.user!.uid);
  }

  Future<void> handleSuccessfulAuth(String userId) async {
    StorageService.instance.save(AppConstants.userId, userId);
    showCustomSnackbar('Success', 'Authentication successful');
    await checkExistingRoutines(userId);
  }

  Future<void> checkExistingRoutines(String userId) async {
    try {
      if (userId.isEmpty) {
        Get.offAllNamed(AppRoutes.layoutRoute);
        return;
      }

      await routineController.fetchRoutines();
    } catch (e) {
      showCustomSnackbar('Error', "Message: $e");
    } finally {
      Get.offAllNamed(AppRoutes.layoutRoute);
    }
  }
}
