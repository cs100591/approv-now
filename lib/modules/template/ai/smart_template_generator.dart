import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/utils/app_logger.dart';
import 'ai_service.dart';
import 'ai_cache_service.dart';
import 'local_template_matcher.dart';
import 'models/ai_generation_result.dart';
import '../template_models.dart';

/// Smart Template Generator
/// Unified entry: Local first -> AI Fallback -> Cache fallback
class SmartTemplateGenerator {
  final AiService _aiService;
  final AiCacheService _cacheService;
  final LocalTemplateMatcher _localMatcher;

  final bool enableAi;
  final bool enableCache;
  final double highMatchThreshold;
  final double mediumMatchThreshold;

  SmartTemplateGenerator({
    String? openAiApiKey,
    this.enableAi = true,
    this.enableCache = true,
    this.highMatchThreshold = 0.8,
    this.mediumMatchThreshold = 0.5,
  })  : _aiService = AiService(apiKey: openAiApiKey),
        _cacheService = AiCacheService(),
        _localMatcher = LocalTemplateMatcher();

  /// Generate template config (smart routing)
  Future<GenerationResponse> generate(String templateName) async {
    if (templateName.trim().isEmpty) {
      return GenerationResponse.error('Please enter a template name');
    }

    // 1. Try local match (zero cost, milliseconds)
    final localResult = _localMatcher.match(templateName);

    if (localResult.isHighMatch) {
      return GenerationResponse.success(
        result: localResult.result!,
        matchType: MatchType.localExact,
        matchScore: localResult.matchScore,
      );
    }

    // 2. Medium match: return suggested result with AI option
    if (localResult.isMediumMatch && localResult.result != null) {
      return GenerationResponse.success(
        result: localResult.result!,
        matchType: MatchType.localSuggested,
        matchScore: localResult.matchScore,
        suggestions: _localMatcher.getTopMatches(templateName, topN: 3),
      );
    }

    // 3. Low match: try cache
    if (enableCache) {
      final cachedResult = await _cacheService.getCachedResult(templateName);
      if (cachedResult != null) {
        return GenerationResponse.success(
          result: cachedResult,
          matchType: MatchType.cached,
          matchScore: 0.7,
        );
      }
    }

    // 4. No match: check network and call AI
    if (enableAi && await _hasNetworkConnection()) {
      try {
        final aiResult = await _aiService.generateTemplate(templateName);

        if (aiResult != null) {
          if (enableCache) {
            await _cacheService.cacheResult(templateName, aiResult);
          }

          return GenerationResponse.success(
            result: aiResult,
            matchType: MatchType.aiGenerated,
            matchScore: 0.95,
          );
        }
      } catch (e) {
        AppLogger.error('AI generation failed', e);
      }
    }

    // 5. Final fallback: generic template
    final genericResult = _generateGenericTemplate(templateName);
    return GenerationResponse.success(
      result: genericResult,
      matchType: MatchType.genericFallback,
      matchScore: 0.3,
      message: 'No matching scenario found, generated generic template',
    );
  }

  /// Force AI generation
  Future<GenerationResponse> generateWithAi(String templateName) async {
    if (!enableAi) {
      return GenerationResponse.error('AI feature not enabled');
    }

    if (!await _hasNetworkConnection()) {
      return GenerationResponse.error(
          'No network connection, cannot use AI generation');
    }

    try {
      final aiResult = await _aiService.generateTemplate(templateName);

      if (aiResult != null) {
        if (enableCache) {
          await _cacheService.cacheResult(templateName, aiResult);
        }

        return GenerationResponse.success(
          result: aiResult,
          matchType: MatchType.aiGenerated,
          matchScore: 0.95,
        );
      } else {
        return GenerationResponse.error('AI generation result parsing failed');
      }
    } catch (e) {
      return GenerationResponse.error('AI generation failed: $e');
    }
  }

  /// Get suggested scenarios list
  Future<List<AiMatchResult>> getSuggestions(String templateName) async {
    return _localMatcher.getTopMatches(templateName, topN: 5);
  }

  /// Check network connection
  Future<bool> _hasNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Generate generic template (fallback)
  AiGenerationResult _generateGenericTemplate(String templateName) {
    return AiGenerationResult(
      templateName: templateName,
      description: 'Generic approval workflow template',
      fields: [
        TemplateField(
          id: 'generic_title_${DateTime.now().millisecondsSinceEpoch}',
          name: 'title',
          label: 'Title',
          type: FieldType.text,
          required: true,
          order: 0,
          placeholder: 'Enter the title for approval',
        ),
        TemplateField(
          id: 'generic_desc_${DateTime.now().millisecondsSinceEpoch}',
          name: 'description',
          label: 'Description',
          type: FieldType.multiline,
          required: true,
          order: 1,
          placeholder: 'Describe the request in detail',
        ),
        TemplateField(
          id: 'generic_attachment_${DateTime.now().millisecondsSinceEpoch}',
          name: 'attachments',
          label: 'Attachments',
          type: FieldType.file,
          required: false,
          order: 2,
        ),
      ],
      approvalSteps: [], // Admin will add approvers manually with UUIDs
      confidence: 0.3,
      source: 'fallback',
      generatedAt: DateTime.now(),
    );
  }
}

/// Match type enum
enum MatchType {
  localExact, // Local exact match (>=80%)
  localSuggested, // Local suggested match (50-80%)
  cached, // Cached result
  aiGenerated, // AI generated
  genericFallback, // Generic template fallback
}

/// Generation response
class GenerationResponse {
  final bool success;
  final AiGenerationResult? result;
  final MatchType? matchType;
  final double? matchScore;
  final String? message;
  final List<AiMatchResult>? suggestions;
  final String? error;

  const GenerationResponse._({
    required this.success,
    this.result,
    this.matchType,
    this.matchScore,
    this.message,
    this.suggestions,
    this.error,
  });

  factory GenerationResponse.success({
    required AiGenerationResult result,
    required MatchType matchType,
    required double matchScore,
    String? message,
    List<AiMatchResult>? suggestions,
  }) =>
      GenerationResponse._(
        success: true,
        result: result,
        matchType: matchType,
        matchScore: matchScore,
        message: message,
        suggestions: suggestions,
      );

  factory GenerationResponse.error(String error) => GenerationResponse._(
        success: false,
        error: error,
      );

  bool get isHighMatch => matchScore != null && matchScore! >= 0.8;

  bool get isMediumMatch =>
      matchScore != null && matchScore! >= 0.5 && matchScore! < 0.8;

  bool get shouldShowSuggestions =>
      suggestions != null && suggestions!.isNotEmpty;

  String get matchTypeText {
    switch (matchType) {
      case MatchType.localExact:
        return 'Exact Match';
      case MatchType.localSuggested:
        return 'Suggested';
      case MatchType.cached:
        return 'Cached';
      case MatchType.aiGenerated:
        return 'AI Generated';
      case MatchType.genericFallback:
        return 'Generic';
      default:
        return 'Unknown';
    }
  }
}
