import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// API client for making network requests
class ApiClient {
  /// Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  
  /// Factory constructor
  factory ApiClient() => _instance;
  
  /// Internal constructor
  ApiClient._internal();
  
  /// Dio client instance
  late Dio _dio;
  
  /// Initialize the API client
  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.apiTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.apiTimeout),
        validateStatus: (status) => status! < 500,
      ),
    );
    
    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      request: AppConfig.isDevelopment,
      requestHeader: AppConfig.isDevelopment,
      requestBody: AppConfig.isDevelopment,
      responseHeader: AppConfig.isDevelopment,
      responseBody: AppConfig.isDevelopment,
      error: true,
    ));
    
    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to request headers if available
          // final token = await StorageService().getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Handle token refresh if needed
          if (e.response?.statusCode == 401) {
            // Handle token refresh logic here
          }
          return handler.next(e);
        },
      ),
    );
  }
  
  /// Get the Dio instance
  Dio get dio => _dio;
  
  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

/// API service for handling errors and responses
class ApiResponse<T> {
  /// Status of the response
  final ApiStatus status;
  
  /// Data of the response
  final T? data;
  
  /// Error message if any
  final String? message;
  
  /// Creates an API response
  ApiResponse.success(this.data)
      : status = ApiStatus.success,
        message = null;
        
  /// Creates an error response
  ApiResponse.error(this.message)
      : status = ApiStatus.error,
        data = null;
        
  /// Creates a loading response
  ApiResponse.loading()
      : status = ApiStatus.loading,
        data = null,
        message = null;
}

/// Status of the API response
enum ApiStatus { loading, success, error }
