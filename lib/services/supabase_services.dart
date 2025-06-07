import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://rpzttytepebvihryrjqx.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwenR0eXRlcGVidmlocnlyanF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5Nzc4OTcsImV4cCI6MjA2MDU1Mzg5N30.SyGcEyunS-PkbsBWy2KUyeKjbOBJPAAr9KB-i4h7D88',
    );
  }
}
