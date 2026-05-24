import 'package:skin_sync/core/error/exceptions.dart' as app_exceptions;
import 'package:skin_sync/core/services/supabase_services.dart';
import 'package:skin_sync/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp(String phoneNumber);
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  });
  Future<void> signOut();
  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<String> sendOtp(String phoneNumber) async {
    try {
      // Check if this is a test number (no SMS will be sent)
      if (SupabaseService.isTestNumber(phoneNumber)) {
        // For test numbers, we simulate OTP sent
        // Return phone number as "verification ID" for test flow
        return phoneNumber;
      }

      // For real numbers, send OTP via Supabase (requires SMS provider setup)
      await supabaseClient.auth.signInWithOtp(
        phone: phoneNumber,
      );

      // Supabase doesn't return a verification ID like Firebase
      // We use the phone number as the identifier for the verification step
      return phoneNumber;
    } on AuthException catch (e) {
      throw app_exceptions.AuthException(
        message: e.message,
        code: e.statusCode,
      );
    } catch (e) {
      throw app_exceptions.AuthException(message: 'Failed to send OTP: $e');
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId, // This is the phone number
    required String smsCode,
  }) async {
    try {
      final phoneNumber = verificationId;

      // Check if this is a test number with matching OTP
      if (SupabaseService.isTestNumber(phoneNumber)) {
        final expectedOtp = SupabaseService.getTestOtp(phoneNumber);
        if (smsCode != expectedOtp) {
          throw const app_exceptions.AuthException(
            message: 'Invalid OTP. Please try again.',
            code: 'invalid-otp',
          );
        }

        // For test numbers, create a mock session
        // In production, you might want to create a real user in Supabase
        // For now, we'll use a deterministic UID based on phone number
        final testUid = 'test_${phoneNumber.replaceAll('+', '')}';
        return UserModel(
          uid: testUid,
          phoneNumber: phoneNumber,
          email: null,
        );
      }

      // For real numbers, verify with Supabase
      final response = await supabaseClient.auth.verifyOTP(
        phone: phoneNumber,
        token: smsCode,
        type: OtpType.sms,
      );

      if (response.user == null) {
        throw const app_exceptions.AuthException(
          message: 'Verification failed. Please try again.',
          code: 'verification-failed',
        );
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on app_exceptions.AuthException {
      // Re-throw our custom AuthException
      rethrow;
    } on AuthException catch (e) {
      // Supabase AuthException
      throw app_exceptions.AuthException(
        message: e.message,
        code: e.statusCode,
      );
    } catch (e) {
      throw app_exceptions.AuthException(message: 'OTP verification failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw app_exceptions.AuthException(message: 'Sign out failed: $e');
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }
}
