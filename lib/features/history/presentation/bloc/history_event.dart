part of 'history_bloc.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

final class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}

final class HistoryDeleteRequested extends HistoryEvent {
  final String id;

  const HistoryDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

final class HistoryDeleteAllRequested extends HistoryEvent {
  const HistoryDeleteAllRequested();
}

final class HistorySyncRequested extends HistoryEvent {
  const HistorySyncRequested();
}

/// Optimistically adds a new history entry to the list without waiting for remote sync
final class HistoryAddOptimistic extends HistoryEvent {
  final HistoryEntity history;

  const HistoryAddOptimistic(this.history);

  @override
  List<Object?> get props => [history];
}
