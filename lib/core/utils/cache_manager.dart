import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Advanced cache manager for Le Livreur Pro
class CacheManager {
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._internal();
  CacheManager._internal();

  SharedPreferences? _prefs;
  final Map<String, CacheEntry> _memoryCache = {};
  
  // Cache configuration
  static const Duration _defaultTTL = Duration(hours: 1);
  static const int _maxMemoryCacheSize = 100;
  static const int _maxDiskCacheSize = 500;

  /// Initialize the cache manager
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _cleanExpiredEntries();
      debugPrint('💾 Cache manager initialized');
    } catch (e) {
      debugPrint('❌ Cache initialization error: $e');
    }
  }

  /// Store data in cache with optional TTL
  Future<void> store<T>({
    required String key,
    required T data,
    Duration? ttl,
    bool memoryOnly = false,
  }) async {
    try {
      final cacheEntry = CacheEntry<T>(
        data: data,
        timestamp: DateTime.now(),
        ttl: ttl ?? _defaultTTL,
      );

      // Store in memory cache
      _memoryCache[key] = cacheEntry;
      _enforceMemoryCacheLimit();

      // Store in persistent cache unless memory-only
      if (!memoryOnly && _prefs != null) {
        final serializedData = _serializeData(cacheEntry);
        if (serializedData != null) {
          await _prefs!.setString(key, serializedData);
          await _enforceDiskCacheLimit();
        }
      }

      debugPrint('💾 Cached: $key (TTL: ${ttl ?? _defaultTTL})');
    } catch (e) {
      debugPrint('❌ Cache store error for $key: $e');
    }
  }

  /// Retrieve data from cache
  Future<T?> retrieve<T>(String key) async {
    try {
      // Check memory cache first
      final memoryCacheEntry = _memoryCache[key];
      if (memoryCacheEntry != null && !memoryCacheEntry.isExpired) {
        debugPrint('⚡ Memory cache hit: $key');
        return memoryCacheEntry.data as T?;
      }

      // Check persistent cache
      if (_prefs != null && _prefs!.containsKey(key)) {
        final serializedData = _prefs!.getString(key);
        if (serializedData != null) {
          final cacheEntry = _deserializeData<T>(serializedData);
          if (cacheEntry != null && !cacheEntry.isExpired) {
            // Restore to memory cache
            _memoryCache[key] = cacheEntry;
            debugPrint('💾 Disk cache hit: $key');
            return cacheEntry.data as T?;
          } else {
            // Remove expired entry
            await _prefs!.remove(key);
            debugPrint('🗑️ Removed expired cache: $key');
          }
        }
      }

      debugPrint('❌ Cache miss: $key');
      return null;
    } catch (e) {
      debugPrint('❌ Cache retrieve error for $key: $e');
      return null;
    }
  }

  /// Check if cache contains valid data
  Future<bool> contains(String key) async {
    final data = await retrieve(key);
    return data != null;
  }

  /// Remove specific cache entry
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      if (_prefs != null) {
        await _prefs!.remove(key);
      }
      debugPrint('🗑️ Removed cache: $key');
    } catch (e) {
      debugPrint('❌ Cache remove error for $key: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      _memoryCache.clear();
      if (_prefs != null) {
        final keys = _prefs!.getKeys().where((key) => key.startsWith('cache_'));
        for (final key in keys) {
          await _prefs!.remove(key);
        }
      }
      debugPrint('🧹 All cache cleared');
    } catch (e) {
      debugPrint('❌ Cache clear error: $e');
    }
  }

  /// Clear expired entries
  Future<void> _cleanExpiredEntries() async {
    try {
      // Clean memory cache
      _memoryCache.removeWhere((key, entry) => entry.isExpired);

      // Clean disk cache
      if (_prefs != null) {
        final keys = _prefs!.getKeys().where((key) => key.startsWith('cache_'));
        for (final key in keys) {
          final serializedData = _prefs!.getString(key);
          if (serializedData != null) {
            final cacheEntry = _deserializeData(serializedData);
            if (cacheEntry?.isExpired == true) {
              await _prefs!.remove(key);
            }
          }
        }
      }

      debugPrint('🧹 Expired cache entries cleaned');
    } catch (e) {
      debugPrint('❌ Cache cleanup error: $e');
    }
  }

  /// Enforce memory cache size limit
  void _enforceMemoryCacheLimit() {
    if (_memoryCache.length > _maxMemoryCacheSize) {
      // Remove oldest entries
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

      final entriesToRemove = sortedEntries.take(_memoryCache.length - _maxMemoryCacheSize);
      for (final entry in entriesToRemove) {
        _memoryCache.remove(entry.key);
      }

      debugPrint('🧹 Memory cache limit enforced: ${_memoryCache.length}/$_maxMemoryCacheSize');
    }
  }

  /// Enforce disk cache size limit
  Future<void> _enforceDiskCacheLimit() async {
    if (_prefs == null) return;

    try {
      final cacheKeys = _prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();
      
      if (cacheKeys.length > _maxDiskCacheSize) {
        // Get timestamps for sorting
        final keyTimestamps = <String, DateTime>{};
        for (final key in cacheKeys) {
          final serializedData = _prefs!.getString(key);
          if (serializedData != null) {
            final cacheEntry = _deserializeData(serializedData);
            if (cacheEntry != null) {
              keyTimestamps[key] = cacheEntry.timestamp;
            }
          }
        }

        // Sort by timestamp and remove oldest
        final sortedKeys = keyTimestamps.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        final keysToRemove = sortedKeys.take(cacheKeys.length - _maxDiskCacheSize);
        for (final entry in keysToRemove) {
          await _prefs!.remove(entry.key);
        }

        debugPrint('🧹 Disk cache limit enforced: ${cacheKeys.length - keysToRemove.length}/$_maxDiskCacheSize');
      }
    } catch (e) {
      debugPrint('❌ Disk cache limit enforcement error: $e');
    }
  }

  /// Serialize cache entry to string
  String? _serializeData<T>(CacheEntry<T> entry) {
    try {
      final Map<String, dynamic> entryMap = {
        'data': entry.data,
        'timestamp': entry.timestamp.millisecondsSinceEpoch,
        'ttl': entry.ttl.inMilliseconds,
      };
      return jsonEncode(entryMap);
    } catch (e) {
      debugPrint('❌ Serialization error: $e');
      return null;
    }
  }

  /// Deserialize string to cache entry
  CacheEntry<T>? _deserializeData<T>(String serializedData) {
    try {
      final Map<String, dynamic> entryMap = jsonDecode(serializedData);
      return CacheEntry<T>(
        data: entryMap['data'] as T,
        timestamp: DateTime.fromMillisecondsSinceEpoch(entryMap['timestamp']),
        ttl: Duration(milliseconds: entryMap['ttl']),
      );
    } catch (e) {
      debugPrint('❌ Deserialization error: $e');
      return null;
    }
  }

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    int diskCacheSize = 0;
    if (_prefs != null) {
      diskCacheSize = _prefs!.getKeys().where((key) => key.startsWith('cache_')).length;
    }

    return CacheStats(
      memoryCacheSize: _memoryCache.length,
      diskCacheSize: diskCacheSize,
      maxMemoryCacheSize: _maxMemoryCacheSize,
      maxDiskCacheSize: _maxDiskCacheSize,
    );
  }
}

/// Cache entry with timestamp and TTL
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}

/// Cache statistics
class CacheStats {
  final int memoryCacheSize;
  final int diskCacheSize;
  final int maxMemoryCacheSize;
  final int maxDiskCacheSize;

  CacheStats({
    required this.memoryCacheSize,
    required this.diskCacheSize,
    required this.maxMemoryCacheSize,
    required this.maxDiskCacheSize,
  });

  @override
  String toString() {
    return 'CacheStats(memory: $memoryCacheSize/$maxMemoryCacheSize, disk: $diskCacheSize/$maxDiskCacheSize)';
  }
}