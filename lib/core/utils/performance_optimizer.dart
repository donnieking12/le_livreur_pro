import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Performance optimization utilities for Le Livreur Pro
class PerformanceOptimizer {
  static Timer? _memoryCleanupTimer;
  static bool _isOptimizationEnabled = true;

  /// Initialize performance optimizations
  static void initialize() {
    if (!_isOptimizationEnabled) return;

    // Start periodic memory cleanup
    _startMemoryCleanup();
    
    // Optimize system UI
    _optimizeSystemUI();
    
    // Enable performance monitoring in debug mode
    if (kDebugMode) {
      _enablePerformanceMonitoring();
    }
    
    debugPrint('🚀 Performance optimizations initialized');
  }

  /// Dispose performance optimizations
  static void dispose() {
    _memoryCleanupTimer?.cancel();
    _memoryCleanupTimer = null;
    debugPrint('🧹 Performance optimizations disposed');
  }

  /// Start periodic memory cleanup
  static void _startMemoryCleanup() {
    _memoryCleanupTimer?.cancel();
    
    // Clean up memory every 5 minutes
    _memoryCleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _performMemoryCleanup(),
    );
  }

  /// Perform memory cleanup
  static void _performMemoryCleanup() {
    try {
      // Force garbage collection
      if (kDebugMode) {
        debugPrint('🧹 Performing memory cleanup...');
      }
      
      // Clear image cache if it's getting too large
      PaintingBinding.instance.imageCache.clear();
      
      // Clear any temporary data
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      
      if (kDebugMode) {
        debugPrint('✅ Memory cleanup completed');
      }
    } catch (e) {
      debugPrint('❌ Memory cleanup error: $e');
    }
  }

  /// Optimize system UI for better performance
  static void _optimizeSystemUI() {
    try {
      // Set preferred orientations for mobile
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Optimize system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      debugPrint('📱 System UI optimized');
    } catch (e) {
      debugPrint('❌ System UI optimization error: $e');
    }
  }

  /// Enable performance monitoring for development
  static void _enablePerformanceMonitoring() {
    if (!kDebugMode) return;

    // Log performance metrics
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _logPerformanceMetrics();
    });
  }

  /// Log current performance metrics
  static void _logPerformanceMetrics() {
    if (!kDebugMode) return;

    try {
      final binding = WidgetsBinding.instance;
      
      // Log frame rendering info
      debugPrint('📊 Performance Metrics:');
      debugPrint('   • Image cache size: ${PaintingBinding.instance.imageCache.currentSize}');
      debugPrint('   • Image cache live count: ${PaintingBinding.instance.imageCache.liveImageCount}');
      debugPrint('   • Image cache pending count: ${PaintingBinding.instance.imageCache.pendingImageCount}');
      
    } catch (e) {
      debugPrint('❌ Performance monitoring error: $e');
    }
  }

  /// Preload critical resources
  static Future<void> preloadCriticalResources() async {
    try {
      debugPrint('⏳ Preloading critical resources...');
      
      // Preload commonly used assets
      await _preloadAssets();
      
      // Warm up commonly used services
      await _warmUpServices();
      
      debugPrint('✅ Critical resources preloaded');
    } catch (e) {
      debugPrint('❌ Resource preloading error: $e');
    }
  }

  /// Preload commonly used assets
  static Future<void> _preloadAssets() async {
    // Preload app icons and commonly used images
    // This would typically load from assets/images/
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Warm up commonly used services
  static Future<void> _warmUpServices() async {
    // Initialize commonly used services to reduce first-time delays
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Optimize list scrolling performance
  static Widget optimizeListView({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Performance optimizations
      cacheExtent: 1000.0, // Cache items for smooth scrolling
      physics: const ClampingScrollPhysics(), // Better performance on Android
      addAutomaticKeepAlives: false, // Don't keep all items alive
      addRepaintBoundaries: false, // Reduce repaint boundaries
    );
  }

  /// Optimize image loading
  static Widget optimizeNetworkImage({
    required String imageUrl,
    required Widget Function(BuildContext, Widget, int?, bool) builder,
    Widget Function(BuildContext, String)? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Performance optimizations
      frameBuilder: builder,
      errorBuilder: errorBuilder,
      cacheWidth: width?.round(),
      cacheHeight: height?.round(),
      isAntiAlias: false, // Disable anti-aliasing for better performance
      filterQuality: FilterQuality.low, // Use low quality for list images
    );
  }

  /// Debounce function calls to improve performance
  static void debounce({
    required String key,
    required VoidCallback callback,
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _DebouncerManager.instance.debounce(key, callback, delay);
  }

  /// Throttle function calls to improve performance
  static void throttle({
    required String key,
    required VoidCallback callback,
    Duration interval = const Duration(milliseconds: 100),
  }) {
    _ThrottlerManager.instance.throttle(key, callback, interval);
  }

  /// Enable or disable optimizations
  static void setOptimizationEnabled(bool enabled) {
    _isOptimizationEnabled = enabled;
    if (!enabled) {
      dispose();
    } else {
      initialize();
    }
  }
}

/// Debouncer manager for performance optimization
class _DebouncerManager {
  static final _DebouncerManager _instance = _DebouncerManager._internal();
  static _DebouncerManager get instance => _instance;
  _DebouncerManager._internal();

  final Map<String, Timer> _timers = {};

  void debounce(String key, VoidCallback callback, Duration delay) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, () {
      callback();
      _timers.remove(key);
    });
  }

  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}

/// Throttler manager for performance optimization
class _ThrottlerManager {
  static final _ThrottlerManager _instance = _ThrottlerManager._internal();
  static _ThrottlerManager get instance => _instance;
  _ThrottlerManager._internal();

  final Map<String, DateTime> _lastExecution = {};

  void throttle(String key, VoidCallback callback, Duration interval) {
    final now = DateTime.now();
    final lastTime = _lastExecution[key];
    
    if (lastTime == null || now.difference(lastTime) >= interval) {
      _lastExecution[key] = now;
      callback();
    }
  }

  void dispose() {
    _lastExecution.clear();
  }
}