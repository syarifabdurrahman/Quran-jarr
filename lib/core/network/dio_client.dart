import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Dio Client Configuration
/// Singleton instance for API calls
class DioClient {
  DioClient._();

  static DioClient? _instance;
  static DioClient get instance => _instance ??= DioClient._();

  Dio? _dio;
  bool _isInitialized = false;

  Dio get dio {
    if (!_isInitialized) {
      initialize();
    }
    return _dio!;
  }

  void initialize() {
    if (_isInitialized) return; // Prevent double initialization

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: ApiConfig.timeoutSeconds),
        receiveTimeout: const Duration(seconds: ApiConfig.timeoutSeconds),
        sendTimeout: const Duration(seconds: ApiConfig.timeoutSeconds),
        headers: ApiConfig.headers,
      ),
    );

    // Add interceptors
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add default parameters
          options.queryParameters.addAll(ApiConfig.defaultParams);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          final exception = ApiException.fromDioError(error);
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: exception,
            response: error.response,
            type: error.type,
          ));
        },
      ),
    );

    // Add logging interceptor in debug mode
    _dio!.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );

    _isInitialized = true;
  }
}
