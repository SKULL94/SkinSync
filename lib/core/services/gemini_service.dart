import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:skin_sync/core/config/api_config.dart';
import 'package:skin_sync/core/error/exceptions.dart' as app_exceptions;
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';

class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;
  bool _isInitialized = false;

  GeminiService({String? apiKey}) : apiKey = apiKey ?? ApiConfig.geminiApiKey;

  void _initialize() {
    if (_isInitialized) return;

    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      throw const app_exceptions.ServerException(
        message: 'Gemini API key not configured. Please add your API key.',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 1024,
      ),
    );
    _isInitialized = true;
  }

  Future<AIAnalysisModel> analyzeSkinImage(File imageFile) async {
    _initialize();

    try {
      final imageBytes = await imageFile.readAsBytes();
      final mimeType = _getMimeType(imageFile.path);

      final prompt = TextPart(_skinAnalysisPrompt);
      final imagePart = DataPart(mimeType, imageBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw const app_exceptions.ServerException(
          message: 'No response from AI. Please try again.',
        );
      }

      return AIAnalysisModel.fromJsonString(responseText);
    } on GenerativeAIException catch (e) {
      throw app_exceptions.ServerException(message: 'AI Analysis failed: ${e.message}');
    } catch (e) {
      if (e is app_exceptions.ServerException) rethrow;
      throw app_exceptions.ServerException(message: 'Analysis failed: $e');
    }
  }

  Future<String> generatePersonalizedTips({
    required String skinType,
    required List<String> concerns,
    required int lastScore,
    String? weather,
  }) async {
    _initialize();

    try {
      final prompt = '''
You are a friendly skincare advisor. Based on the user's profile, provide 3 personalized tips.

User Profile:
- Skin Type: $skinType
- Concerns: ${concerns.join(', ')}
- Last Skin Score: $lastScore/100
${weather != null ? '- Current Weather: $weather' : ''}

Provide exactly 3 short, actionable tips (1-2 sentences each). Be specific and encouraging.
Format as a simple numbered list.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Keep up with your skincare routine!';
    } catch (e) {
      return 'Keep up with your skincare routine! Consistency is key.';
    }
  }

  Future<String> generateCustomContent(String prompt) async {
    _initialize();

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      rethrow;
    }
  }

  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  static const String _skinAnalysisPrompt = '''
You are a professional skin analysis AI assistant. Analyze this skin image carefully and provide a detailed assessment.

IMPORTANT: Be medically responsible. If you see concerning symptoms that require professional attention, indicate that clearly.

Provide your response ONLY as a valid JSON object with this exact structure:

{
  "overall_score": <number 0-100, or "needs_professional_assessment" if concerning>,
  "metrics": {
    "texture": <number 0-100, higher is better/smoother>,
    "clarity": <number 0-100, higher is clearer/less blemishes>,
    "oiliness": <number 0-100, 50 is balanced, higher is more oily>,
    "hydration": <number 0-100, higher is better hydrated>,
    "pore_visibility": <number 0-100, lower means less visible pores>,
    "firmness": <number 0-100, higher is firmer skin>
  },
  "detected_concerns": ["list of specific concerns you observe"],
  "severity": "mild" | "moderate" | "severe" | "needs_dermatologist",
  "skin_type": "oily" | "dry" | "combination" | "normal" | "sensitive",
  "recommendations": ["3 specific actionable recommendations"],
  "ingredients_to_look_for": ["4-5 ingredients that would help based on concerns"],
  "ai_insight": "A brief 1-2 sentence personalized insight about their skin",
  "disclaimer": true if professional consultation is recommended
}

Respond with ONLY the JSON object, no additional text or markdown formatting.
''';
}
