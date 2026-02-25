import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/config/constants.dart';

/// Jar Widget
/// A beautiful glass jar visualization with pull interaction
class JarWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isEmpty;

  const JarWidget({
    super.key,
    this.onTap,
    this.isEmpty = false,
  });

  @override
  State<JarWidget> createState() => _JarWidgetState();
}

class _JarWidgetState extends State<JarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.95 : 1.0)
          ..rotateZ(_isPressed ? 0.02 : 0),
        child: SizedBox(
          width: AppConstants.jarWidth,
          height: AppConstants.jarHeight,
          child: CustomPaint(
            painter: _JarPainter(
              isEmpty: widget.isEmpty,
              ripple: _controller.value,
            ),
          ),
        ),
      ).animate().then(delay: 100.ms).fade(duration: 400.ms),
    );
  }
}

class _JarPainter extends CustomPainter {
  final bool isEmpty;
  final double ripple;

  _JarPainter({
    required this.isEmpty,
    required this.ripple,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Jar body - glass effect
    final jarPaint = Paint()
      ..color = AppColors.sageGreen.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final jarStrokePaint = Paint()
      ..color = AppColors.sageGreen.withOpacity(0.6)
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
      ..color = AppColors.sageGreen.withOpacity(0.2)
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
      ..color = AppColors.glassWhite.withOpacity(0.3)
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

    // Ripple effect on tap
    if (ripple > 0) {
      final ripplePaint = Paint()
        ..color = AppColors.sageGreen.withOpacity(0.3 * (1 - ripple))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        center,
        size.width * 0.5 * ripple,
        ripplePaint,
      );
    }
  }

  void _drawPaperSlips(Canvas canvas, Offset center, Size size) {
    final slipPaint = Paint()
      ..color = AppColors.cream
      ..style = PaintingStyle.fill;

    final slipStrokePaint = Paint()
      ..color = AppColors.glassBorder.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw a few paper slips
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
    return oldDelegate.isEmpty != isEmpty || oldDelegate.ripple != ripple;
  }
}
