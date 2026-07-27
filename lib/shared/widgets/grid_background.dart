import 'package:flutter/material.dart';

/// The app's grid paper backdrop, first drawn inline in `main_shell.dart`.
///
/// Promoted to `shared/widgets/` so any feature can sit on the same surface
/// without importing another feature's file — a cross-feature widget import
/// would break the boundary in ENGINEERING_STANDARD §3.
class GridBackground extends StatelessWidget {
  /// Flat colour painted under the grid.
  final Color background;

  /// Colour of the rules. Keep it low-contrast; this is texture, not content.
  final Color line;

  /// Distance between rules, in logical pixels.
  final double cell;

  final double strokeWidth;

  /// Shifts the pattern. Pass a chart or canvas translation here and the grid
  /// tracks panning instead of sitting still behind moving content.
  final Offset offset;

  const GridBackground({
    super.key,
    this.background = const Color(0xFFF6F8FA),
    this.line = const Color(0x99E2E8F0),
    this.cell = 24,
    this.strokeWidth = 1,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GridPainter(
          background: background,
          line: line,
          cell: cell,
          strokeWidth: strokeWidth,
          offset: offset,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color background;
  final Color line;
  final double cell;
  final double strokeWidth;
  final Offset offset;

  const _GridPainter({
    required this.background,
    required this.line,
    required this.cell,
    required this.strokeWidth,
    required this.offset,
  });

  /// Wraps the offset into [0, cell) so the pattern tiles seamlessly however
  /// far the content has been dragged, in either direction.
  double _phase(double value) => ((value % cell) + cell) % cell;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(background, BlendMode.srcOver);

    final paint = Paint()
      ..color = line
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (var x = _phase(offset.dx); x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = _phase(offset.dy); y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.line != line ||
      oldDelegate.cell != cell ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.offset != offset;
}
