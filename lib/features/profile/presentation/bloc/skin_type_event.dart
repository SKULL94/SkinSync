part of 'skin_type_bloc.dart';

sealed class SkinTypeEvent extends Equatable {
  const SkinTypeEvent();

  @override
  List<Object?> get props => [];
}

final class SkinTypeLoadRequested extends SkinTypeEvent {
  const SkinTypeLoadRequested();
}

final class SkinTypeSelected extends SkinTypeEvent {
  final String skinType;
  const SkinTypeSelected(this.skinType);

  @override
  List<Object?> get props => [skinType];
}

final class SkinTypeFitzpatrickChanged extends SkinTypeEvent {
  final int fitzpatrickIndex;
  const SkinTypeFitzpatrickChanged(this.fitzpatrickIndex);

  @override
  List<Object?> get props => [fitzpatrickIndex];
}

final class SkinTypeSaveRequested extends SkinTypeEvent {
  const SkinTypeSaveRequested();
}
