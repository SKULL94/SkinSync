part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, updating, failure }

final class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  // Computed properties for easy access
  String get userName => profile?.fullName ?? profile?.firstName ?? 'User';
  String get avatarInitial => userName.isNotEmpty ? userName[0].toUpperCase() : '?';
  DateTime? get memberSince => profile?.createdAt;
  String? get skinType => profile?.skinType;
  List<String> get concerns => profile?.concerns ?? [];

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
