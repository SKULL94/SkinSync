part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

final class ProfileSkinTypeChanged extends ProfileEvent {
  final String skinType;

  const ProfileSkinTypeChanged(this.skinType);

  @override
  List<Object?> get props => [skinType];
}

final class ProfileConcernsChanged extends ProfileEvent {
  final List<String> concerns;

  const ProfileConcernsChanged(this.concerns);

  @override
  List<Object?> get props => [concerns];
}

final class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested();
}
