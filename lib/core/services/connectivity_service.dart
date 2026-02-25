import 'dart:async';
import 'package:dio/dio.dart';

/// Connectivity Service
/// Monitors internet connection status
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService _instance = ConnectivityService._();
  static ConnectivityService get instance => _instance;

  final Dio _dio = Dio();

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _controller.stream;

  /// Check internet connectivity by pinging a reliable server
  Future<bool> checkConnectivity() async {
    try {
      // Try to reach Google's DNS (works better than API calls for connectivity)
      final response = await _dio.get(
        'https://dns.google/resolve',
        queryParameters: {'name': 'google.com', 'type': 'A'},
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      final wasConnected = _isConnected;
      _isConnected = response.statusCode == 200;

      if (wasConnected != _isConnected) {
        _controller.add(_isConnected);
      }

      return _isConnected;
    } catch (e) {
      final wasConnected = _isConnected;
      _isConnected = false;

      if (wasConnected != _isConnected) {
        _controller.add(_isConnected);
      }

      return false;
    }
  }

  /// Start periodic connectivity checks
  void startMonitoring() {
    // Check every 10 seconds
    Timer.periodic(const Duration(seconds: 10), (_) {
      checkConnectivity();
    });

    // Initial check
    checkConnectivity();
  }

  /// Manual check - call this after API failures
  Future<void> verifyConnection() async {
    await checkConnectivity();
  }

  void dispose() {
    _controller.close();
  }
}
