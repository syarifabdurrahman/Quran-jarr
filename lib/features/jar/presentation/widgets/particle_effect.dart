import 'dart:math';
import 'package:flutter/material.dart';

/// Particle Effect Widget
/// Shows animated particles when jar is tapped
class ParticleEffect extends StatefulWidget {
  final Color color;
  final int particleCount;

  const ParticleEffect({
    super.key,
    this.color = const Color(0xFFD4A373),
    this.particleCount = 20,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _generateParticles();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateParticles() {
    final random = Random();
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        startX: 0,
        startY: 0,
        endX: (random.nextDouble() - 0.5) * 200,
        endY: -random.nextDouble() * 150 - 50,
        size: random.nextDouble() * 6 + 2,
        color: widget.color.withValues(alpha: random.nextDouble() * 0.5 + 0.5),
        delay: random.nextDouble() * 0.3,
        rotation: random.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

/// Particle data class
class Particle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final Color color;
  final double delay;
  final double rotation;

  Particle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.color,
    required this.delay,
    required this.rotation,
  });
}

/// Particle Painter
class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height;

    for (final particle in particles) {
      final adjustedProgress =
          ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);

      if (adjustedProgress <= 0) continue;

      final x =
          centerX +
          particle.startX +
          (particle.endX - particle.startX) * adjustedProgress;
      final y =
          centerY +
          particle.startY +
          (particle.endY - particle.startY) * adjustedProgress;

      final opacity = 1.0 - adjustedProgress;
      final currentSize = particle.size * (1 - adjustedProgress * 0.5);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Draw rotated square (like paper pieces)
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + adjustedProgress * 2);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: currentSize,
        height: currentSize,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
