import 'dart:math';
import 'models/ai_generation_result.dart';
import 'ai_preset_configs.dart';

/// 本地模板匹配引擎
/// 使用多种算法匹配用户输入与预设场景
class LocalTemplateMatcher {
  static const double _highMatchThreshold = 0.8;
  static const double _mediumMatchThreshold = 0.5;

  /// 匹配用户输入与预设场景
  AiMatchResult match(String input) {
    if (input.trim().isEmpty) {
      return const AiMatchResult(
        matchScore: 0.0,
        matchType: 'none',
      );
    }

    final normalizedInput = _normalize(input);

    // 1. 精确匹配（100%）
    final exactMatch = _findExactMatch(normalizedInput);
    if (exactMatch != null) {
      return AiMatchResult(
        result: exactMatch,
        matchScore: 1.0,
        matchType: 'exact',
        matchedPresetName: exactMatch.matchedScenario,
      );
    }

    // 2. 包含匹配（90%）
    final containsMatch = _findContainsMatch(normalizedInput);
    if (containsMatch != null) {
      return AiMatchResult(
        result: containsMatch.result,
        matchScore: containsMatch.matchScore,
        matchType: 'contains',
        matchedPresetName: containsMatch.matchedPresetName,
      );
    }

    // 3. 编辑距离匹配（Levenshtein）
    final fuzzyMatch = _findFuzzyMatch(normalizedInput);
    if (fuzzyMatch != null && fuzzyMatch.matchScore >= _highMatchThreshold) {
      return AiMatchResult(
        result: fuzzyMatch.result,
        matchScore: fuzzyMatch.matchScore,
        matchType: 'fuzzy',
        matchedPresetName: fuzzyMatch.matchedPresetName,
      );
    }

    // 4. 关键词相似度匹配
    final similarityMatch = _findSimilarityMatch(normalizedInput);
    if (similarityMatch != null) {
      return AiMatchResult(
        result: similarityMatch.matchScore >= _mediumMatchThreshold
            ? similarityMatch.result
            : null,
        matchScore: similarityMatch.matchScore,
        matchType: similarityMatch.matchScore >= _mediumMatchThreshold
            ? 'similarity'
            : 'none',
        matchedPresetName: similarityMatch.matchedPresetName,
      );
    }

    // 无匹配
    return const AiMatchResult(
      matchScore: 0.0,
      matchType: 'none',
    );
  }

  /// 获取最相似的几个预设（用于推荐）
  List<AiMatchResult> getTopMatches(String input, {int topN = 3}) {
    final normalizedInput = _normalize(input);
    final results = <AiMatchResult>[];

    for (final preset in aiPresetConfigs) {
      double maxScore = 0.0;

      for (final keyword in preset.keywords) {
        final score =
            _calculateSimilarity(normalizedInput, _normalize(keyword));
        if (score > maxScore) {
          maxScore = score;
        }
      }

      if (maxScore > 0.3) {
        results.add(
          AiMatchResult(
            result: _presetToResult(preset, input, maxScore),
            matchScore: maxScore,
            matchType: 'similarity',
            matchedPresetName: preset.name,
          ),
        );
      }
    }

    // 按匹配度排序
    results.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return results.take(topN).toList();
  }

  /// 精确匹配
  AiGenerationResult? _findExactMatch(String input) {
    for (final preset in aiPresetConfigs) {
      for (final keyword in preset.keywords) {
        if (_normalize(keyword) == input) {
          return _presetToResult(preset, input, 1.0);
        }
      }
    }
    return null;
  }

  /// 包含匹配
  AiMatchResult? _findContainsMatch(String input) {
    for (final preset in aiPresetConfigs) {
      for (final keyword in preset.keywords) {
        final normalizedKeyword = _normalize(keyword);

        // 输入包含关键词
        if (input.contains(normalizedKeyword)) {
          return AiMatchResult(
            result: _presetToResult(preset, input, 0.9),
            matchScore: 0.9,
            matchType: 'contains',
            matchedPresetName: preset.name,
          );
        }

        // 关键词包含输入（适用于缩写）
        if (normalizedKeyword.contains(input) && input.length >= 2) {
          return AiMatchResult(
            result: _presetToResult(preset, input, 0.85),
            matchScore: 0.85,
            matchType: 'contains',
            matchedPresetName: preset.name,
          );
        }
      }
    }
    return null;
  }

