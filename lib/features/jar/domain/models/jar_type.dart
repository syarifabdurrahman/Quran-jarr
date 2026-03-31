import 'package:flutter/material.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';

/// Jar Type enum
enum JarType {
  classic,
  vintage,
  modern,
  ornate;

  String get displayName {
    switch (this) {
      case JarType.classic:
        return 'Classic';
      case JarType.vintage:
        return 'Vintage';
      case JarType.modern:
        return 'Modern';
      case JarType.ornate:
        return 'Ornate';
    }
  }

  String get description {
    switch (this) {
      case JarType.classic:
        return 'Traditional glass jar';
      case JarType.vintage:
        return 'Elegant vintage design';
      case JarType.modern:
        return 'Sleek modern style';
      case JarType.ornate:
        return 'Decorative ornate jar';
    }
  }
}

/// Jar Painter Factory
class JarPainterFactory {
  static CustomPainter create({
    required JarType type,
    required bool isEmpty,
    required bool isDark,
  }) {
    final jarColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final lidColor = isDark ? AppColors.midnightGold : AppColors.terracotta;
    final paperColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    switch (type) {
      case JarType.classic:
        return ClassicJarPainter(
          isEmpty: isEmpty,
          jarColor: jarColor,
          lidColor: lidColor,
          paperColor: paperColor,
        );
      case JarType.vintage:
        return VintageJarPainter(
          isEmpty: isEmpty,
          jarColor: jarColor,
          lidColor: lidColor,
          paperColor: paperColor,
        );
      case JarType.modern:
        return ModernJarPainter(
          isEmpty: isEmpty,
          jarColor: jarColor,
          lidColor: lidColor,
          paperColor: paperColor,
        );
      case JarType.ornate:
        return OrnateJarPainter(
          isEmpty: isEmpty,
          jarColor: jarColor,
          lidColor: lidColor,
          paperColor: paperColor,
        );
    }
  }
}

/// Classic Jar Painter (original design)
class ClassicJarPainter extends CustomPainter {
  final bool isEmpty;
  final Color jarColor;
  final Color lidColor;
  final Color paperColor;

  ClassicJarPainter({
    required this.isEmpty,
    required this.jarColor,
    required this.lidColor,
    required this.paperColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Jar body
    final jarPath = Path();
    jarPath.moveTo(size.width * 0.2, size.height * 0.25);
    jarPath.lineTo(size.width * 0.15, size.height * 0.85);
    jarPath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.95,
      size.width * 0.25,
      size.height * 0.95,
    );
    jarPath.lineTo(size.width * 0.75, size.height * 0.95);
    jarPath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.95,
      size.width * 0.85,
      size.height * 0.85,
    );
    jarPath.lineTo(size.width * 0.8, size.height * 0.25);
    jarPath.close();

    paint.color = jarColor;
    canvas.drawPath(jarPath, paint);

    // Lid
    final lidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = lidColor;

    final lidPath = Path();
    lidPath.moveTo(size.width * 0.15, size.height * 0.25);
    lidPath.lineTo(size.width * 0.85, size.height * 0.25);
    lidPath.lineTo(size.width * 0.82, size.height * 0.15);
    lidPath.lineTo(size.width * 0.18, size.height * 0.15);
    lidPath.close();

    canvas.drawPath(lidPath, lidPaint);

    // Papers inside (if not empty)
    if (!isEmpty) {
      final paperPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = paperColor.withValues(alpha: 0.3);

      for (int i = 0; i < 3; i++) {
        final paperPath = Path();
        paperPath.moveTo(size.width * (0.3 + i * 0.1), size.height * 0.5);
        paperPath.lineTo(size.width * (0.35 + i * 0.1), size.height * 0.85);
        paperPath.lineTo(size.width * (0.4 + i * 0.1), size.height * 0.85);
        paperPath.lineTo(size.width * (0.35 + i * 0.1), size.height * 0.5);
        paperPath.close();

        canvas.drawPath(paperPath, paperPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ClassicJarPainter oldDelegate) {
    return oldDelegate.isEmpty != isEmpty;
  }
}

/// Vintage Jar Painter
class VintageJarPainter extends CustomPainter {
  final bool isEmpty;
  final Color jarColor;
  final Color lidColor;
  final Color paperColor;

  VintageJarPainter({
    required this.isEmpty,
    required this.jarColor,
    required this.lidColor,
    required this.paperColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Jar body (more rounded, vintage shape)
    final jarPath = Path();
    jarPath.moveTo(size.width * 0.25, size.height * 0.3);
    jarPath.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.5,
      size.width * 0.2,
      size.height * 0.9,
    );
    jarPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.0,
      size.width * 0.8,
      size.height * 0.9,
    );
    jarPath.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.5,
      size.width * 0.75,
      size.height * 0.3,
    );
    jarPath.close();

    paint.color = jarColor;
    canvas.drawPath(jarPath, paint);

    // Decorative band
    final bandPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = lidColor.withValues(alpha: 0.5);

    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.6),
      Offset(size.width * 0.78, size.height * 0.6),
      bandPaint,
    );

    // Cork lid
    final lidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = lidColor;

    final lidPath = Path();
    lidPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.3,
          size.height * 0.1,
          size.width * 0.4,
          size.height * 0.2,
        ),
        const Radius.circular(8),
      ),
    );

    canvas.drawPath(lidPath, lidPaint);

    // Papers
    if (!isEmpty) {
      final paperPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = paperColor.withValues(alpha: 0.25);

      for (int i = 0; i < 4; i++) {
        canvas.save();
        canvas.translate(size.width * (0.35 + i * 0.08), size.height * 0.7);
        canvas.rotate(0.2 - i * 0.1);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width * 0.06, size.height * 0.2),
          paperPaint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant VintageJarPainter oldDelegate) {
    return oldDelegate.isEmpty != isEmpty;
  }
}

