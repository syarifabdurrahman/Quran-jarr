import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/dhikr/presentation/providers/dhikr_provider.dart';

class DhikrScreen extends ConsumerStatefulWidget {
  const DhikrScreen({super.key});

  @override
  ConsumerState<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends ConsumerState<DhikrScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    ref.read(dhikrProvider.notifier).increment();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dhikrProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.midnightPeriwinkle : AppColors.sageGreen;
    final accentColor = isDark ? AppColors.midnightGold : AppColors.terracotta;

    final progress = (state.count % state.target) / state.target;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background Blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  color: isDark 
                      ? AppColors.midnightBlue.withValues(alpha: 0.8) 
                      : AppColors.cream.withValues(alpha: 0.8),
                ),
              ),
            ),

            // Top Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: primaryColor, size: 30),
                  ),
                  Text(
                    state.sessionName.toUpperCase(),
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _buildSettingsDialog(context),
                      );
                    },
                    icon: Icon(Icons.settings_outlined, color: primaryColor),
                  ),
                ],
              ),
            ),

            // Center Ring & Counter
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 280 + (_pulseController.value * 20),
                        height: 280 + (_pulseController.value * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.1 * _pulseController.value),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Progress Ring
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: DhikrRingPainter(
                        progress: progress,
                        color: accentColor,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  // Counter Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.count}',
                        style: GoogleFonts.lora(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ).animate(target: state.count.toDouble()).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1),
                        duration: 100.ms,
                        curve: Curves.easeOut,
                      ).then().scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1)),
                      Text(
                        'Target: ${state.target}',
                        style: AppTextStyles.loraCaptionForTheme(context).copyWith(
                          fontSize: 16,
                          letterSpacing: 2,
                          color: primaryColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer instructions
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'Tap anywhere to count',
                    style: AppTextStyles.loraBodySmallForTheme(context).copyWith(
                      color: primaryColor.withValues(alpha: 0.4),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      ref.read(dhikrProvider.notifier).reset();
                      HapticFeedback.mediumImpact();
                    },
                    child: Text(
                      'RESET',
                      style: GoogleFonts.lora(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildSettingsDialog(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: AppColors.glassNight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Dhikr Settings', style: AppTextStyles.loraHeading().copyWith(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTargetOption(33),
            _buildTargetOption(99),
            _buildTargetOption(100),
            _buildTargetOption(1000),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetOption(int target) {
    return ListTile(
      title: Text('$target Taps', style: const TextStyle(color: Colors.white)),
      onTap: () {
        ref.read(dhikrProvider.notifier).setTarget(target);
        Navigator.pop(context);
      },
    );
  }
}

class DhikrRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  DhikrRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.1415926535 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
