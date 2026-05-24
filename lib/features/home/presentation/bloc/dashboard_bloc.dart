import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/features/home/domain/repositories/dashboard_repository.dart';
import 'package:skin_sync/features/home/presentation/bloc/dashboard_event.dart';
import 'package:skin_sync/features/home/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(const DashboardState()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<LoadWeather>(_onLoadWeather);
    on<LoadAIInsight>(_onLoadAIInsight);
    on<DismissTip>(_onDismissTip);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));

    final result = await repository.getDashboardData();

    result.fold(
      (failure) => emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: failure.message,
      )),
      (dashboard) => emit(state.copyWith(
        status: DashboardStatus.loaded,
        dashboard: dashboard,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await repository.getDashboardData();

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (dashboard) => emit(state.copyWith(
        dashboard: dashboard,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onLoadWeather(
    LoadWeather event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(weatherStatus: WeatherStatus.loading));

    final result = await repository.getWeather(
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        weatherStatus: WeatherStatus.error,
      )),
      (weather) => emit(state.copyWith(
        weatherStatus: WeatherStatus.loaded,
        weather: weather,
      )),
    );
  }

  Future<void> _onLoadAIInsight(
    LoadAIInsight event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(insightStatus: InsightStatus.loading));

    final result = await repository.getAIInsight();

    result.fold(
      (failure) => emit(state.copyWith(
        insightStatus: InsightStatus.error,
      )),
      (insight) => emit(state.copyWith(
        insightStatus: InsightStatus.loaded,
        aiInsight: insight,
      )),
    );
  }

  void _onDismissTip(
    DismissTip event,
    Emitter<DashboardState> emit,
  ) {
    final updatedDismissedIds = [...state.dismissedTipIds, event.tipId];
    emit(state.copyWith(dismissedTipIds: updatedDismissedIds));
  }
}
