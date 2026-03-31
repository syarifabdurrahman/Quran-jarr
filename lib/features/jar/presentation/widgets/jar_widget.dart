import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/features/jar/domain/models/jar_type.dart';

/// Jar Widget
/// A beautiful glass jar visualization with pull interaction
class JarWidget extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  final bool isEmpty;
  final bool isAnimating;
  final bool shouldShake;

  const JarWidget({
    super.key,
    this.onTap,
    this.isEmpty = false,
    this.isAnimating = false,
    this.shouldShake = false,
  });

  @override
  ConsumerState<JarWidget> createState() => _JarWidgetState();
}

class _JarWidgetState extends ConsumerState<JarWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _paperController;
  bool _isPressed = false;
  bool _showPaperSlip = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _paperController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _paperController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(JarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _triggerShakeAnimation();
    }
  }

  Future<void> _triggerShakeAnimation() async {
    await _shakeController.forward();
    await _shakeController.reverse();
  }

  Future<void> _handleTap() async {
    if (_showPaperSlip) return;

    setState(() => _showPaperSlip = true);

    // Simple shake
    await _shakeController.forward();
    await _shakeController.reverse();

    // Paper slip comes out
    await _paperController.forward();

    // Reset after animation
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _showPaperSlip = false);
    _shakeController.reset();
    await _paperController.reverse();

    // Call the onTap callback
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxJarHeight = screenHeight * 0.4;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxJarHeight),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _handleTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final jarScale = (screenWidth / 375).clamp(0.7, 1.3);
            final jarWidth = AppConstants.jarWidth * jarScale;
            final jarHeight = AppConstants.jarHeight * jarScale;

            return SizedBox(
              width: jarWidth + 60 * jarScale,
              height: jarHeight + 80 * jarScale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Jar (centered)
                  Positioned(
                    left: 30 * jarScale,
                    top: 40 * jarScale,
                    child: AnimatedScale(
                      scale: _isPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      child: AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          final shake =
                              sin(_shakeController.value * 3.14159 * 4) *
                              10 *
                              (1 - _shakeController.value);
                          return Transform.translate(
                            offset: Offset(shake, 0),
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: jarWidth,
                          height: jarHeight,
                          child: CustomPaint(
                            painter: JarPainterFactory.create(
                              type: JarType.values[ref.watch(jarTypeProvider)],
                              isEmpty: widget.isEmpty,
                              isDark:
                                  Theme.of(context).brightness ==
                                  Brightness.dark,
                            ),
                          ),
                        ),
                      ),
                    ).animate().then(delay: 100.ms).fade(duration: 400.ms),
                  ),

                  // Paper slip that comes out
                  if (_showPaperSlip)
                    Positioned(
                      left: jarWidth / 2 - 25 * jarScale,
                      top: 90 * jarScale,
                      child: AnimatedBuilder(
                        animation: _paperController,
                        builder: (context, child) {
                          final curve = Curves.easeOutCubic;
                          final t = curve.transform(_paperController.value);

                          return Transform.translate(
                            offset: Offset(0, -t * 120 * jarScale),
                            child: Transform.rotate(
                              angle: -0.15 + (t * 0.08),
                              child: Opacity(opacity: t, child: child),
                            ),
                          );
                        },
                        child: _PaperSlipWidget(scale: jarScale),
                      ),
                    ).animate().fade(duration: 150.ms),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Paper Slip Widget
class _PaperSlipWidget extends StatelessWidget {
  final double scale;

  const _PaperSlipWidget({this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 55 * scale,
      height: 75 * scale,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cream,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.deepUmber).withValues(
              alpha: 0.15,
            ),
            blurRadius: 12,
            offset: const Offset(3, 6),
          ),
        ],
        border: Border.all(
          color: (isDark ? AppColors.midnightSlate : AppColors.glassBorder)
              .withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 3 * scale,
              width: 35 * scale,
              decoration: BoxDecoration(
                color:
                    (isDark ? AppColors.darkTextSecondary : AppColors.deepUmber)
                        .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(1.5 * scale),
              ),
            ),
            SizedBox(height: 5 * scale),
            Container(
              height: 3 * scale,
              width: 40 * scale,
              decoration: BoxDecoration(
                color:
                    (isDark ? AppColors.darkTextSecondary : AppColors.deepUmber)
                        .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(1.5 * scale),
              ),
            ),
            SizedBox(height: 5 * scale),
            Container(
              height: 3 * scale,
              width: 30 * scale,
              decoration: BoxDecoration(
                color:
                    (isDark ? AppColors.darkTextSecondary : AppColors.deepUmber)
                        .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(1.5 * scale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
