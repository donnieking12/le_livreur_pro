import 'package:flutter/foundation.dart';

/// Logging levels for the application
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Application logger utility
/// Replaces print statements with structured logging
/// In production, logs can be sent to external logging services
class AppLogger {
  static const String _tag = 'LeLivreurPro';

  /// Log a debug message (only in debug mode)
  static void debug(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  static void info(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  static void warning(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  static void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a critical error message
  static void critical(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Only log in debug mode or for errors/critical in production
    if (!kDebugMode && level != LogLevel.error && level != LogLevel.critical) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? _tag;
    final levelStr = level.name.toUpperCase().padRight(8);

    // Format: [TIMESTAMP] [LEVEL] [TAG] Message
    final logMessage = '[$timestamp] [$levelStr] [$logTag] $message';

    // In debug mode, print to console
    if (kDebugMode) {
      // Use different colors/symbols for different levels (if terminal supports it)
      switch (level) {
        case LogLevel.debug:
          debugPrint('🔍 $logMessage');
          break;
        case LogLevel.info:
          debugPrint('ℹ️  $logMessage');
          break;
        case LogLevel.warning:
          debugPrint('⚠️  $logMessage');
          break;
        case LogLevel.error:
          debugPrint('❌ $logMessage');
          break;
        case LogLevel.critical:
          debugPrint('🚨 $logMessage');
          break;
      }

      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('   StackTrace: $stackTrace');
      }
    }

    // In production, send to logging service (e.g., Sentry, Firebase Crashlytics)
    if (!kDebugMode &&
        (level == LogLevel.error || level == LogLevel.critical)) {
      _sendToLoggingService(level, message, error, stackTrace);
    }
  }

  /// Send logs to external logging service in production
  static void _sendToLoggingService(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // TODO: Implement integration with logging service (Sentry, Firebase, etc.)
    // Example:
    // if (error != null) {
    //   Sentry.captureException(error, stackTrace: stackTrace);
    // } else {
    //   Sentry.captureMessage(message, level: _convertToSentryLevel(level));
    // }
  }

  /// Log API request
  static void apiRequest(String method, String url,
      {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      info('API Request: $method $url', tag: 'API');
      if (params != null && params.isNotEmpty) {
        debug('  Params: $params', tag: 'API');
      }
    }
  }

  /// Log API response
  static void apiResponse(String method, String url, int statusCode,
      {dynamic data}) {
    if (kDebugMode) {
      final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      info('$emoji API Response: $method $url - Status: $statusCode',
          tag: 'API');
      if (data != null) {
        debug('  Data: $data', tag: 'API');
      }
    }
  }

  /// Log navigation events
  static void navigation(String from, String to) {
    if (kDebugMode) {
      debug('Navigation: $from → $to', tag: 'Navigation');
    }
  }

  /// Log user actions
  static void userAction(String action, {Map<String, dynamic>? metadata}) {
    if (kDebugMode) {
      info('User Action: $action', tag: 'UserAction');
      if (metadata != null && metadata.isNotEmpty) {
        debug('  Metadata: $metadata', tag: 'UserAction');
      }
    }
  }

  /// Log payment events
  static void payment(String event, {Map<String, dynamic>? details}) {
    info('Payment Event: $event', tag: 'Payment');
    if (details != null && details.isNotEmpty) {
      debug('  Details: $details', tag: 'Payment');
    }
  }

  /// Log order events
  static void order(String event, String orderId,
      {Map<String, dynamic>? details}) {
    info('Order Event: $event - Order: $orderId', tag: 'Order');
    if (details != null && details.isNotEmpty) {
      debug('  Details: $details', tag: 'Order');
    }
  }
}
