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

/// Classic Jar Painter
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
    // Glass back layer
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = jarColor.withValues(alpha: 0.1);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.4);

    final jarOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = jarColor.withValues(alpha: 0.8);

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

    canvas.drawPath(jarPath, fillPaint);

    // Papers inside (if not empty)
    if (!isEmpty) {
      final paperPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = paperColor.withValues(alpha: 0.6);

      final paperShadow = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black.withValues(alpha: 0.2);

      for (int i = 0; i < 4; i++) {
        canvas.save();
        canvas.translate(size.width * (0.3 + i * 0.12), size.height * 0.7);
        canvas.rotate(-0.1 + (i * 0.1));
        
        // Shadow
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, size.width * 0.1, size.height * 0.2), const Radius.circular(2)),
          paperShadow,
        );
        // Paper
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * 0.1, size.height * 0.2), const Radius.circular(2)),
          paperPaint,
        );
        canvas.restore();
      }
    }

    // Glass front layer
    canvas.drawPath(jarPath, fillPaint);
    canvas.drawPath(jarPath, jarOutlinePaint);

    // Glass Highlight
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.35),
      Offset(size.width * 0.18, size.height * 0.8),
      highlightPaint,
    );

    // Lid
    final lidGradient = LinearGradient(
      colors: [lidColor.withValues(alpha: 0.7), lidColor, lidColor.withValues(alpha: 0.6)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(size.width * 0.15, size.height * 0.15, size.width * 0.7, size.height * 0.1));

    final lidPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = lidGradient;

    final lidPath = Path();
    lidPath.moveTo(size.width * 0.15, size.height * 0.25);
    lidPath.lineTo(size.width * 0.85, size.height * 0.25);
    lidPath.lineTo(size.width * 0.82, size.height * 0.15);
    lidPath.lineTo(size.width * 0.18, size.height * 0.15);
    lidPath.close();

    canvas.drawPath(lidPath, lidPaint);
  }

  @override
  bool shouldRepaint(covariant ClassicJarPainter oldDelegate) => oldDelegate.isEmpty != isEmpty;
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
    // Glass base
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = jarColor.withValues(alpha: 0.08);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = jarColor.withValues(alpha: 0.9);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.25);

    // Jar body (more rounded, vintage shape)
    final jarPath = Path();
    jarPath.moveTo(size.width * 0.35, size.height * 0.3);
    jarPath.quadraticBezierTo(
      size.width * 0.05,
      size.height * 0.5,
      size.width * 0.15,
      size.height * 0.9,
    );
    jarPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.0,
      size.width * 0.85,
      size.height * 0.9,
    );
    jarPath.quadraticBezierTo(
      size.width * 0.95,
      size.height * 0.5,
      size.width * 0.65,
      size.height * 0.3,
    );
    jarPath.close();

    canvas.drawPath(jarPath, fillPaint);

    // Papers
    if (!isEmpty) {
      final paperPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = paperColor.withValues(alpha: 0.7);

      for (int i = 0; i < 5; i++) {
        canvas.save();
        canvas.translate(size.width * (0.3 + i * 0.1), size.height * 0.75);
        canvas.rotate(0.3 - i * 0.15);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * 0.08, size.height * 0.18), const Radius.circular(3)),
          paperPaint,
        );
        canvas.restore();
      }
    }

    canvas.drawPath(jarPath, fillPaint);
    canvas.drawPath(jarPath, outlinePaint);

    // Glass Highlight curved
    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.2, size.height * 0.55);
    highlightPath.quadraticBezierTo(size.width * 0.18, size.height * 0.7, size.width * 0.25, size.height * 0.85);
    canvas.drawPath(highlightPath, highlightPaint);

    // Cork lid
    final lidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = lidColor;

    final lidPath = Path();
    lidPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.15, size.width * 0.3, size.height * 0.15),
        const Radius.circular(8),
      ),
    );

    // Bottle neck
    final neckPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = jarColor.withValues(alpha: 0.6);
    
    canvas.drawRect(Rect.fromLTWH(size.width * 0.35, size.height * 0.25, size.width * 0.3, size.height * 0.05), neckPaint);
    canvas.drawPath(lidPath, lidPaint);
  }

  @override
  bool shouldRepaint(covariant VintageJarPainter oldDelegate) => oldDelegate.isEmpty != isEmpty;
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
    // Fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = jarColor.withValues(alpha: 0.05);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = jarColor;

    // Jar body (clean geometric shape)
    final jarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.25, size.width * 0.6, size.height * 0.7),
      const Radius.circular(20),
    );

    canvas.drawRRect(jarRect, fillPaint);

    // Papers
    if (!isEmpty) {
      final paperPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = paperColor.withValues(alpha: 0.8);

      for (int i = 0; i < 4; i++) {
        canvas.drawCircle(
          Offset(size.width * (0.35 + i * 0.1), size.height * 0.8),
          size.width * 0.06,
          paperPaint,
        );
      }
    }

    canvas.drawRRect(jarRect, fillPaint);
    canvas.drawRRect(jarRect, outlinePaint);

    // Glass reflection effect
    final reflectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.3);

    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.35),
      Offset(size.width * 0.28, size.height * 0.85),
      reflectionPaint,
    );

    // Minimalist lid
    final lidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = lidColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.15, size.width * 0.7, size.height * 0.1),
        const Radius.circular(6),
      ),
      lidPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ModernJarPainter oldDelegate) => oldDelegate.isEmpty != isEmpty;
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
    final jarPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = jarColor;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = jarColor.withValues(alpha: 0.12);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.3);

    // Jar body - elegant curved shape
    final jarPath = Path();
    jarPath.moveTo(size.width * 0.3, size.height * 0.3);
    jarPath.quadraticBezierTo(
      size.width * 0.0,
      size.height * 0.6,
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
      size.width * 1.0,
      size.height * 0.6,
      size.width * 0.7,
      size.height * 0.3,
    );
    jarPath.close();

    canvas.drawPath(jarPath, fillPaint);

    // Papers inside
    if (!isEmpty) {
      final paperPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = paperColor.withValues(alpha: 0.5);

      for (int i = 0; i < 5; i++) {
        canvas.save();
        canvas.translate(size.width * (0.35 + i * 0.08), size.height * 0.65);
        canvas.rotate(0.2 - i * 0.15);
        
        final starPath = Path();
        starPath.moveTo(0, size.height * 0.05);
        starPath.lineTo(size.width * 0.05, size.height * 0.15);
        starPath.lineTo(size.width * 0.15, size.height * 0.15);
        starPath.lineTo(size.width * 0.08, size.height * 0.2);
        starPath.lineTo(size.width * 0.1, size.height * 0.3);
        starPath.lineTo(0, size.height * 0.25);
        starPath.lineTo(-size.width * 0.1, size.height * 0.3);
        starPath.lineTo(-size.width * 0.08, size.height * 0.2);
        starPath.lineTo(-size.width * 0.15, size.height * 0.15);
        starPath.lineTo(-size.width * 0.05, size.height * 0.15);
        starPath.close();

        canvas.drawPath(starPath, paperPaint);
        canvas.restore();
      }
    }

    canvas.drawPath(jarPath, fillPaint);
    canvas.drawPath(jarPath, jarPaint);

    // Highlights
    final hPath = Path();
    hPath.moveTo(size.width * 0.2, size.height * 0.5);
    hPath.quadraticBezierTo(size.width * 0.15, size.height * 0.65, size.width * 0.25, size.height * 0.8);
    canvas.drawPath(hPath, highlightPaint);

    // Ornate lid
    final lidGradient = RadialGradient(
      colors: [lidColor.withValues(alpha: 0.8), lidColor],
    ).createShader(Rect.fromLTWH(size.width * 0.2, size.height * 0.1, size.width * 0.6, size.height * 0.2));

    final lidPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = lidGradient;

    final domePath = Path();
    domePath.moveTo(size.width * 0.3, size.height * 0.3);
    domePath.lineTo(size.width * 0.25, size.height * 0.2);
    domePath.quadraticBezierTo(size.width * 0.5, size.height * 0.0, size.width * 0.75, size.height * 0.2);
    domePath.lineTo(size.width * 0.7, size.height * 0.3);
    domePath.close();
    
    canvas.drawPath(domePath, lidPaint);

    // Gold rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.midnightGold;

    // Base ring
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.9), Offset(size.width * 0.75, size.height * 0.9), ringPaint);
    // Neck ring
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.3), Offset(size.width * 0.7, size.height * 0.3), ringPaint);
  }

  @override
  bool shouldRepaint(covariant OrnateJarPainter oldDelegate) => oldDelegate.isEmpty != isEmpty;
}
