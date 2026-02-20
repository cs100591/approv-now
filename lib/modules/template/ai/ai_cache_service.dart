import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/ai_generation_result.dart';

/// AI 生成结果缓存服务
class AiCacheService {
  static const String _cachePrefix = 'ai_template_cache_';
  static const int _maxCacheSize = 100; // 最多缓存100个结果
  static const Duration _cacheExpiration = Duration(days: 30); // 缓存30天

  SharedPreferences? _prefs;

  /// 初始化缓存服务
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 获取缓存的生成结果
  Future<AiGenerationResult?> getCachedResult(String templateName) async {
    await init();

    final key = _getCacheKey(templateName);
    final cachedData = _prefs!.getString(key);

    if (cachedData == null) return null;

    try {
      final data = jsonDecode(cachedData) as Map<String, dynamic>;

      // 检查是否过期
      final cachedAt = DateTime.parse(data['cachedAt'] as String);
      if (DateTime.now().difference(cachedAt) > _cacheExpiration) {
        // 过期，删除缓存
        await _prefs!.remove(key);
        return null;
      }

      // 解析结果
      final resultData = data['result'] as Map<String, dynamic>;
      return AiGenerationResult.fromJson(resultData);
    } catch (e) {
      // 解析失败，删除无效缓存
      await _prefs!.remove(key);
      return null;
    }
  }

  /// 缓存生成结果
  Future<void> cacheResult(
      String templateName, AiGenerationResult result) async {
    await init();

    // 检查缓存大小，如果超过限制则清理最旧的缓存
    await _enforceCacheLimit();

    final key = _getCacheKey(templateName);
    final data = {
      'cachedAt': DateTime.now().toIso8601String(),
      'templateName': templateName,
      'result': result.toJson(),
    };

    await _prefs!.setString(key, jsonEncode(data));
  }

  /// 删除缓存
  Future<void> removeCache(String templateName) async {
    await init();
    final key = _getCacheKey(templateName);
    await _prefs!.remove(key);
  }

  /// 清理所有过期缓存
  Future<int> clearExpiredCache() async {
    await init();

    int clearedCount = 0;
    final keys = _prefs!.getKeys().where((key) => key.startsWith(_cachePrefix));

    for (final key in keys) {
      final cachedData = _prefs!.getString(key);
      if (cachedData != null) {
        try {
          final data = jsonDecode(cachedData) as Map<String, dynamic>;
          final cachedAt = DateTime.parse(data['cachedAt'] as String);

          if (DateTime.now().difference(cachedAt) > _cacheExpiration) {
            await _prefs!.remove(key);
            clearedCount++;
          }
        } catch (e) {
          // 解析失败，删除
          await _prefs!.remove(key);
          clearedCount++;
        }
      }
    }

    return clearedCount;
  }

  /// 清理所有缓存
  Future<void> clearAllCache() async {
    await init();

    final keys = _prefs!.getKeys().where((key) => key.startsWith(_cachePrefix));
    for (final key in keys) {
      await _prefs!.remove(key);
    }
  }

  /// 获取缓存统计
  Future<CacheStats> getCacheStats() async {
    await init();

    final keys = _prefs!.getKeys().where((key) => key.startsWith(_cachePrefix));
    int totalCount = 0;
    int expiredCount = 0;
    DateTime? oldestCache;
    DateTime? newestCache;

    for (final key in keys) {
      final cachedData = _prefs!.getString(key);
      if (cachedData != null) {
        try {
          final data = jsonDecode(cachedData) as Map<String, dynamic>;
          final cachedAt = DateTime.parse(data['cachedAt'] as String);

          totalCount++;

          if (DateTime.now().difference(cachedAt) > _cacheExpiration) {
            expiredCount++;
          }

          if (oldestCache == null || cachedAt.isBefore(oldestCache)) {
            oldestCache = cachedAt;
          }
          if (newestCache == null || cachedAt.isAfter(newestCache)) {
            newestCache = cachedAt;
          }
        } catch (e) {
          // 忽略无效缓存
        }
      }
    }

    return CacheStats(
      totalCount: totalCount,
      expiredCount: expiredCount,
      validCount: totalCount - expiredCount,
      oldestCache: oldestCache,
      newestCache: newestCache,
    );
  }

  /// 强制执行缓存大小限制
  Future<void> _enforceCacheLimit() async {
    final keys = _prefs!.getKeys().where((key) => key.startsWith(_cachePrefix));

    if (keys.length >= _maxCacheSize) {
      // 获取所有缓存的创建时间
      final cacheEntries = <MapEntry<String, DateTime>>[];

      for (final key in keys) {
        final cachedData = _prefs!.getString(key);
        if (cachedData != null) {
          try {
            final data = jsonDecode(cachedData) as Map<String, dynamic>;
            final cachedAt = DateTime.parse(data['cachedAt'] as String);
            cacheEntries.add(MapEntry(key, cachedAt));
          } catch (e) {
            // 无效缓存直接删除
            await _prefs!.remove(key);
          }
        }
      }

      // 按时间排序，删除最旧的
      cacheEntries.sort((a, b) => a.value.compareTo(b.value));

      final deleteCount = cacheEntries.length - _maxCacheSize + 1;
      for (var i = 0; i < deleteCount && i < cacheEntries.length; i++) {
        await _prefs!.remove(cacheEntries[i].key);
      }
    }
  }

  /// 生成缓存键
  String _getCacheKey(String templateName) {
    // 标准化模板名称
    final normalized =
        templateName.toLowerCase().trim().replaceAll(RegExp(r'[\s\-_]+'), '');
    return '$_cachePrefix$normalized';
  }
}

/// 缓存统计信息
class CacheStats {
  final int totalCount;
  final int expiredCount;
  final int validCount;
  final DateTime? oldestCache;
  final DateTime? newestCache;

  const CacheStats({
    required this.totalCount,
    required this.expiredCount,
    required this.validCount,
    this.oldestCache,
    this.newestCache,
  });

  @override
  String toString() {
    return 'CacheStats(total: $totalCount, valid: $validCount, expired: $expiredCount)';
  }
}
