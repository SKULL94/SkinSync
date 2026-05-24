import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

class LoadWeather extends DashboardEvent {
  final double latitude;
  final double longitude;

  const LoadWeather({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class LoadAIInsight extends DashboardEvent {
  const LoadAIInsight();
}

class DismissTip extends DashboardEvent {
  final String tipId;

  const DismissTip({required this.tipId});

  @override
  List<Object?> get props => [tipId];
}
