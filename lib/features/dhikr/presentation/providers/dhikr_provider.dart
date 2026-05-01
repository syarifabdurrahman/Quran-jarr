import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';

class DhikrState {
  final int count;
  final int target;
  final String sessionName;

  DhikrState({
    this.count = 0,
    this.target = 33,
    this.sessionName = 'SubhanAllah',
  });

  DhikrState copyWith({
    int? count,
    int? target,
    String? sessionName,
  }) {
    return DhikrState(
      count: count ?? this.count,
      target: target ?? this.target,
      sessionName: sessionName ?? this.sessionName,
    );
  }
}

class DhikrNotifier extends StateNotifier<DhikrState> {
  DhikrNotifier() : super(DhikrState()) {
    _loadState();
  }

  void _loadState() {
    final prefs = PreferencesService.instance;
    final savedCount = prefs.getDhikrCount();
    state = state.copyWith(count: savedCount);
  }

  void increment() {
    state = state.copyWith(count: state.count + 1);
    PreferencesService.instance.setDhikrCount(state.count);
  }

  void reset() {
    state = state.copyWith(count: 0);
    PreferencesService.instance.setDhikrCount(0);
  }

  void setTarget(int target) {
    state = state.copyWith(target: target);
  }
}

final dhikrProvider = StateNotifierProvider<DhikrNotifier, DhikrState>((ref) {
  return DhikrNotifier();
});
