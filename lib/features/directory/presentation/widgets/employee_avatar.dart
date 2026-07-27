import 'package:flutter/material.dart';

import '../../domain/entities/employee.dart';
import '../theme/directory_tokens.dart';

/// Draws a person's photo from [Employee.imageUrl] when present, and their
/// initials on a department-tinted gradient otherwise.
///
/// Network loads degrade gracefully: while the image is fetching, the initials
/// show; a failed fetch (offline, dead URL, TLS handshake refused) stays on the
/// initials via [Image.network]'s errorBuilder, so nothing throws and no red
/// box appears. Behind an HTTPS-inspecting proxy the fetch only succeeds with
/// the debug TLS override in main.dart.
class EmployeeAvatar extends StatelessWidget {
  final Employee employee;
  final Color accent;
  final double size;
  final double radius;
  final bool showPresence;

  const EmployeeAvatar({
    super.key,
    required this.employee,
    required this.accent,
    this.size = 44,
    this.radius = 14,
    this.showPresence = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(radius);

    if (!employee.hasImage) return _initials(border);

    return ClipRRect(
      borderRadius: border,
      child: Image.network(
        employee.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        // Any failure — offline, 404, refused handshake — shows initials.
        errorBuilder: (_, __, ___) => _initials(border),
        // Show initials until the first frame decodes, then cross-fade in.
        frameBuilder: (context, child, frame, wasSyncLoaded) {
          if (wasSyncLoaded) return child;
          return AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            crossFadeState: frame == null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _initials(border),
            secondChild: SizedBox(width: size, height: size, child: child),
          );
        },
      ),
    );
  }

  Widget _initials(BorderRadius border) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withValues(alpha: 0.6)],
        ),
        borderRadius: border,
      ),
      alignment: Alignment.center,
      child: Text(
        employee.initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
