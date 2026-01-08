part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, loaded, deleted, deletedAll, failure }

final class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<HistoryEntity> histories;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.histories = const [],
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryEntity>? histories,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      histories: histories ?? this.histories,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, histories, errorMessage];
}
