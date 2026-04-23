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
      final wasDisconnected = !state;
      state = isConnected;
      // Call callbacks when connection is restored
      if (isConnected && wasDisconnected) {
        _onConnectionRestoredCallbacks.forEach((callback) {
          callback();
        });
      }
    });

    // Initial check
    ConnectivityService.instance.checkConnectivity().then((value) {
      state = value;
    });
  }

  /// Callbacks to run when connection is restored
  final List<void Function()> _onConnectionRestoredCallbacks = [];

  /// Register a callback to be called when connection is restored
  void onConnectionRestored(void Function() callback) {
    _onConnectionRestoredCallbacks.add(callback);
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
