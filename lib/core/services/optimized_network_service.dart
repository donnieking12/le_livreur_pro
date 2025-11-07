import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:le_livreur_pro/core/utils/cache_manager.dart';

/// Optimized network service with caching and retry logic
class OptimizedNetworkService {
  static OptimizedNetworkService? _instance;
  static OptimizedNetworkService get instance => _instance ??= OptimizedNetworkService._internal();
  OptimizedNetworkService._internal();

  final http.Client _client = http.Client();
  final CacheManager _cacheManager = CacheManager.instance;
  
  // Network configuration
  static const Duration _connectionTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);
  
  // Request queue for offline handling
  final List<PendingRequest> _pendingRequests = [];
  bool _isOnline = true;

  /// Initialize the network service
  Future<void> initialize() async {
    await _cacheManager.initialize();
    _startConnectivityMonitoring();
    debugPrint('🌐 Optimized network service initialized');
  }

  /// Dispose the network service
  void dispose() {
    _client.close();
    debugPrint('🌐 Network service disposed');
  }

  /// GET request with caching
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool useCache = true,
    Duration? cacheTtl,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final cacheKey = 'GET_${uri.toString()}';

    // Try cache first
    if (useCache) {
      final cachedData = await _cacheManager.retrieve<T>(cacheKey);
      if (cachedData != null) {
        debugPrint('⚡ Cache hit for GET $endpoint');
        return ApiResponse.success(cachedData);
      }
    }

    // Make network request
    try {
      final response = await _makeRequest(
        () => _client.get(uri, headers: _buildHeaders(headers)),
      );

      if (response.isSuccess && response.data != null) {
        T? parsedData;
        
        if (fromJson != null && response.data is Map<String, dynamic>) {
          parsedData = fromJson(response.data as Map<String, dynamic>);
        } else {
          parsedData = response.data as T?;
        }

        // Cache successful response
        if (useCache && parsedData != null) {
          await _cacheManager.store(
            key: cacheKey,
            data: parsedData,
            ttl: cacheTtl,
          );
        }

        return ApiResponse.success(parsedData);
      }

      return ApiResponse.error(response.message ?? 'Unknown error');
    } catch (e) {
      debugPrint('❌ GET request failed: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// POST request with retry logic
  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParams);

    try {
      final response = await _makeRequest(
        () => _client.post(
          uri,
          headers: _buildHeaders(headers),
          body: body != null ? jsonEncode(body) : null,
        ),
      );

      if (response.isSuccess && response.data != null) {
        T? parsedData;
        
        if (fromJson != null && response.data is Map<String, dynamic>) {
          parsedData = fromJson(response.data as Map<String, dynamic>);
        } else {
          parsedData = response.data as T?;
        }

        return ApiResponse.success(parsedData);
      }

      return ApiResponse.error(response.message ?? 'Unknown error');
    } catch (e) {
      debugPrint('❌ POST request failed: $e');
      
      // Queue for retry if offline
      if (!_isOnline) {
        _queueRequest(PendingRequest(
          method: 'POST',
          endpoint: endpoint,
          body: body,
          headers: headers,
          queryParams: queryParams,
        ));
      }
      
      return ApiResponse.error(e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParams);

    try {
      final response = await _makeRequest(
        () => _client.put(
          uri,
          headers: _buildHeaders(headers),
          body: body != null ? jsonEncode(body) : null,
        ),
      );

      if (response.isSuccess && response.data != null) {
        T? parsedData;
        
        if (fromJson != null && response.data is Map<String, dynamic>) {
          parsedData = fromJson(response.data as Map<String, dynamic>);
        } else {
          parsedData = response.data as T?;
        }

        return ApiResponse.success(parsedData);
      }

      return ApiResponse.error(response.message ?? 'Unknown error');
    } catch (e) {
      debugPrint('❌ PUT request failed: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<bool>> delete({
    required String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);

    try {
      final response = await _makeRequest(
        () => _client.delete(uri, headers: _buildHeaders(headers)),
      );

      return ApiResponse.success(response.isSuccess);
    } catch (e) {
      debugPrint('❌ DELETE request failed: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Make HTTP request with retry logic
  Future<ApiResponse<dynamic>> _makeRequest(
    Future<http.Response> Function() requestFunction,
  ) async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        final response = await requestFunction().timeout(_connectionTimeout);
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = response.body.isNotEmpty 
            ? jsonDecode(response.body) 
            : null;
          return ApiResponse.success(data);
        } else if (response.statusCode >= 500 && attempts < _maxRetries - 1) {
          // Retry on server errors
          attempts++;
          await Future.delayed(_retryDelay * attempts);
          continue;
        } else {
          final errorMessage = _extractErrorMessage(response);
          return ApiResponse.error(errorMessage);
        }
      } on TimeoutException {
        if (attempts < _maxRetries - 1) {
          attempts++;
          await Future.delayed(_retryDelay * attempts);
          continue;
        }
        return ApiResponse.error('Request timeout');
      } on SocketException {
        _isOnline = false;
        return ApiResponse.error('No internet connection');
      } catch (e) {
        if (attempts < _maxRetries - 1) {
          attempts++;
          await Future.delayed(_retryDelay * attempts);
          continue;
        }
        return ApiResponse.error(e.toString());
      }
    }
    
    return ApiResponse.error('Max retry attempts exceeded');
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    final baseUrl = 'https://your-api-base-url.com'; // Replace with actual base URL
    var uri = Uri.parse('$baseUrl$endpoint');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }
    
    return uri;
  }

  /// Build headers
  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    
    return headers;
  }

  /// Extract error message from response
  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body['message'] ?? body['error'] ?? 'HTTP ${response.statusCode}';
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }
    
    return 'HTTP ${response.statusCode}';
  }

  /// Start connectivity monitoring
  void _startConnectivityMonitoring() {
    // In a real app, you would use connectivity_plus package
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConnectivity();
    });
  }

  /// Check connectivity and process pending requests
  Future<void> _checkConnectivity() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com')).timeout(
        const Duration(seconds: 5),
      );
      
      if (result.statusCode == 200 && !_isOnline) {
        _isOnline = true;
        debugPrint('🌐 Connection restored, processing pending requests');
        await _processPendingRequests();
      }
    } catch (e) {
      _isOnline = false;
    }
  }

  /// Queue request for later processing
  void _queueRequest(PendingRequest request) {
    _pendingRequests.add(request);
    debugPrint('📤 Queued request: ${request.method} ${request.endpoint}');
  }

  /// Process pending requests when connection is restored
  Future<void> _processPendingRequests() async {
    final requestsToProcess = List<PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();

    for (final request in requestsToProcess) {
      try {
        await post(
          endpoint: request.endpoint,
          body: request.body,
          headers: request.headers,
          queryParams: request.queryParams,
        );
        debugPrint('✅ Processed pending request: ${request.method} ${request.endpoint}');
      } catch (e) {
        debugPrint('❌ Failed to process pending request: $e');
        // Re-queue if still failing
        _pendingRequests.add(request);
      }
    }
  }
}

/// API Response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool isSuccess;

  ApiResponse._({this.data, this.message, required this.isSuccess});

  factory ApiResponse.success(T? data) => ApiResponse._(data: data, isSuccess: true);
  factory ApiResponse.error(String message) => ApiResponse._(message: message, isSuccess: false);
}

/// Pending request for offline handling
class PendingRequest {
  final String method;
  final String endpoint;
  final Map<String, dynamic>? body;
  final Map<String, String>? headers;
  final Map<String, dynamic>? queryParams;
  final DateTime timestamp;

  PendingRequest({
    required this.method,
    required this.endpoint,
    this.body,
    this.headers,
    this.queryParams,
  }) : timestamp = DateTime.now();
}