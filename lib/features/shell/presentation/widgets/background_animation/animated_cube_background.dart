import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedCubeBackground extends StatefulWidget {
  final Color baseColor;

  const AnimatedCubeBackground({
    super.key,
    this.baseColor = const Color(0xFFF8FAFC),
  });

  @override
  State<AnimatedCubeBackground> createState() => _AnimatedCubeBackgroundState();
}

class _AnimatedCubeBackgroundState extends State<AnimatedCubeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // Speed of the light sweep
    )..repeat(); // Loops continuously
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
        return CustomPaint(
          painter: CubePatternPainter(
            animationValue: _controller.value,
            baseColor: widget.baseColor,
          ),
          child: Container(),
        );
      },
    );
  }
}

class CubePatternPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;

  CubePatternPainter({
    required this.animationValue,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double cubeSize = 35.0; // Adjust for larger/smaller cubes
    final double dx = cubeSize * math.cos(math.pi / 6);
    final double dy = cubeSize * math.sin(math.pi / 6);

    // Base colors for 3D faces
    final Paint topPaint = Paint()..style = PaintingStyle.fill;
    final Paint leftPaint = Paint()..style = PaintingStyle.fill;
    final Paint rightPaint = Paint()..style = PaintingStyle.fill;

    // Calculate how many rows and columns we need to cover the screen
    final int cols = (size.width / (2 * dx)).ceil() + 1;
    final int rows = (size.height / (3 * dy)).ceil() + 1;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        // Hexagonal staggered grid logic
        final double cx = col * 2 * dx + (row % 2 != 0 ? dx : 0);
        final double cy = row * 3 * dy;

        // Animated light wave logic (sweeps diagonally across the screen)
        final double wave = math.sin((cx + cy) * 0.005 - (animationValue * 2 * math.pi));
        // Normalize wave from [-1, 1] to [0, 1]
        final double intensity = (wave + 1) / 2; 

        // Lighten the colors based on the wave intensity to create a shimmer effect
        topPaint.color = Color.lerp(Colors.white, Colors.white.withValues(alpha: 0.4), intensity)!;
        leftPaint.color = Color.lerp(const Color(0xFFF1F5F9), const Color(0xFFE2E8F0), intensity)!;
        rightPaint.color = Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFCBD5E1), intensity)!;

        // Draw Top Face
        final Path topPath = Path()
          ..moveTo(cx, cy)
          ..lineTo(cx + dx, cy - dy)
          ..lineTo(cx, cy - 2 * dy)
          ..lineTo(cx - dx, cy - dy)
          ..close();
        canvas.drawPath(topPath, topPaint);

        // Draw Left Face
        final Path leftPath = Path()
          ..moveTo(cx, cy)
          ..lineTo(cx - dx, cy - dy)
          ..lineTo(cx - dx, cy + dy)
          ..lineTo(cx, cy + 2 * dy)
          ..close();
        canvas.drawPath(leftPath, leftPaint);

        // Draw Right Face
        final Path rightPath = Path()
          ..moveTo(cx, cy)
          ..lineTo(cx + dx, cy - dy)
          ..lineTo(cx + dx, cy + dy)
          ..lineTo(cx, cy + 2 * dy)
          ..close();
        canvas.drawPath(rightPath, rightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CubePatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}