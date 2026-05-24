import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/models/user_profile.dart';
import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/features/home/data/models/dashboard_model.dart';
import 'package:skin_sync/features/home/domain/entities/dashboard_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboardData();
  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  });
  Future<String> getAIInsight({required UserProfile profile});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final SupabaseClient supabaseClient;
  final UserRepository userRepository;

  // API Keys - move to env in production
  static const String weatherApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  static const String aiApiKey = 'YOUR_OPENAI_API_KEY';

  DashboardRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.userRepository,
  });

  @override
  Future<DashboardModel> getDashboardData() async {
    try {
      final profile = await userRepository.getCurrentUserProfile();
      final scanStats = await _fetchScanStatistics();
      final heroMessage = _generateHeroMessage(scanStats);
      final tips = _generateTips(profile?.skinType, null);

      return DashboardModel(
        userName: profile?.firstName ?? StringConst.kDefaultUserName,
        skinType: profile?.skinType,
        totalScans: scanStats['totalScans'] ?? 0,
        currentStreak: scanStats['streak'] ?? 0,
        bestScore: scanStats['bestScore'] ?? 0,
        lastScanDate: scanStats['lastScanDate'],
        lastScanScore: scanStats['lastScore'],
        lastScanMetrics: scanStats['lastMetrics'],
        scoreTrend: scanStats['trend'],
        dailyTips: tips,
        heroTitle: heroMessage['title']!,
        heroSubtitle: heroMessage['subtitle']!,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch dashboard data: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchScanStatistics() async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) return {};

      // TODO: Query actual scan_history table when implemented
      // For now return empty stats
      return {
        'totalScans': 0,
        'streak': 0,
        'bestScore': 0,
        'lastScanDate': null,
        'lastScore': null,
        'lastMetrics': null,
        'trend': null,
      };
    } catch (e) {
      return {};
    }
  }

  Map<String, String> _generateHeroMessage(Map<String, dynamic> scanStats) {
    final totalScans = scanStats['totalScans'] as int? ?? 0;
    final lastScanDate = scanStats['lastScanDate'] as DateTime?;
    final lastScore = scanStats['lastScore'] as int?;

    if (totalScans == 0) {
      return {
        'title': StringConst.kStartJourneyTitle,
        'subtitle': StringConst.kStartJourneySubtitle,
      };
    }

    final daysSince = lastScanDate != null
        ? DateTime.now().difference(lastScanDate).inDays
        : -1;

    if (daysSince >= 0 && daysSince <= 3 && lastScore != null && lastScore >= 70) {
      return {
        'title': StringConst.kGlowingTitle,
        'subtitle': StringConst.kGlowingSubtitle,
      };
    }

    if (daysSince >= 0 && daysSince <= 3 && lastScore != null && lastScore < 70) {
      return {
        'title': StringConst.kImproveTitle,
        'subtitle': StringConst.kImproveSubtitle,
      };
    }

    if (daysSince >= 7) {
      return {
        'title': StringConst.kCheckInTitle,
        'subtitle': "It's been $daysSince days since your last scan",
      };
    }

    return {
      'title': StringConst.kTrackProgressTitle,
      'subtitle': StringConst.kTrackProgressSubtitle,
    };
  }

  List<DailyTipModel> _generateTips(String? skinType, WeatherEntity? weather) {
    final tips = <DailyTipModel>[];
    final hour = DateTime.now().hour;

    // Time-based tips
    if (hour >= 6 && hour < 11) {
      tips.add(DailyTipModel(
        id: 'morning_spf',
        icon: '☀️',
        title: StringConst.kMorningSPFTitle,
        description: StringConst.kMorningSPFDesc,
        category: 'protection',
        source: TipSource.timeBased,
      ));
    }

    if (hour >= 19 && hour < 23) {
      tips.add(DailyTipModel(
        id: 'evening_cleanse',
        icon: '🌙',
        title: StringConst.kEveningCleanseTitle,
        description: StringConst.kEveningCleanseDesc,
        category: 'routine',
        source: TipSource.timeBased,
      ));
    }

    // Skin type based tips
    if (skinType == 'oily') {
      tips.add(DailyTipModel(
        id: 'oily_tip',
        icon: '💧',
        title: StringConst.kOilyTipTitle,
        description: StringConst.kOilyTipDesc,
        category: 'skincare',
        source: TipSource.ruleBased,
      ));
    } else if (skinType == 'dry') {
      tips.add(DailyTipModel(
        id: 'dry_tip',
        icon: '🧴',
        title: StringConst.kDryTipTitle,
        description: StringConst.kDryTipDesc,
        category: 'hydration',
        source: TipSource.ruleBased,
      ));
    } else if (skinType == 'combo') {
      tips.add(DailyTipModel(
        id: 'combo_tip',
        icon: '⚖️',
        title: StringConst.kComboTipTitle,
        description: StringConst.kComboTipDesc,
        category: 'skincare',
        source: TipSource.ruleBased,
      ));
    }

    // Weather based tips
    if (weather != null) {
      if (weather.isHighUV) {
        tips.add(DailyTipModel(
          id: 'high_uv',
          icon: '🔆',
          title: StringConst.kHighUVTitle,
          description: StringConst.kHighUVDesc,
          category: 'protection',
          source: TipSource.weather,
        ));
      }

      if (weather.isLowHumidity) {
        tips.add(DailyTipModel(
          id: 'low_humidity',
          icon: '💨',
          title: StringConst.kLowHumidityTitle,
          description: StringConst.kLowHumidityDesc,
          category: 'hydration',
          source: TipSource.weather,
        ));
      }
    }

    // General tips as fallback
    if (tips.length < 3) {
      tips.addAll([
        DailyTipModel(
          id: 'hydration',
          icon: '💧',
          title: StringConst.kStayHydratedTitle,
          description: StringConst.kStayHydratedDesc,
          category: 'hydration',
          source: TipSource.ruleBased,
        ),
        DailyTipModel(
          id: 'sleep',
          icon: '😴',
          title: StringConst.kBeautySleepTitle,
          description: StringConst.kBeautySleepDesc,
          category: 'routine',
          source: TipSource.ruleBased,
        ),
      ]);
    }

    return tips.take(4).toList();
  }

  @override
  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    if (weatherApiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
      throw const ServerException(message: 'Weather API key not configured');
    }

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=metric',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      }
      throw ServerException(
        message: 'Weather API error',
        code: response.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch weather: $e');
    }
  }

  @override
  Future<String> getAIInsight({required UserProfile profile}) async {
    if (aiApiKey == 'YOUR_OPENAI_API_KEY') {
      return _getFallbackInsight();
    }

    try {
      final prompt = '''
You are a friendly skincare advisor. Provide a brief, encouraging weekly insight (2-3 sentences max).
User's skin type: ${profile.skinType ?? 'Unknown'}
Be specific, actionable, and positive.
''';

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $aiApiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 100,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'] as String;
      }
      return _getFallbackInsight();
    } catch (e) {
      return _getFallbackInsight();
    }
  }

  String _getFallbackInsight() {
    return StringConst.kFallbackInsight;
  }
}
