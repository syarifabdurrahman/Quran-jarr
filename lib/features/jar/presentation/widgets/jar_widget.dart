import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/config/constants.dart';

/// Jar Widget
/// A beautiful glass jar visualization with pull interaction
/// Features shake animation and paper slip coming out effect
class JarWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isEmpty;
  final bool isAnimating;

  const JarWidget({
    super.key,
    this.onTap,
    this.isEmpty = false,
    this.isAnimating = false,
  });

  @override
  State<JarWidget> createState() => _JarWidgetState();
}

class _JarWidgetState extends State<JarWidget> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _paperController;
  bool _isPressed = false;
  bool _showPaperSlip = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ), // Longer shake for ritual feel
    );
    _paperController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slower paper slip
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _paperController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_showPaperSlip) return; // Prevent double tap

    setState(() => _showPaperSlip = true);

    // Shake animation (left-right-left) - smoother with longer duration
    await _shakeController.forward();

    // Paper slip comes out - slower, more dramatic
    await _paperController.forward();

    // Ritual moment - pause before closing
    await Future.delayed(const Duration(milliseconds: 800));

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
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            // Create smoother, more ritualistic shake effect
            double rotation = 0;
            if (_shakeController.value > 0) {
              // Use easing curve for more natural movement
              final t = _shakeController.value;

              // Multi-phase shake with decreasing amplitude
              if (t < 0.2) {
                // Initial gentle tilt
                rotation = Curves.easeInOut.transform(t / 0.2) * 0.12;
              } else if (t < 0.4) {
                // Return to center
                rotation =
                    0.12 - Curves.easeInOut.transform((t - 0.2) / 0.2) * 0.12;
              } else if (t < 0.6) {
                // Tilt to other side
                rotation = -Curves.easeInOut.transform((t - 0.4) / 0.2) * 0.12;
              } else if (t < 0.8) {
                // Return with slight overshoot
                rotation =
                    -0.12 +
                    Curves.easeOutBack.transform((t - 0.6) / 0.2) * 0.14;
              } else {
                // Settle with micro-movements
                final settleT = (t - 0.8) / 0.2;
                rotation =
                    0.02 *
                    Curves.easeOut.transform(1 - settleT) *
                    (settleT * 3 % 2 == 0 ? 1 : -1);
              }
            }
            return Transform.rotate(angle: rotation, child: child);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive jar scale based on screen width
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
                    // Jar (centered with offset)
                    Positioned(
                      left: 30 * jarScale,
                      top: 40 * jarScale,
                      child: AnimatedScale(
                        scale: _isPressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        child: SizedBox(
                          width: jarWidth,
                          height: jarHeight,
                          child: CustomPaint(
                            painter: _JarPainter(isEmpty: widget.isEmpty),
                          ),
                        ),
                      ).animate().then(delay: 100.ms).fade(duration: 400.ms),
                    ),

                    // Paper slip that comes out - smoother, more ritualistic
                    if (_showPaperSlip)
                      Positioned(
                        left: jarWidth / 2 + 5 * jarScale,
                        top: 90 * jarScale,
                        child: AnimatedBuilder(
                          animation: _paperController,
                          builder: (context, child) {
                            final value = _paperController.value;

                            // Multi-phase paper slip animation
                            double translateY;
                            double rotation;
                            double opacity;

                            if (value < 0.3) {
                              // Phase 1: Slow start (anticipation)
                              translateY =
                                  Curves.easeIn.transform(value / 0.3) *
                                  40 *
                                  jarScale;
                              rotation = -0.15;
                              opacity = Curves.easeIn.transform(value / 0.3);
                            } else if (value < 0.7) {
                              // Phase 2: Main slide out (more dramatic)
                              final t = (value - 0.3) / 0.4;
                              translateY =
                                  40 * jarScale +
                                  Curves.easeOutCubic.transform(t) *
                                      100 *
                                      jarScale;
                              rotation = -0.15 + (t * 0.12);
                              opacity = 1.0;
                            } else {
                              // Phase 3: Settle with slight bounce
                              final t = ((value - 0.7) / 0.3).clamp(0.0, 1.0);
                              translateY =
                                  140 * jarScale +
                                  Curves.easeOutCubic.transform(t) *
                                      20 *
                                      jarScale;
                              rotation = -0.03 + (t * 0.05);
                              opacity = 1.0;
                            }

                            return Transform.translate(
                              offset: Offset(0, -translateY),
                              child: Transform.rotate(
                                angle: rotation,
                                child: Opacity(opacity: opacity, child: child),
                              ),
                            );
                          },
                          child: _PaperSlipWidget(scale: jarScale),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Paper Slip Widget
/// Shows a paper slip coming out of the jar
class _PaperSlipWidget extends StatelessWidget {
  final double scale;

  const _PaperSlipWidget({this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55 * scale,
      height: 75 * scale,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepUmber.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(3, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Arabic text lines
            Container(
              height: 3 * scale,
              width: 35 * scale,
              decoration: BoxDecoration(
                color: AppColors.deepUmber.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(1.5 * scale),
              ),
            ),
            SizedBox(height: 5 * scale),
            Container(
              height: 3 * scale,
              width: 40 * scale,
              decoration: BoxDecoration(
                color: AppColors.deepUmber.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(1.5 * scale),
              ),
            ),
            SizedBox(height: 5 * scale),
            Container(
              height: 3 * scale,
              width: 28 * scale,
              decoration: BoxDecoration(
                color: AppColors.deepUmber.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(1.5 * scale),
              ),
            ),
            SizedBox(height: 8 * scale),
            // Translation lines
            Container(
              height: 2.5 * scale,
              width: 42 * scale,
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(1 * scale),
              ),
            ),
            SizedBox(height: 4 * scale),
            Container(
              height: 2.5 * scale,
              width: 36 * scale,
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(1 * scale),
              ),
            ),
            SizedBox(height: 4 * scale),
            Container(
              height: 2.5 * scale,
              width: 30 * scale,
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(1 * scale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JarPainter extends CustomPainter {
  final bool isEmpty;

  _JarPainter({required this.isEmpty});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Jar body - glass effect
    final jarPaint = Paint()
      ..color = AppColors.sageGreen.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final jarStrokePaint = Paint()
      ..color = AppColors.sageGreen.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw jar body
    final jarRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.7,
        height: size.height * 0.7,
      ),
      const Radius.circular(20),
    );

    canvas.drawRRect(jarRect, jarPaint);
    canvas.drawRRect(jarRect, jarStrokePaint);

    // Jar neck
    final neckPaint = Paint()
      ..color = AppColors.sageGreen.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final neckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size.height * 0.35),
        width: size.width * 0.4,
        height: size.height * 0.15,
      ),
      const Radius.circular(10),
    );

    canvas.drawRRect(neckRect, neckPaint);
    canvas.drawRRect(neckRect, jarStrokePaint);

    // Jar lid
    final lidPaint = Paint()
      ..color = AppColors.terracotta
      ..style = PaintingStyle.fill;

    final lidRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size.height * 0.45),
        width: size.width * 0.5,
        height: size.height * 0.08,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(lidRect, lidPaint);

    // Glass shine effect
    final shinePaint = Paint()
      ..color = AppColors.glassWhite.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final shinePath = Path()
      ..moveTo(center.dx + size.width * 0.2, center.dy - size.height * 0.2)
      ..lineTo(center.dx + size.width * 0.25, center.dy + size.height * 0.1)
      ..lineTo(center.dx + size.width * 0.15, center.dy + size.height * 0.15)
      ..lineTo(center.dx + size.width * 0.1, center.dy - size.height * 0.15)
      ..close();

    canvas.drawPath(shinePath, shinePaint);

    // Paper slips inside (if not empty)
    if (!isEmpty) {
      _drawPaperSlips(canvas, center, size);
    }
  }

  void _drawPaperSlips(Canvas canvas, Offset center, Size size) {
    final slipPaint = Paint()
      ..color = AppColors.cream
      ..style = PaintingStyle.fill;

    final slipStrokePaint = Paint()
      ..color = AppColors.glassBorder.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw a few paper slips inside the jar
    for (int i = 0; i < 3; i++) {
      final slipY = center.dy - size.height * 0.1 + (i * 15.0);
      final slipX = center.dx - size.width * 0.15 + (i * 5.0);

      final slipRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(slipX, slipY),
          width: size.width * 0.25,
          height: size.height * 0.25,
        ),
        const Radius.circular(4),
      );

      canvas.drawRRect(slipRect, slipPaint);
      canvas.drawRRect(slipRect, slipStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JarPainter oldDelegate) {
    return oldDelegate.isEmpty != isEmpty;
  }
}
