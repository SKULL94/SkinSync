import 'package:skin_sync/core/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final SupabaseClient _supabaseClient;

  UserRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Get current user's profile from Supabase
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) return null;

      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('auth_id', authUser.id)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromMap(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Create a new user profile
  Future<UserProfile?> createProfile({
    required String firstName,
    String? lastName,
    String? gender,
    String? phone,
  }) async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) throw Exception('User not authenticated');

      final profile = UserProfile(
        authId: authUser.id,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        phone: phone ?? authUser.phone,
      );

      final response = await _supabaseClient
          .from('users')
          .insert(profile.toMap())
          .select()
          .single();

      return UserProfile.fromMap(response);
    } catch (e) {
      print('Error creating user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<UserProfile?> updateProfile(UserProfile profile) async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) throw Exception('User not authenticated');

      final response = await _supabaseClient
          .from('users')
          .update(profile.toMap())
          .eq('auth_id', authUser.id)
          .select()
          .single();

      return UserProfile.fromMap(response);
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  /// Create or update profile (upsert)
  Future<UserProfile?> upsertProfile({
    required String firstName,
    String? lastName,
    String? gender,
    String? phone,
    DateTime? dateOfBirth,
    String? email,
    String? location,
    String? skinType,
    String? fitzpatrickScale,
    String? knownAllergies,
  }) async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) throw Exception('User not authenticated');

      final data = {
        'auth_id': authUser.id,
        'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (gender != null) 'gender': gender,
        'phone': phone ?? authUser.phone,
        if (dateOfBirth != null)
          'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
        if (email != null) 'email': email,
        if (location != null) 'location': location,
        if (skinType != null) 'skin_type': skinType,
        if (fitzpatrickScale != null) 'fitzpatrick_scale': fitzpatrickScale,
        if (knownAllergies != null) 'known_allergies': knownAllergies,
      };

      final response = await _supabaseClient
          .from('users')
          .upsert(data, onConflict: 'auth_id')
          .select()
          .single();

      return UserProfile.fromMap(response);
    } catch (e) {
      print('Error upserting user profile: $e');
      return null;
    }
  }

  /// Update specific fields
  Future<UserProfile?> updateFields(Map<String, dynamic> fields) async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) throw Exception('User not authenticated');

      final response = await _supabaseClient
          .from('users')
          .update(fields)
          .eq('auth_id', authUser.id)
          .select()
          .single();

      return UserProfile.fromMap(response);
    } catch (e) {
      print('Error updating user fields: $e');
      return null;
    }
  }

  /// Check if profile exists
  Future<bool> profileExists() async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) return false;

      final response = await _supabaseClient
          .from('users')
          .select('id')
          .eq('auth_id', authUser.id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Delete user profile
  Future<bool> deleteProfile() async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) return false;

      await _supabaseClient
          .from('users')
          .delete()
          .eq('auth_id', authUser.id);

      return true;
    } catch (e) {
      print('Error deleting user profile: $e');
      return false;
    }
  }
}
