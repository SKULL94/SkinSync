import 'package:equatable/equatable.dart';
import 'package:skin_sync/features/home/domain/entities/dashboard_entity.dart';

enum DashboardStatus { initial, loading, loaded, error }

enum WeatherStatus { initial, loading, loaded, error }

enum InsightStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final WeatherStatus weatherStatus;
  final InsightStatus insightStatus;
  final DashboardEntity? dashboard;
  final WeatherEntity? weather;
  final String? aiInsight;
  final String? errorMessage;
  final List<String> dismissedTipIds;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.weatherStatus = WeatherStatus.initial,
    this.insightStatus = InsightStatus.initial,
    this.dashboard,
    this.weather,
    this.aiInsight,
    this.errorMessage,
    this.dismissedTipIds = const [],
  });

  List<DailyTipEntity> get visibleTips {
    if (dashboard == null) return [];
    return dashboard!.dailyTips
        .where((tip) => !dismissedTipIds.contains(tip.id))
        .toList();
  }

  bool get isLoading => status == DashboardStatus.loading;
  bool get hasError => status == DashboardStatus.error;
  bool get isLoaded => status == DashboardStatus.loaded;

  DashboardState copyWith({
    DashboardStatus? status,
    WeatherStatus? weatherStatus,
    InsightStatus? insightStatus,
    DashboardEntity? dashboard,
    WeatherEntity? weather,
    String? aiInsight,
    String? errorMessage,
    List<String>? dismissedTipIds,
  }) {
    return DashboardState(
      status: status ?? this.status,
      weatherStatus: weatherStatus ?? this.weatherStatus,
      insightStatus: insightStatus ?? this.insightStatus,
      dashboard: dashboard ?? this.dashboard,
      weather: weather ?? this.weather,
      aiInsight: aiInsight ?? this.aiInsight,
      errorMessage: errorMessage ?? this.errorMessage,
      dismissedTipIds: dismissedTipIds ?? this.dismissedTipIds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        weatherStatus,
        insightStatus,
        dashboard,
        weather,
        aiInsight,
        errorMessage,
        dismissedTipIds,
      ];
}
