import 'package:skin_sync/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.phoneNumber,
    super.email,
  });

  /// Create UserModel from Supabase User
  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      uid: user.id,
      phoneNumber: user.phone,
      email: user.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
    );
  }
}
