part of 'personal_details_bloc.dart';

sealed class PersonalDetailsEvent extends Equatable {
  const PersonalDetailsEvent();

  @override
  List<Object?> get props => [];
}

final class PersonalDetailsLoadRequested extends PersonalDetailsEvent {
  const PersonalDetailsLoadRequested();
}

final class PersonalDetailsFirstNameChanged extends PersonalDetailsEvent {
  final String firstName;
  const PersonalDetailsFirstNameChanged(this.firstName);

  @override
  List<Object?> get props => [firstName];
}

final class PersonalDetailsLastNameChanged extends PersonalDetailsEvent {
  final String lastName;
  const PersonalDetailsLastNameChanged(this.lastName);

  @override
  List<Object?> get props => [lastName];
}

final class PersonalDetailsEmailChanged extends PersonalDetailsEvent {
  final String email;
  const PersonalDetailsEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

final class PersonalDetailsLocationChanged extends PersonalDetailsEvent {
  final String location;
  const PersonalDetailsLocationChanged(this.location);

  @override
  List<Object?> get props => [location];
}

final class PersonalDetailsAllergiesChanged extends PersonalDetailsEvent {
  final String allergies;
  const PersonalDetailsAllergiesChanged(this.allergies);

  @override
  List<Object?> get props => [allergies];
}

final class PersonalDetailsGenderChanged extends PersonalDetailsEvent {
  final String gender;
  const PersonalDetailsGenderChanged(this.gender);

  @override
  List<Object?> get props => [gender];
}

final class PersonalDetailsDateOfBirthChanged extends PersonalDetailsEvent {
  final DateTime dateOfBirth;
  const PersonalDetailsDateOfBirthChanged(this.dateOfBirth);

  @override
  List<Object?> get props => [dateOfBirth];
}

final class PersonalDetailsFitzpatrickChanged extends PersonalDetailsEvent {
  final String fitzpatrickScale;
  const PersonalDetailsFitzpatrickChanged(this.fitzpatrickScale);

  @override
  List<Object?> get props => [fitzpatrickScale];
}

final class PersonalDetailsSaveRequested extends PersonalDetailsEvent {
  const PersonalDetailsSaveRequested();
}

final class PersonalDetailsImagePickRequested extends PersonalDetailsEvent {
  final bool fromCamera;
  const PersonalDetailsImagePickRequested({this.fromCamera = false});

  @override
  List<Object?> get props => [fromCamera];
}
