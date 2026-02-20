import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/utils/app_logger.dart';
import 'ai_service.dart';
import 'ai_cache_service.dart';
import 'local_template_matcher.dart';
import 'models/ai_generation_result.dart';
import '../template_models.dart';

/// 智能模板生成器
/// 统一入口：本地优先 → AI Fallback → 缓存兜底
class SmartTemplateGenerator {
  final AiService _aiService;
  final AiCacheService _cacheService;
  final LocalTemplateMatcher _localMatcher;

  // 配置选项
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

  /// 生成模板配置（智能路由）
  /// 返回结果和匹配信息
  Future<GenerationResponse> generate(String templateName) async {
    if (templateName.trim().isEmpty) {
      return GenerationResponse.error('请输入模板名称');
    }

    // 1. 尝试本地匹配（零成本，毫秒级）
    final localResult = _localMatcher.match(templateName);

    if (localResult.isHighMatch) {
      // 高匹配度：直接使用本地预设
      return GenerationResponse.success(
        result: localResult.result!,
        matchType: MatchType.localExact,
        matchScore: localResult.matchScore,
      );
    }

    // 2. 中等匹配度：返回推荐结果，同时提供 AI 选项
    if (localResult.isMediumMatch && localResult.result != null) {
      return GenerationResponse.success(
        result: localResult.result!,
        matchType: MatchType.localSuggested,
        matchScore: localResult.matchScore,
        suggestions: _localMatcher.getTopMatches(templateName, topN: 3),
      );
    }

    // 3. 低匹配度：尝试缓存
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

    // 4. 无匹配或低匹配：检查网络并调用 AI
    if (enableAi && await _hasNetworkConnection()) {
      try {
        final aiResult = await _aiService.generateTemplate(templateName);

        if (aiResult != null) {
          // 缓存 AI 结果
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
        // AI 失败，回退到通用模板
        AppLogger.error('AI generation failed', e);
      }
    }

    // 5. 最终兜底：通用模板
    final genericResult = _generateGenericTemplate(templateName);
    return GenerationResponse.success(
      result: genericResult,
      matchType: MatchType.genericFallback,
      matchScore: 0.3,
      message: '未找到匹配场景，已生成通用模板',
    );
  }

  /// 强制使用 AI 生成
  Future<GenerationResponse> generateWithAi(String templateName) async {
    if (!enableAi) {
      return GenerationResponse.error('AI 功能未启用');
    }

    if (!await _hasNetworkConnection()) {
      return GenerationResponse.error('无网络连接，无法使用 AI 生成');
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
        return GenerationResponse.error('AI 生成结果解析失败');
      }
    } catch (e) {
      return GenerationResponse.error('AI 生成失败: $e');
    }
  }

  /// 获取推荐场景列表
  Future<List<AiMatchResult>> getSuggestions(String templateName) async {
    return _localMatcher.getTopMatches(templateName, topN: 5);
  }

  /// 检查网络连接
  Future<bool> _hasNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// 生成通用模板（兜底方案）
  AiGenerationResult _generateGenericTemplate(String templateName) {
    return AiGenerationResult(
      templateName: templateName,
      description: '通用审批流程模板',
      fields: [
        TemplateField(
          id: 'generic_title_${DateTime.now().millisecondsSinceEpoch}',
          name: 'title',
          label: '事项标题',
          type: FieldType.text,
          required: true,
          order: 0,
          placeholder: '请输入需要审批的事项标题',
        ),
        TemplateField(
          id: 'generic_desc_${DateTime.now().millisecondsSinceEpoch}',
          name: 'description',
          label: '详细说明',
          type: FieldType.multiline,
          required: true,
          order: 1,
          placeholder: '请详细描述需要审批的事项',
        ),
        TemplateField(
          id: 'generic_attachment_${DateTime.now().millisecondsSinceEpoch}',
          name: 'attachments',
          label: '相关附件',
          type: FieldType.file,
          required: false,
          order: 2,
        ),
      ],
      approvalSteps: [
        ApprovalStep(
          id: 'generic_step_${DateTime.now().millisecondsSinceEpoch}',
          level: 1,
          name: '直属经理审批',
          approvers: ['manager@company.com'],
          requireAll: false,
        ),
      ],
      confidence: 0.3,
      source: 'fallback',
      generatedAt: DateTime.now(),
    );
  }
}

/// 匹配类型枚举
enum MatchType {
  localExact, // 本地精确匹配（>=80%）
  localSuggested, // 本地推荐匹配（50-80%）
  cached, // 缓存结果
  aiGenerated, // AI 生成
  genericFallback, // 通用模板兜底
}

/// 生成响应
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

  /// 是否高匹配
  bool get isHighMatch => matchScore != null && matchScore! >= 0.8;

  /// 是否中等匹配
  bool get isMediumMatch =>
      matchScore != null && matchScore! >= 0.5 && matchScore! < 0.8;

  /// 是否需要显示推荐
  bool get shouldShowSuggestions =>
      suggestions != null && suggestions!.isNotEmpty;

  /// 匹配类型显示文本
  String get matchTypeText {
    switch (matchType) {
      case MatchType.localExact:
        return '本地精确匹配';
      case MatchType.localSuggested:
        return '本地推荐匹配';
      case MatchType.cached:
        return '缓存结果';
      case MatchType.aiGenerated:
        return 'AI 生成';
      case MatchType.genericFallback:
        return '通用模板';
      default:
        return '未知';
    }
  }
}
