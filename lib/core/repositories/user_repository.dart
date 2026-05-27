import 'dart:io';

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
    List<String>? concerns,
    String? avatarUrl,
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
        if (concerns != null) 'concerns': concerns,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
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

  /// Upload avatar image to Supabase storage
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) throw Exception('User not authenticated');

      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final fileName = '${authUser.id}/avatar.$fileExt';

      // Upload to 'avatars' bucket
      await _supabaseClient.storage.from('avatars').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final publicUrl =
          _supabaseClient.storage.from('avatars').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
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

      await _supabaseClient.from('users').delete().eq('auth_id', authUser.id);

      return true;
    } catch (e) {
      print('Error deleting user profile: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // USER DETAILS TABLE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get user details from user_details table
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) return null;

      final response = await _supabaseClient
          .from('user_details')
          .select()
          .eq('auth_id', authUser.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  /// Save or update user details to user_details table
  Future<Map<String, dynamic>?> upsertUserDetails({
    required String firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? email,
    String? location,
    String? avatarUrl,
  }) async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) throw Exception('User not authenticated');

      final data = {
        'auth_id': authUser.id,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
        'email': email,
        'location': location,
        'avatar_url': avatarUrl,
        'phone': authUser.phone,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove null values
      data.removeWhere((key, value) => value == null);

      final response = await _supabaseClient
          .from('user_details')
          .upsert(data, onConflict: 'auth_id')
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error upserting user details: $e');
      return null;
    }
  }

  /// Update avatar URL in user_details table
  Future<bool> updateUserDetailsAvatar(String avatarUrl) async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) return false;

      await _supabaseClient
          .from('user_details')
          .update({
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_id', authUser.id);

      return true;
    } catch (e) {
      print('Error updating avatar in user_details: $e');
      return false;
    }
  }
}
