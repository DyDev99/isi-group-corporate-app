import 'package:flutter/material.dart';

import '../layout/org_layout.dart';
import '../theme/directory_tokens.dart';

/// Draws the reporting lines as rounded elbows and animates them in whenever
/// the tree changes shape. Highlighted edges are the branch that leads to a
/// search hit.
class ConnectorPainter extends CustomPainter {
  final List<OrgEdge> edges;
  final double progress;

  const ConnectorPainter({required this.edges, required this.progress});

  static const double _corner = 16;

  @override
  void paint(Canvas canvas, Size size) {
    if (edges.isEmpty || progress <= 0) return;

    final base = Paint()
      ..color = DirColors.connector
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final highlight = Paint()
      ..color = DirColors.brand
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final edge in edges) {
      final path = _elbow(edge);
      canvas.drawPath(
        _partial(path, progress),
        edge.highlighted ? highlight : base,
      );

      if (edge.highlighted && progress > 0.9) {
        canvas.drawCircle(
          edge.to,
          3.4,
          Paint()..color = DirColors.brand,
        );
      }
    }
  }

  Path _elbow(OrgEdge edge) {
    final path = Path();
    final midY = (edge.from.dy + edge.to.dy) / 2;
    final goingRight = edge.to.dx > edge.from.dx;
    final horizontalRun = (edge.to.dx - edge.from.dx).abs();
    final radius = horizontalRun < _corner * 2 ? horizontalRun / 2 : _corner;

    path.moveTo(edge.from.dx, edge.from.dy);

    if (radius < 1) {
      // Straight drop — single child sitting directly below its manager.
      path.lineTo(edge.to.dx, edge.to.dy);
      return path;
    }

    path
      ..lineTo(edge.from.dx, midY - radius)
      ..quadraticBezierTo(
        edge.from.dx,
        midY,
        edge.from.dx + (goingRight ? radius : -radius),
        midY,
      )
      ..lineTo(edge.to.dx + (goingRight ? -radius : radius), midY)
      ..quadraticBezierTo(
        edge.to.dx,
        midY,
        edge.to.dx,
        midY + radius,
      )
      ..lineTo(edge.to.dx, edge.to.dy);

    return path;
  }

  Path _partial(Path path, double fraction) {
    if (fraction >= 1) return path;
    final result = Path();
    for (final metric in path.computeMetrics()) {
      result.addPath(
        metric.extractPath(0, metric.length * fraction),
        Offset.zero,
      );
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant ConnectorPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.edges != edges;
}
