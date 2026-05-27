import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  final String userName;
  final String? avatarUrl;
  final String? skinType;
  final int totalScans;
  final int currentStreak;
  final int bestScore;
  final DateTime? lastScanDate;
  final int? lastScanScore;
  final ScanMetricsEntity? lastScanMetrics;
  final int? scoreTrend;
  final WeatherEntity? weather;
  final String? weeklyInsight;
  final List<DailyTipEntity> dailyTips;
  final String heroTitle;
  final String heroSubtitle;

  const DashboardEntity({
    required this.userName,
    this.avatarUrl,
    this.skinType,
    this.totalScans = 0,
    this.currentStreak = 0,
    this.bestScore = 0,
    this.lastScanDate,
    this.lastScanScore,
    this.lastScanMetrics,
    this.scoreTrend,
    this.weather,
    this.weeklyInsight,
    this.dailyTips = const [],
    required this.heroTitle,
    required this.heroSubtitle,
  });

  int get daysSinceLastScan {
    if (lastScanDate == null) return -1;
    return DateTime.now().difference(lastScanDate!).inDays;
  }

  bool get needsScan => daysSinceLastScan < 0 || daysSinceLastScan >= 7;

  String get trendDirection {
    if (scoreTrend == null) return 'stable';
    if (scoreTrend! > 0) return 'up';
    if (scoreTrend! < 0) return 'down';
    return 'stable';
  }

  @override
  List<Object?> get props => [
        userName,
        avatarUrl,
        skinType,
        totalScans,
        currentStreak,
        bestScore,
        lastScanDate,
        lastScanScore,
        lastScanMetrics,
        scoreTrend,
        weather,
        weeklyInsight,
        dailyTips,
        heroTitle,
        heroSubtitle,
      ];
}

class ScanMetricsEntity extends Equatable {
  final int hydration;
  final int texture;
  final int clarity;
  final int oiliness;

  const ScanMetricsEntity({
    required this.hydration,
    required this.texture,
    required this.clarity,
    required this.oiliness,
  });

  @override
  List<Object?> get props => [hydration, texture, clarity, oiliness];
}

class WeatherEntity extends Equatable {
  final double temperature;
  final int humidity;
  final int uvIndex;
  final String condition;
  final String city;

  const WeatherEntity({
    required this.temperature,
    required this.humidity,
    required this.uvIndex,
    required this.condition,
    required this.city,
  });

  bool get isHighUV => uvIndex >= 6;
  bool get isLowHumidity => humidity < 40;
  bool get isHighHumidity => humidity > 70;
  bool get isHot => temperature > 30;
  bool get isCold => temperature < 15;

  @override
  List<Object?> get props => [temperature, humidity, uvIndex, condition, city];
}

class DailyTipEntity extends Equatable {
  final String id;
  final String icon;
  final String title;
  final String description;
  final String category;
  final TipSource source;

  const DailyTipEntity({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.category,
    required this.source,
  });

  @override
  List<Object?> get props => [id, icon, title, description, category, source];
}

enum TipSource { ruleBased, weather, ai, timeBased }