  /// 模糊匹配（编辑距离）
  AiMatchResult? _findFuzzyMatch(String input) {
    AiPresetConfig? bestPreset;
    double bestScore = 0.0;

    for (final preset in aiPresetConfigs) {
      for (final keyword in preset.keywords) {
        final distance = _levenshteinDistance(input, _normalize(keyword));
        final maxLength = max(input.length, keyword.length);
        final similarity = 1.0 - (distance / maxLength);

        if (similarity > bestScore) {
          bestScore = similarity;
          bestPreset = preset;
        }
      }
    }

    if (bestPreset != null && bestScore >= _mediumMatchThreshold) {
      return AiMatchResult(
        result: _presetToResult(bestPreset, input, bestScore),
        matchScore: bestScore,
        matchType: 'fuzzy',
        matchedPresetName: bestPreset.name,
      );
    }

    return null;
  }

  /// 相似度匹配（TF-IDF 简化版）
  AiMatchResult? _findSimilarityMatch(String input) {
    AiPresetConfig? bestPreset;
    double bestScore = 0.0;

    for (final preset in aiPresetConfigs) {
      for (final keyword in preset.keywords) {
        final score = _calculateSimilarity(input, _normalize(keyword));

        if (score > bestScore) {
          bestScore = score;
          bestPreset = preset;
        }
      }
    }

    if (bestPreset != null) {
      return AiMatchResult(
        result: _presetToResult(bestPreset, input, bestScore),
        matchScore: bestScore,
        matchType: 'similarity',
        matchedPresetName: bestPreset.name,
      );
    }

    return null;
  }

  /// 计算相似度（简化版余弦相似度）
  double _calculateSimilarity(String s1, String s2) {
    // 使用字符级别的 Jaccard 相似度
    final set1 = s1.split('').toSet();
    final set2 = s2.split('').toSet();

    final intersection = set1.intersection(set2);
    final union = set1.union(set2);

    if (union.isEmpty) return 0.0;

    // 基础 Jaccard 相似度
    double jaccard = intersection.length / union.length;

    // 长度惩罚（避免短词匹配长词）
    final lengthDiff = (s1.length - s2.length).abs();
    final lengthPenalty = 1.0 - (lengthDiff / max(s1.length, s2.length));

    // 顺序奖励（如果包含连续字符序列）
    double sequenceBonus =
        _longestCommonSubstring(s1, s2) / max(s1.length, s2.length);

    return (jaccard * 0.4 + lengthPenalty * 0.3 + sequenceBonus * 0.3);
  }

  /// 最长公共子串
  int _longestCommonSubstring(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    var maxLength = 0;

    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
          maxLength = max(maxLength, dp[i][j]);
        }
      }
    }

    return maxLength;
  }

  /// Levenshtein 编辑距离
  int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;

    if (m == 0) return n;
    if (n == 0) return m;

    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 +
              min(
                min(dp[i - 1][j], dp[i][j - 1]),
                dp[i - 1][j - 1],
              );
        }
      }
    }

    return dp[m][n];
  }

  /// 将预设配置转换为生成结果
  AiGenerationResult _presetToResult(
    AiPresetConfig preset,
    String templateName,
    double confidence,
  ) {
    return AiGenerationResult(
      templateName: templateName,
      description: preset.description,
      fields: preset.fields
          .asMap()
          .entries
          .map((e) => e.value.toTemplateField(e.key))
          .toList(),
      approvalSteps: preset.approvalSteps
          .asMap()
          .entries
          .map((e) => e.value.toApprovalStep(e.key + 1))
          .toList(),
      confidence: confidence,
      source: 'local',
      matchedScenario: preset.name,
      generatedAt: DateTime.now(),
    );
  }

  /// 文本标准化处理
  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\s\-_]+'), '') // 移除空格、横杠、下划线
        .replaceAll(RegExp(r'[^\w\u4e00-\u9fff]'), ''); // 只保留字母、数字、中文
  }

  int max(int a, int b) => a > b ? a : b;
}
