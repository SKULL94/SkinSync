part of 'personal_details_bloc.dart';

enum PersonalDetailsStatus { initial, loading, loaded, saving, success, failure }

final class PersonalDetailsState extends Equatable {
  final PersonalDetailsStatus status;
  final String firstName;
  final String lastName;
  final String email;
  final String location;
  final String allergies;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? fitzpatrickScale;
  final String? phone;
  final String? avatarUrl;
  final String? localAvatarPath;
  final bool isUploadingImage;
  final String? errorMessage;

  const PersonalDetailsState({
    this.status = PersonalDetailsStatus.initial,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.location = '',
    this.allergies = '',
    this.gender,
    this.dateOfBirth,
    this.fitzpatrickScale,
    this.phone,
    this.avatarUrl,
    this.localAvatarPath,
    this.isUploadingImage = false,
    this.errorMessage,
  });

  String get formattedGender {
    if (gender == null || gender!.isEmpty) return 'Not set';
    return gender![0].toUpperCase() + gender!.substring(1);
  }

  String get formattedPhone {
    if (phone == null || phone!.isEmpty) return 'Not set';
    if (phone!.length > 10) {
      final country = phone!.substring(0, phone!.length - 10);
      final number = phone!.substring(phone!.length - 10);
      return '$country ${number.substring(0, 5)} ${number.substring(5)}';
    }
    return phone!;
  }

  String get avatarInitial =>
      firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

  PersonalDetailsState copyWith({
    PersonalDetailsStatus? status,
    String? firstName,
    String? lastName,
    String? email,
    String? location,
    String? allergies,
    String? gender,
    DateTime? dateOfBirth,
    String? fitzpatrickScale,
    String? phone,
    String? avatarUrl,
    String? localAvatarPath,
    bool? isUploadingImage,
    String? errorMessage,
  }) {
    return PersonalDetailsState(
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      location: location ?? this.location,
      allergies: allergies ?? this.allergies,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      fitzpatrickScale: fitzpatrickScale ?? this.fitzpatrickScale,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        firstName,
        lastName,
        email,
        location,
        allergies,
        gender,
        dateOfBirth,
        fitzpatrickScale,
        phone,
        avatarUrl,
        localAvatarPath,
        isUploadingImage,
        errorMessage,
      ];
}
