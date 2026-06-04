import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const AnimatedBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    final random = Random();
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      _particles.add(_FloatingParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1.5 + random.nextDouble() * 2.5,
        speed: 0.2 + random.nextDouble() * 0.5,
        opacity: 0.1 + random.nextDouble() * 0.25,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? _darkGradientColors(_controller.value)
                  : _lightGradientColors(_controller.value),
            ),
          ),
          child: Stack(
            children: [
              ..._buildParticles(),
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }

  List<Widget> _buildParticles() {
    final progress = _controller.value;
    return _particles.map((p) {
      final x = (p.x + progress * p.speed * 0.02) % 1.0;
      final y = (p.y + progress * p.speed * 0.015) % 1.0;
      return Positioned(
        left: x * MediaQuery.of(context).size.width,
        top: y * MediaQuery.of(context).size.height,
        child: Opacity(
          opacity: p.opacity,
          child: Container(
            width: p.size,
            height: p.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? AppColors.midnightPeriwinkle
                  : AppColors.terracotta,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Color> _lightGradientColors(double t) {
    final smooth = (sin(t * 2 * pi) + 1) / 2;
    return [
      Color.lerp(
        AppColors.cream,
        AppColors.softSand,
        smooth * 0.3,
      )!,
      Color.lerp(
        AppColors.cream.withValues(alpha: 0.95),
        AppColors.softSand.withValues(alpha: 0.95),
        smooth * 0.2,
      )!,
    ];
  }

  List<Color> _darkGradientColors(double t) {
    final smooth = (sin(t * 2 * pi) + 1) / 2;
    return [
      Color.lerp(
        AppColors.midnightBlue,
        AppColors.midnightSlate,
        smooth * 0.4,
      )!,
      Color.lerp(
        AppColors.darkSurface,
        AppColors.midnightBlue,
        smooth * 0.3,
      )!,
    ];
  }
}

class _FloatingParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