/// Modern Jar Painter
class ModernJarPainter extends CustomPainter {
  final bool isEmpty;
  final Color jarColor;
  final Color lidColor;
  final Color paperColor;

  ModernJarPainter({
    required this.isEmpty,
    required this.jarColor,
    required this.lidColor,
    required this.paperColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Jar body (clean geometric shape)
    final jarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.25,
        size.width * 0.6,
        size.height * 0.7,
      ),
      const Radius.circular(16),
    );

    paint.color = jarColor;
    canvas.drawRRect(jarRect, paint);

    // Minimalist lid
    final lidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = lidColor.withValues(alpha: 0.8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.35,
          size.height * 0.1,
          size.width * 0.3,
          size.height * 0.18,
        ),
        const Radius.circular(12),
      ),
      lidPaint,
    );

    // Glass reflection effect
    final reflectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = jarColor.withValues(alpha: 0.3);

    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.3, size.height * 0.85),
      reflectionPaint,
    );

    // Papers
    if (!isEmpty) {
      final paperPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = paperColor.withValues(alpha: 0.2);

      for (int i = 0; i < 3; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * (0.3 + i * 0.12),
              size.height * 0.5,
              size.width * 0.08,
              size.height * 0.35,
            ),
            const Radius.circular(4),
          ),
          paperPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ModernJarPainter oldDelegate) {
    return oldDelegate.isEmpty != isEmpty;
  }
}

/// Ornate Jar Painter
class OrnateJarPainter extends CustomPainter {
  final bool isEmpty;
  final Color jarColor;
  final Color lidColor;
  final Color paperColor;

  OrnateJarPainter({
    required this.isEmpty,
    required this.jarColor,
    required this.lidColor,
    required this.paperColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Jar body (decorative shape)
    final jarPath = Path();
    jarPath.moveTo(size.width * 0.3, size.height * 0.3);
    jarPath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.4,
      size.width * 0.2,
      size.height * 0.6,
    );
    jarPath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.85,
      size.width * 0.5,
      size.height * 0.95,
    );
    jarPath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.85,
      size.width * 0.8,
      size.height * 0.6,
    );
    jarPath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.4,
      size.width * 0.7,
      size.height * 0.3,
    );
    jarPath.close();

    paint.color = jarColor;
    canvas.drawPath(jarPath, paint);

    // Decorative patterns
    final decorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = lidColor.withValues(alpha: 0.6);

    // Top decoration
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.35),
        width: size.width * 0.3,
        height: size.height * 0.1,
      ),
      0,
      3.14,
      false,
      decorPaint,
    );

    // Bottom decoration
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.85),
        width: size.width * 0.4,
        height: size.height * 0.08,
      ),
      3.14,
      3.14,
      false,
      decorPaint,
    );

    // Ornate lid
    final lidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = lidColor;

    // Lid base
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.15,
        size.width * 0.5,
        size.height * 0.15,
      ),
      lidPaint,
    );

    // Lid knob
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.1),
      size.width * 0.08,
      lidPaint,
    );

    // Papers
    if (!isEmpty) {
      final paperPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = paperColor.withValues(alpha: 0.25);

      for (int i = 0; i < 5; i++) {
        canvas.save();
        canvas.translate(size.width * (0.3 + i * 0.07), size.height * 0.55);
        canvas.rotate(0.3 - i * 0.15);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width * 0.05, size.height * 0.3),
          paperPaint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant OrnateJarPainter oldDelegate) {
    return oldDelegate.isEmpty != isEmpty;
  }
}
