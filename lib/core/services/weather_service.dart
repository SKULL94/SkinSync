import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skin_sync/core/config/api_config.dart';

class WeatherData {
  final double temperature;
  final int humidity;
  final String description;
  final String icon;
  final String main;
  final double uvIndex;
  final String cityName;

  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.main,
    required this.uvIndex,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0] as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;

    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      humidity: main['humidity'] as int,
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      main: weather['main'] as String,
      uvIndex: 0, // UV index requires separate API call
      cityName: json['name'] as String,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Get skin-related advice based on weather
  List<String> get skinTips {
    final tips = <String>[];

    // Temperature-based tips
    if (temperature > 30) {
      tips.add('High heat alert! Use lightweight, oil-free products to prevent clogged pores.');
      tips.add('Carry blotting papers to manage excess oil throughout the day.');
    } else if (temperature > 25) {
      tips.add('Warm weather increases sebum production. Consider a mattifying moisturizer.');
    } else if (temperature < 10) {
      tips.add('Cold weather strips moisture. Layer a hydrating serum under your moisturizer.');
      tips.add('Avoid hot showers - they damage your skin barrier in cold weather.');
    } else if (temperature < 18) {
      tips.add('Cool temperatures can dry skin. Use a richer moisturizer than summer.');
    }

    // Humidity-based tips
    if (humidity > 70) {
      tips.add('High humidity ($humidity%) - use a gel-based moisturizer to avoid greasiness.');
      tips.add('Humidity breeds bacteria. Double cleanse to keep pores clear.');
    } else if (humidity < 40) {
      tips.add('Low humidity ($humidity%) - your skin needs extra hydration. Use a humidifier indoors.');
      tips.add('Apply hyaluronic acid serum on damp skin for maximum hydration.');
    }

    // Weather condition tips
    switch (main.toLowerCase()) {
      case 'clear':
        tips.add('Clear skies mean strong UV rays. Reapply SPF every 2 hours outdoors.');
        break;
      case 'clouds':
        tips.add('Cloudy doesn\'t mean safe - 80% of UV rays penetrate clouds. Wear sunscreen!');
        break;
      case 'rain':
        tips.add('Rainy weather can still cause UV damage. Don\'t skip your sunscreen.');
        tips.add('Humidity from rain can cause fungal acne. Keep skin clean and dry.');
        break;
      case 'snow':
        tips.add('Snow reflects 80% of UV rays. Sunscreen is essential even in winter!');
        tips.add('Cold + snow = extremely dry air. Use occlusive products like petroleum jelly on dry patches.');
        break;
      case 'thunderstorm':
        tips.add('Stay indoors and use this time for a hydrating face mask!');
        break;
      case 'haze':
      case 'smoke':
      case 'dust':
        tips.add('Poor air quality detected. Double cleanse tonight to remove pollutants.');
        tips.add('Pollution causes oxidative stress. Apply antioxidant serum (Vitamin C, E).');
        break;
    }

    return tips;
  }

  /// Get weather impact on skin (for display)
  String get skinImpact {
    if (temperature > 30 && humidity > 60) {
      return 'Hot & humid - Increased oil, risk of breakouts';
    } else if (temperature > 25) {
      return 'Warm - Moderate oil production expected';
    } else if (temperature < 10) {
      return 'Cold - High risk of dryness and irritation';
    } else if (humidity < 40) {
      return 'Dry air - Skin dehydration likely';
    } else if (humidity > 70) {
      return 'Humid - May feel greasy, pores at risk';
    }
    return 'Moderate conditions - Good for skin';
  }

  /// Get weather severity for skin (0-100, higher = worse for skin)
  int get skinRiskScore {
    int score = 50;

    // Temperature impact
    if (temperature > 35) score += 20;
    else if (temperature > 30) score += 15;
    else if (temperature < 5) score += 20;
    else if (temperature < 10) score += 10;

    // Humidity impact
    if (humidity > 80) score += 15;
    else if (humidity < 30) score += 20;

    // Weather condition impact
    if (['haze', 'smoke', 'dust'].contains(main.toLowerCase())) {
      score += 15;
    }

    return score.clamp(0, 100);
  }
}

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Fetch current weather by city name
  static Future<WeatherData?> getWeatherByCity(String city) async {
    if (!ApiConfig.isWeatherConfigured) return null;

    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$city&appid=${ApiConfig.weatherApiKey}&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch current weather by coordinates
  static Future<WeatherData?> getWeatherByCoordinates(double lat, double lon) async {
    if (!ApiConfig.isWeatherConfigured) return null;

    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=${ApiConfig.weatherApiKey}&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
