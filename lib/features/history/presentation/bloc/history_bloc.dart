import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/domain/usecases/delete_all_histories.dart';
import 'package:skin_sync/features/history/domain/usecases/delete_history.dart';
import 'package:skin_sync/features/history/domain/usecases/get_histories.dart';
import 'package:skin_sync/features/history/domain/usecases/sync_histories.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistories getHistories;
  final DeleteHistory deleteHistory;
  final DeleteAllHistories deleteAllHistories;
  final SyncHistories syncHistories;
  final StorageService storageService;

  HistoryBloc({
    required this.getHistories,
    required this.deleteHistory,
    required this.deleteAllHistories,
    required this.syncHistories,
    required this.storageService,
  }) : super(const HistoryState()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryDeleteRequested>(_onDeleteRequested);
    on<HistoryDeleteAllRequested>(_onDeleteAllRequested);
    on<HistorySyncRequested>(_onSyncRequested);
  }

  String? get _userId => storageService.fetch<String>(AppConstants.userId);

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (_userId == null) return;

    emit(state.copyWith(status: HistoryStatus.loading));

    final result = await getHistories(GetHistoriesParams(userId: _userId!));

    result.fold(
      (failure) => emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: failure.message,
      )),
      (histories) => emit(state.copyWith(
        status: HistoryStatus.loaded,
        histories: histories,
      )),
    );

    add(const HistorySyncRequested());
  }

  Future<void> _onDeleteRequested(
    HistoryDeleteRequested event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await deleteHistory(DeleteHistoryParams(id: event.id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedHistories =
            state.histories.where((h) => h.id != event.id).toList();
        emit(state.copyWith(
          status: HistoryStatus.deleted,
          histories: updatedHistories,
        ));
      },
    );
  }

  Future<void> _onDeleteAllRequested(
    HistoryDeleteAllRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (_userId == null) return;

    final result = await deleteAllHistories(
      DeleteAllHistoriesParams(userId: _userId!),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: HistoryStatus.deletedAll,
        histories: const [],
      )),
    );
  }

  Future<void> _onSyncRequested(
    HistorySyncRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (_userId == null) return;

    await syncHistories(SyncHistoriesParams(userId: _userId!));

    final result = await getHistories(GetHistoriesParams(userId: _userId!));

    result.fold(
      (failure) {},
      (histories) => emit(state.copyWith(histories: histories)),
    );
  }
}
