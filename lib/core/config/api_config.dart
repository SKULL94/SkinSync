import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration
///
/// Keys are loaded from .env file. Never commit .env to version control.
/// See .env.example for required variables.
class ApiConfig {
  ApiConfig._();

  /// Gemini API Key
  /// Get your free key from: https://aistudio.google.com/
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? '';

  /// OpenWeatherMap API Key (optional, for weather-based tips)
  /// Get your free key from: https://openweathermap.org/api
  static String get weatherApiKey =>
      dotenv.env['OPENWEATHERMAP_API_KEY'] ?? '';

  /// Check if Gemini is configured
  static bool get isGeminiConfigured =>
      geminiApiKey.isNotEmpty &&
      geminiApiKey != 'your_gemini_api_key_here';

  /// Check if Weather is configured
  static bool get isWeatherConfigured =>
      weatherApiKey.isNotEmpty &&
      weatherApiKey != 'your_openweathermap_api_key_here' &&
      weatherApiKey != 'YOUR_OPENWEATHERMAP_API_KEY';
}
