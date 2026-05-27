part of 'skin_type_bloc.dart';

enum SkinTypeStatus { initial, loading, loaded, saving, success, failure }

final class SkinTypeState extends Equatable {
  final SkinTypeStatus status;
  final String? selectedType;
  final int selectedFitzpatrick;
  final String? errorMessage;

  const SkinTypeState({
    this.status = SkinTypeStatus.initial,
    this.selectedType,
    this.selectedFitzpatrick = 2,
    this.errorMessage,
  });

  SkinTypeState copyWith({
    SkinTypeStatus? status,
    String? selectedType,
    int? selectedFitzpatrick,
    String? errorMessage,
  }) {
    return SkinTypeState(
      status: status ?? this.status,
      selectedType: selectedType ?? this.selectedType,
      selectedFitzpatrick: selectedFitzpatrick ?? this.selectedFitzpatrick,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedType,
        selectedFitzpatrick,
        errorMessage,
      ];
}
