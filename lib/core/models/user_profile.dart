import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String? id;
  final String authId;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? email;
  final String? location;
  final String? avatarUrl;
  final String? skinType;
  final String? fitzpatrickScale;
  final String? knownAllergies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.id,
    required this.authId,
    this.phone,
    this.firstName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.email,
    this.location,
    this.avatarUrl,
    this.skinType,
    this.fitzpatrickScale,
    this.knownAllergies,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from Supabase row
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String?,
      authId: map['auth_id'] as String,
      phone: map['phone'] as String?,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      gender: map['gender'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'] as String)
          : null,
      email: map['email'] as String?,
      location: map['location'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      skinType: map['skin_type'] as String?,
      fitzpatrickScale: map['fitzpatrick_scale'] as String?,
      knownAllergies: map['known_allergies'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Convert to Supabase row (for insert/update)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'auth_id': authId,
      if (phone != null) 'phone': phone,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
      if (email != null) 'email': email,
      if (location != null) 'location': location,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (skinType != null) 'skin_type': skinType,
      if (fitzpatrickScale != null) 'fitzpatrick_scale': fitzpatrickScale,
      if (knownAllergies != null) 'known_allergies': knownAllergies,
    };
  }

  /// Get full name
  String get fullName {
    final parts = [firstName, lastName].where((s) => s != null && s.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : '';
  }

  /// Get display name (first name or 'User')
  String get displayName => firstName?.isNotEmpty == true ? firstName! : 'User';

  /// Get avatar initial
  String get avatarInitial =>
      firstName?.isNotEmpty == true ? firstName![0].toUpperCase() : '?';

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? authId,
    String? phone,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? email,
    String? location,
    String? avatarUrl,
    String? skinType,
    String? fitzpatrickScale,
    String? knownAllergies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      skinType: skinType ?? this.skinType,
      fitzpatrickScale: fitzpatrickScale ?? this.fitzpatrickScale,
      knownAllergies: knownAllergies ?? this.knownAllergies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authId,
        phone,
        firstName,
        lastName,
        gender,
        dateOfBirth,
        email,
        location,
        avatarUrl,
        skinType,
        fitzpatrickScale,
        knownAllergies,
        createdAt,
        updatedAt,
      ];
}
