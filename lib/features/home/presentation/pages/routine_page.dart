import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/config/api_config.dart';
import 'package:skin_sync/core/services/gemini_service.dart';
import 'package:skin_sync/core/theme/theme_extension.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:intl/intl.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  bool _isMorning = true;
  bool _useAIRoutine = false;
  bool _isGeneratingAI = false;
  bool _isCancelled = false; // For API cancellation
  Map<String, bool> _morningChecks = {};
  Map<String, bool> _nightChecks = {};
  String _todayKey = '';

  // Default routines
  List<_RoutineStep> _defaultMorningSteps = [
    _RoutineStep(id: 'cleanser', name: 'Cleanser', icon: Icons.water_drop_outlined, duration: '60 sec'),
    _RoutineStep(id: 'toner', name: 'Toner', icon: Icons.opacity, duration: '30 sec'),
    _RoutineStep(id: 'serum', name: 'Serum', icon: Icons.science_outlined, duration: '60 sec'),
    _RoutineStep(id: 'moisturizer', name: 'Moisturizer', icon: Icons.spa_outlined, duration: '30 sec'),
    _RoutineStep(id: 'sunscreen', name: 'Sunscreen', icon: Icons.wb_sunny_outlined, duration: '60 sec'),
  ];

  List<_RoutineStep> _defaultNightSteps = [
    _RoutineStep(id: 'makeup_remover', name: 'Makeup Remover', icon: Icons.face_retouching_off, duration: '60 sec'),
    _RoutineStep(id: 'cleanser_n', name: 'Cleanser', icon: Icons.water_drop_outlined, duration: '60 sec'),
    _RoutineStep(id: 'toner_n', name: 'Toner', icon: Icons.opacity, duration: '30 sec'),
    _RoutineStep(id: 'treatment', name: 'Treatment/Serum', icon: Icons.science_outlined, duration: '60 sec'),
    _RoutineStep(id: 'eye_cream', name: 'Eye Cream', icon: Icons.remove_red_eye_outlined, duration: '30 sec'),
    _RoutineStep(id: 'moisturizer_n', name: 'Night Moisturizer', icon: Icons.nightlight_outlined, duration: '30 sec'),
  ];

  // AI-generated routines
  List<_RoutineStep> _aiMorningSteps = [];
  List<_RoutineStep> _aiNightSteps = [];

  List<_RoutineStep> get _morningSteps => _useAIRoutine && _aiMorningSteps.isNotEmpty ? _aiMorningSteps : _defaultMorningSteps;
  List<_RoutineStep> get _nightSteps => _useAIRoutine && _aiNightSteps.isNotEmpty ? _aiNightSteps : _defaultNightSteps;

  @override
  void initState() {
    super.initState();
    _todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadData();

    // Auto-select based on time of day
    final hour = DateTime.now().hour;
    _isMorning = hour < 14;
  }

  @override
  void dispose() {
    _isCancelled = true; // Cancel any pending API calls
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load routine preference
    _useAIRoutine = prefs.getBool('use_ai_routine') ?? false;

    // Load AI routines if saved
    final aiMorningJson = prefs.getString('ai_morning_routine');
    final aiNightJson = prefs.getString('ai_night_routine');

    if (aiMorningJson != null) {
      _aiMorningSteps = _parseRoutineJson(aiMorningJson);
    }
    if (aiNightJson != null) {
      _aiNightSteps = _parseRoutineJson(aiNightJson);
    }

    // Load checks
    _loadChecks();
  }

  List<_RoutineStep> _parseRoutineJson(String json) {
    try {
      final List<dynamic> list = jsonDecode(json);
      return list.map((item) => _RoutineStep(
        id: item['id'] ?? item['name'].toString().toLowerCase().replaceAll(' ', '_'),
        name: item['name'] ?? '',
        icon: _getIconForStep(item['name'] ?? ''),
        duration: item['duration'] ?? '60 sec',
        tip: item['tip'],
      )).toList();
    } catch (e) {
      return [];
    }
  }

  IconData _getIconForStep(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('cleans')) return Icons.water_drop_outlined;
    if (lower.contains('tone')) return Icons.opacity;
    if (lower.contains('serum') || lower.contains('treatment')) return Icons.science_outlined;
    if (lower.contains('moistur')) return Icons.spa_outlined;
    if (lower.contains('sun') || lower.contains('spf')) return Icons.wb_sunny_outlined;
    if (lower.contains('eye')) return Icons.remove_red_eye_outlined;
    if (lower.contains('night') || lower.contains('sleep')) return Icons.nightlight_outlined;
    if (lower.contains('mask')) return Icons.face_outlined;
    if (lower.contains('oil')) return Icons.water_outlined;
    if (lower.contains('exfol')) return Icons.grain;
    if (lower.contains('makeup') || lower.contains('remov')) return Icons.face_retouching_off;
    return Icons.check_circle_outline;
  }

  Future<void> _loadChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _useAIRoutine ? 'ai_' : '';

    setState(() {
      for (final step in _morningSteps) {
        _morningChecks[step.id] = prefs.getBool('routine_${prefix}${_todayKey}_morning_${step.id}') ?? false;
      }
      for (final step in _nightSteps) {
        _nightChecks[step.id] = prefs.getBool('routine_${prefix}${_todayKey}_night_${step.id}') ?? false;
      }
    });
  }

  Future<void> _toggleCheck(String id, bool isMorning) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _useAIRoutine ? 'ai_' : '';
    final key = 'routine_${prefix}${_todayKey}_${isMorning ? 'morning' : 'night'}_$id';

    setState(() {
      if (isMorning) {
        _morningChecks[id] = !(_morningChecks[id] ?? false);
        prefs.setBool(key, _morningChecks[id]!);
      } else {
        _nightChecks[id] = !(_nightChecks[id] ?? false);
        prefs.setBool(key, _nightChecks[id]!);
      }
    });
  }

  Future<void> _toggleRoutineType(bool useAI) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_ai_routine', useAI);

    setState(() {
      _useAIRoutine = useAI;
      _morningChecks = {};
      _nightChecks = {};
    });

    _loadChecks();
  }

  Future<void> _generateAIRoutine() async {
    if (!ApiConfig.isGeminiConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI not configured. Please add Gemini API key.')),
      );
      return;
    }

    setState(() {
      _isGeneratingAI = true;
      _isCancelled = false;
    });

    try {
      // Check if cancelled before starting
      if (_isCancelled || !mounted) return;

      // Get user's skin data
      String skinType = 'combination';
      List<String> concerns = [];

      final historyState = context.read<HistoryBloc>().state;
      if (historyState.histories.isNotEmpty) {
        final latest = historyState.histories.first;
        if (latest.aiAnalysis != null) {
          skinType = latest.aiAnalysis!['skin_type'] as String? ?? 'combination';
          final detectedConcerns = latest.aiAnalysis!['detected_concerns'];
          if (detectedConcerns is List) {
            concerns = detectedConcerns.map((e) => e.toString()).toList();
          }
        }
      }

      final gemini = GeminiService();
      final prompt = '''
Create a personalized skincare routine for someone with $skinType skin.
${concerns.isNotEmpty ? 'Their main concerns are: ${concerns.join(", ")}.' : ''}

Respond with ONLY a JSON object (no markdown, no explanation) in this exact format:
{
  "morning": [
    {"name": "Step Name", "duration": "60 sec", "tip": "Brief tip for this step"}
  ],
  "night": [
    {"name": "Step Name", "duration": "60 sec", "tip": "Brief tip for this step"}
  ]
}

Include 4-6 steps for each routine. Be specific to their skin type and concerns.
''';

      final response = await gemini.generateCustomContent(prompt);

      // Check if cancelled after API call
      if (_isCancelled || !mounted) return;

      // Parse response
      String jsonStr = response.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replaceAll(RegExp(r'^```json?\n?'), '').replaceAll(RegExp(r'\n?```$'), '');
      }

      final Map<String, dynamic> routines = jsonDecode(jsonStr);

      final prefs = await SharedPreferences.getInstance();

      if (routines['morning'] != null) {
        _aiMorningSteps = (routines['morning'] as List).asMap().entries.map((entry) {
          final item = entry.value;
          return _RoutineStep(
            id: 'ai_m_${entry.key}',
            name: item['name'] ?? '',
            icon: _getIconForStep(item['name'] ?? ''),
            duration: item['duration'] ?? '60 sec',
            tip: item['tip'],
          );
        }).toList();
        await prefs.setString('ai_morning_routine', jsonEncode(routines['morning']));
      }

      if (routines['night'] != null) {
        _aiNightSteps = (routines['night'] as List).asMap().entries.map((entry) {
          final item = entry.value;
          return _RoutineStep(
            id: 'ai_n_${entry.key}',
            name: item['name'] ?? '',
            icon: _getIconForStep(item['name'] ?? ''),
            duration: item['duration'] ?? '60 sec',
            tip: item['tip'],
          );
        }).toList();
        await prefs.setString('ai_night_routine', jsonEncode(routines['night']));
      }

      setState(() {
        _useAIRoutine = true;
        _morningChecks = {};
        _nightChecks = {};
      });

      await prefs.setBool('use_ai_routine', true);
      _loadChecks();

    } catch (e) {
      if (!mounted) return;

      final errorMsg = e.toString().toLowerCase();
      String message = 'Failed to generate routine';

      if (errorMsg.contains('quota') || errorMsg.contains('rate') || errorMsg.contains('exceeded')) {
        message = 'API quota exceeded. Please try again later.';
      } else if (errorMsg.contains('cancelled')) {
        return; // User cancelled, no need to show error
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingAI = false);
    }
  }

  int get _morningProgress {
    if (_morningSteps.isEmpty) return 0;
    final completed = _morningChecks.values.where((v) => v).length;
    return ((completed / _morningSteps.length) * 100).round();
  }

  int get _nightProgress {
    if (_nightSteps.isEmpty) return 0;
    final completed = _nightChecks.values.where((v) => v).length;
    return ((completed / _nightSteps.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colors),
            _buildRoutineTypeSelector(colors),
            const SizedBox(height: 8),
            _buildTimeToggle(colors),
            Expanded(child: _buildChecklist(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorsTheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'My Routine',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineTypeSelector(AppColorsTheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleRoutineType(false),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: !_useAIRoutine ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_useAIRoutine ? AppColors.primary : AppColors.cardBorder,
                    width: !_useAIRoutine ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 18,
                      color: !_useAIRoutine ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Default',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: !_useAIRoutine ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _aiMorningSteps.isNotEmpty
                  ? () => _toggleRoutineType(true)
                  : _generateAIRoutine,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: _useAIRoutine
                      ? LinearGradient(
                          colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.rose.withValues(alpha: 0.15)],
                        )
                      : null,
                  color: _useAIRoutine ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _useAIRoutine ? AppColors.primary : AppColors.cardBorder,
                    width: _useAIRoutine ? 1.5 : 1,
                  ),
                ),
                child: _isGeneratingAI
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Creating...',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 18,
                            color: _useAIRoutine ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Routine',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _useAIRoutine ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (_useAIRoutine && _aiMorningSteps.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _generateAIRoutine,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: _isGeneratingAI
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : Icon(Icons.refresh, size: 18, color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeToggle(AppColorsTheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isMorning = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isMorning ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 16,
                        color: _isMorning ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Morning',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isMorning ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isMorning
                              ? Colors.white.withValues(alpha: 0.2)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$_morningProgress%',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _isMorning ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isMorning = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_isMorning ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.nightlight_outlined,
                        size: 16,
                        color: !_isMorning ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Night',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: !_isMorning ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: !_isMorning
                              ? Colors.white.withValues(alpha: 0.2)
                              : AppColors.rose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$_nightProgress%',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: !_isMorning ? Colors.white : AppColors.rose,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(AppColorsTheme colors) {
    final steps = _isMorning ? _morningSteps : _nightSteps;
    final checks = _isMorning ? _morningChecks : _nightChecks;
    final progress = _isMorning ? _morningProgress : _nightProgress;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Progress card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isMorning
                  ? [AppColors.primary, AppColors.primaryLight]  // Terracotta gradient
                  : [const Color(0xFF5A6B8C), const Color(0xFF7A8BA8)],  // Soft slate blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Text(
                      '$progress%',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          progress == 100
                              ? 'All done!'
                              : progress > 50
                                  ? 'Almost there!'
                                  : 'Let\'s go!',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (_useAIRoutine) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                                const SizedBox(width: 3),
                                Text(
                                  'AI',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progress == 100
                          ? 'Your ${_isMorning ? "morning" : "night"} routine is complete'
                          : '${checks.values.where((v) => v).length} of ${steps.length} steps completed',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (progress == 100)
                const Icon(Icons.check_circle, color: Colors.white, size: 28),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Steps list
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isChecked = checks[step.id] ?? false;

          return Padding(
            padding: EdgeInsets.only(bottom: index < steps.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => _toggleCheck(step.id, _isMorning),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isChecked ? AppColors.sage : AppColors.cardBorder,
                    width: isChecked ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isChecked
                            ? AppColors.sage.withValues(alpha: 0.15)
                            : AppColors.cardBorder.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        step.icon,
                        size: 20,
                        color: isChecked ? AppColors.sage : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isChecked ? AppColors.sage : AppColors.textPrimary,
                              decoration: isChecked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.tip ?? step.duration,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isChecked ? AppColors.sage : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isChecked ? AppColors.sage : AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Tip
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.sage.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.sage.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: AppColors.sage),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _useAIRoutine
                      ? 'This routine is personalized for your skin type. Tap the refresh icon to regenerate.'
                      : _isMorning
                          ? 'Wait 2-3 minutes between each step for better absorption'
                          : 'Apply products on slightly damp skin for better penetration',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoutineStep {
  final String id;
  final String name;
  final IconData icon;
  final String duration;
  final String? tip;

  const _RoutineStep({
    required this.id,
    required this.name,
    required this.icon,
    required this.duration,
    this.tip,
  });
}
