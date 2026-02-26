import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/services/connectivity_service.dart';

/// Connectivity Notifier
/// Manages internet connectivity state
class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true) {
    _init();
  }

  void _init() {
    // Start monitoring connectivity
    ConnectivityService.instance.startMonitoring();

    // Listen to connectivity changes
    ConnectivityService.instance.connectivityStream.listen((isConnected) {
      state = isConnected;
    });

    // Initial check
    ConnectivityService.instance.checkConnectivity().then((value) {
      state = value;
    });
  }

  /// Manually check connectivity
  Future<void> check() async {
    final isConnected = await ConnectivityService.instance.checkConnectivity();
    state = isConnected;
  }

  /// Verify connection (call after API failures)
  Future<void> verifyConnection() async {
    await ConnectivityService.instance.verifyConnection();
  }
}

/// Connectivity Provider
/// Provides internet connectivity status
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});
