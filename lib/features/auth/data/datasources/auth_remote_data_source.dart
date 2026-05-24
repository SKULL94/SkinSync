import 'package:skin_sync/core/error/exceptions.dart' as app_exceptions;
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
      // Supabase handles both real SMS and test numbers
      // Test numbers configured in Dashboard won't receive SMS
      await supabaseClient.auth.signInWithOtp(phone: phoneNumber);
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
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Supabase validates OTP (works for both test and real numbers)
      final response = await supabaseClient.auth.verifyOTP(
        phone: verificationId,
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
      rethrow;
    } on AuthException catch (e) {
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
