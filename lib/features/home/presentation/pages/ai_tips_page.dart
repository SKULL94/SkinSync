import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/config/api_config.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/services/gemini_service.dart';
import 'package:skin_sync/core/services/weather_service.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';

class AITipsPage extends StatefulWidget {
  const AITipsPage({super.key});

  @override
  State<AITipsPage> createState() => _AITipsPageState();
}

class _AITipsPageState extends State<AITipsPage> {
  bool _isLoading = true;
  bool _isCancelled = false; // For API cancellation
  WeatherData? _weather;
  List<_TipSection> _sections = [];
  int _scanCount = 0;

  // User data
  String _skinType = 'combination';
  List<String> _concerns = [];
  int _lastScore = 70;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _isCancelled = true; // Cancel any pending API calls
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isCancelled = false;
    });

    // Get user data from history
    final historyState = context.read<HistoryBloc>().state;
    _scanCount = historyState.histories.length;

    // Get user skin data if available
    if (historyState.histories.isNotEmpty) {
      final latest = historyState.histories.first;
      if (latest.aiAnalysis != null) {
        _lastScore =
            (latest.aiAnalysis!['overall_score'] as num?)?.toInt() ?? 70;
        _skinType = latest.aiAnalysis!['skin_type'] as String? ?? 'combination';
        final concerns = latest.aiAnalysis!['detected_concerns'];
        if (concerns is List) {
          _concerns = concerns.map((e) => e.toString()).toList();
        }
      }
    }

    // Check if cancelled before weather fetch
    if (_isCancelled || !mounted) return;

    // Always fetch weather
    _weather = await WeatherService.getWeatherByCity('Mumbai');

    // Check if cancelled before generating tips
    if (_isCancelled || !mounted) return;

    // Only generate AI tips if user has at least 3 scans
    if (_scanCount >= 3) {
      await _generateAllTips();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _generateAllTips() async {
    _sections = [
      if (_weather != null) _buildWeatherSection(),
      _buildFoodSection(),
      _buildLifestyleSection(),
    ];

    // Check if cancelled before API call
    if (_isCancelled || !mounted) return;

    // Add personalized tips if Gemini is configured
    if (ApiConfig.isGeminiConfigured) {
      try {
        final gemini = GeminiService();
        final personalizedTips = await gemini.generatePersonalizedTips(
          skinType: _skinType,
          concerns: _concerns.isEmpty ? ['general care'] : _concerns,
          lastScore: _lastScore,
          weather: _weather != null
              ? '${_weather!.temperature.round()}°C, ${_weather!.description}'
              : null,
        );

        // Check if cancelled after API call
        if (_isCancelled || !mounted) return;

        final tips = _parseTips(personalizedTips);
        if (tips.isNotEmpty) {
          _sections.insert(
            0,
            _TipSection(
              title: 'For You',
              subtitle: 'Based on your $_skinType skin',
              icon: Icons.auto_awesome,
              color: AppColors.primary,
              tips: tips,
            ),
          );
        }
      } catch (e) {
        if (_isCancelled || !mounted) return;

        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('quota') ||
            errorMsg.contains('rate') ||
            errorMsg.contains('exceeded')) {
          _sections.insert(
            0,
            _TipSection(
              title: 'AI Tips Unavailable',
              subtitle: 'API quota exceeded - resets daily',
              icon: Icons.info_outline,
              color: AppColors.rose,
              tips: [
                'Your Gemini API free tier limit has been reached.',
                'Tips will be available when quota resets.',
                'Check console.cloud.google.com for usage details.'
              ],
            ),
          );
        }
      }
    }
  }

  List<String> _parseTips(String response) {
    final lines = response.split('\n');
    final tips = <String>[];
    for (final line in lines) {
      final cleaned = line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim();
      if (cleaned.isNotEmpty && cleaned.length > 10) {
        tips.add(cleaned);
      }
    }
    return tips;
  }

  _TipSection _buildWeatherSection() {
    return _TipSection(
      title: 'Weather Tips',
      subtitle: '${_weather!.cityName} • ${_weather!.temperature.round()}°C',
      icon: _getWeatherIcon(_weather!.main),
      color: AppColors.amber,
      tips: _weather!.skinTips,
    );
  }

  IconData _getWeatherIcon(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.cloud_queue;
    }
  }

  _TipSection _buildFoodSection() {
    return _TipSection(
      title: 'Food & Nutrition',
      subtitle: 'Eat your way to better skin',
      icon: Icons.restaurant_outlined,
      color: AppColors.sage,
      tips: const [
        'Fatty fish (salmon, mackerel) 2x weekly - omega-3s reduce inflammation.',
        'Colorful vegetables daily - antioxidants fight free radicals.',
        'Green tea contains EGCG - protects against sun damage.',
        'Avocados provide healthy fats for supple, moisturized skin.',
        'Berries are packed with antioxidants that fight premature aging.',
        'Tomatoes (cooked) are rich in lycopene for UV protection.',
        'Brazil nuts (2-3 daily) provide selenium for skin elasticity.',
        'Limit sugar and dairy if prone to breakouts.',
      ],
    );
  }

  _TipSection _buildLifestyleSection() {
    return _TipSection(
      title: 'Lifestyle Habits',
      subtitle: 'Daily practices for healthy skin',
      icon: Icons.self_improvement,
      color: AppColors.rose,
      tips: const [
        'Sleep 7-9 hours - skin produces collagen during deep sleep.',
        'Change pillowcases weekly to prevent bacteria buildup.',
        'Exercise increases blood flow, delivering nutrients to skin.',
        'Manage stress - cortisol triggers oil production and breakouts.',
        'Avoid touching your face to prevent bacteria transfer.',
        'Clean phone screen daily - it harbors bacteria!',
        'Stay hydrated - aim for 8 glasses of water daily.',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading tips...',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // Header with weather
          SliverToBoxAdapter(child: _buildHeader()),

          // Weather card (if available)
          if (_weather != null) SliverToBoxAdapter(child: _buildWeatherCard()),

          // Show message if not enough scans
          if (_scanCount < 3)
            SliverToBoxAdapter(child: _buildScanRequiredCard()),

          // Tip sections (only shown if enough scans)
          if (_scanCount >= 3)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _TipSectionCard(section: _sections[index]),
                childCount: _sections.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildScanRequiredCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.face_retouching_natural,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Personalized Tips Locked',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete 3 skin AI scans to unlock personalized skincare tips based on your skin type and concerns.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isCompleted = index < _scanCount;
              return Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.sage
                      : AppColors.cardBorder.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.camera_alt_outlined,
                  size: 16,
                  color: isCompleted ? Colors.white : AppColors.textTertiary,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '$_scanCount of 3 scans completed',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.push(AppRoutes.skinAnalysisRoute),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Start Skin Scan',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI POWERED',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Skincare Tips',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    final weather = _weather!;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        weather.cityName,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weather.temperature.round()}°C',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(
                    _getWeatherIcon(weather.main),
                    size: 48,
                    color: Colors.white,
                  ),
                  Text(
                    weather.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Humidity and Skin Impact Row
          Row(
            children: [
              // Humidity Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      '${weather.humidity}%',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Skin Risk Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      weather.skinRiskScore > 65
                          ? Icons.warning_amber
                          : Icons.shield,
                      size: 14,
                      color: weather.skinRiskScore > 65
                          ? Colors.amber
                          : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Risk: ${weather.skinRiskScore}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Skin Impact Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.face, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skin Impact',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        weather.skinImpact,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> tips;

  const _TipSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tips,
  });
}

class _TipSectionCard extends StatelessWidget {
  final _TipSection section;

  const _TipSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: section.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(section.icon, size: 22, color: section.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        section.subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: section.tips.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key < section.tips.length - 1 ? 12 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: section.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
