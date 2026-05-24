import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static const String _supabaseUrl = 'https://qicbibqtsfhtkcvtiwfv.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpY2JpYnF0c2ZodGtjdnRpd2Z2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2MDM3OTcsImV4cCI6MjA5NTE3OTc5N30.xz5M4mpt6VCldurRuJuYrNuairMrzwfUkTMhiDQhenw';

  static Future<void> init() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  /// Get current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get current session
  static Session? get currentSession => client.auth.currentSession;

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
