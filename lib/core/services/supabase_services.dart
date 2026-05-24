import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Supabase project configuration
  static const String _supabaseUrl = 'https://rpzttytepebvihryrjqx.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwenR0eXRlcGVidmlocnlyanF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5Nzc4OTcsImV4cCI6MjA2MDU1Mzg5N30.SyGcEyunS-PkbsBWy2KUyeKjbOBJPAAr9KB-i4h7D88';

  // ══════════════════════════════════════════════════════════════════════════
  // TEST OTP CONFIGURATION (For Development/Testing)
  // ══════════════════════════════════════════════════════════════════════════
  // These phone numbers will bypass real SMS and use fixed OTPs.
  // Remove or disable in production!
  // ══════════════════════════════════════════════════════════════════════════

  static const bool isTestMode = true; // Set to false in production

  static const Map<String, String> testOtpNumbers = {
    '+919999999999': '123456', // Primary test number
    '+918888888888': '654321', // Secondary test number
    '+917777777777': '111111', // QA testing
    '+916666666666': '000000', // App Store review
  };

  /// Check if a phone number is a test number
  static bool isTestNumber(String phoneNumber) {
    if (!isTestMode) return false;
    return testOtpNumbers.containsKey(phoneNumber);
  }

  /// Get test OTP for a phone number (returns null if not a test number)
  static String? getTestOtp(String phoneNumber) {
    if (!isTestMode) return null;
    return testOtpNumbers[phoneNumber];
  }

  static Future<void> init() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get current session
  static Session? get currentSession => client.auth.currentSession;

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
