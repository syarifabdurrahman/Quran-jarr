import 'package:dio/dio.dart';

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  factory ApiException.fromDioError(DioException error) {
    String message;
    int? statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        statusCode = error.response?.statusCode;
        break;

      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode;
        message = _getStatusMessage(statusCode);
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;

      case DioExceptionType.unknown:
        final errorObj = error.error;
        if (errorObj != null && errorObj.toString().contains('SocketException')) {
          message = 'No internet connection.';
        } else {
          message = 'An unexpected error occurred: ${error.message}';
        }
        statusCode = error.response?.statusCode;
        break;

      default:
        message = 'An unexpected error occurred.';
        statusCode = error.response?.statusCode;
    }

    return ApiException(message, statusCode: statusCode);
  }

  static String _getStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have access.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
