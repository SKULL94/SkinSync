import 'package:skin_sync/features/home/domain/entities/dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.userName,
    super.avatarUrl,
    super.skinType,
    super.totalScans,
    super.currentStreak,
    super.bestScore,
    super.lastScanDate,
    super.lastScanScore,
    super.lastScanMetrics,
    super.scoreTrend,
    super.weather,
    super.weeklyInsight,
    super.dailyTips,
    required super.heroTitle,
    required super.heroSubtitle,
  });
}

class ScanMetricsModel extends ScanMetricsEntity {
  const ScanMetricsModel({
    required super.hydration,
    required super.texture,
    required super.clarity,
    required super.oiliness,
  });

  factory ScanMetricsModel.fromMap(Map<String, dynamic> map) {
    return ScanMetricsModel(
      hydration: map['hydration'] as int? ?? 0,
      texture: map['texture'] as int? ?? 0,
      clarity: map['clarity'] as int? ?? 0,
      oiliness: map['oiliness'] as int? ?? 0,
    );
  }
}

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.temperature,
    required super.humidity,
    required super.uvIndex,
    required super.condition,
    required super.city,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      uvIndex: json['uv_index'] as int? ?? 0,
      condition: json['weather'][0]['main'] as String,
      city: json['name'] as String,
    );
  }
}

class DailyTipModel extends DailyTipEntity {
  const DailyTipModel({
    required super.id,
    required super.icon,
    required super.title,
    required super.description,
    required super.category,
    required super.source,
  });
}
