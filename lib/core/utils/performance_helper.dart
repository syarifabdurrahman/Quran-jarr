import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

/// Performance Helper
/// Utilities for optimizing app performance
class PerformanceHelper {
  PerformanceHelper._();

  /// Schedule callback after frame render
  static void afterFrame(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  /// Run heavy computation in isolate-friendly way
  static Future<T> runAsync<T>(Future<T> Function() computation) async {
    return await computation();
  }

  /// Precache images
  static Future<void> precacheImages(BuildContext context) async {
    // Add any image precaching here if needed
  }

  /// Haptic feedback (non-blocking)
  static void hapticLight() {
    HapticFeedback.lightImpact();
  }

  static void hapticMedium() {
    HapticFeedback.mediumImpact();
  }

  static void hapticHeavy() {
    HapticFeedback.heavyImpact();
  }

  /// Optimized scroll physics
  static const ScrollPhysics optimizedScrollPhysics = ClampingScrollPhysics();

  /// List item extent for better performance
  static const double listItemExtent = 120.0;
}

/// RepaintBoundary wrapper for heavy widgets
class PerformanceBoundary extends StatelessWidget {
  final Widget child;
  final String? debugLabel;

  const PerformanceBoundary({super.key, required this.child, this.debugLabel});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: child);
  }
}

/// Optimized ListView builder
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? itemExtent;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemExtent,
    this.controller,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      itemExtent: itemExtent,
      controller: controller,
      padding: padding,
      physics: physics ?? PerformanceHelper.optimizedScrollPhysics,
      cacheExtent: 500, // Cache more items for smoother scrolling
    );
  }
}
