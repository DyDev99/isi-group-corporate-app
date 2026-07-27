import 'package:flutter/material.dart';

import '../../domain/entities/employee.dart';

/// Every colour, radius and duration the directory uses. The original screen
/// repeated ~60 inline hex literals across three classes; they all resolve
/// here now.
class DirColors {
  const DirColors._();

  static const Color canvas = Color(0xFFF4F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color hairline = Color(0xFFE2E8F0);
  static const Color connector = Color(0xFFCBD5E1);

  static const Color ink = Color(0xFF0F172A);
  static const Color inkBody = Color(0xFF334155);
  static const Color inkMuted = Color(0xFF64748B);
  static const Color inkFaint = Color(0xFF94A3B8);

  static const Color brand = Color(0xFF2563EB);
  static const Color brandDeep = Color(0xFF1D4ED8);
  static const Color brandWash = Color(0xFFEFF6FF);

  static const Color online = Color(0xFF10B981);
  static const Color away = Color(0xFFF59E0B);
  static const Color offline = Color(0xFFCBD5E1);
  static const Color danger = Color(0xFFEF4444);

  /// Department accents, indexed by `Department.accent`.
  static const List<Color> accents = [
    Color(0xFF4F46E5),
    Color(0xFF2563EB),
    Color(0xFFD97706),
    Color(0xFFE11D48),
    Color(0xFF7C3AED),
    Color(0xFF0D9488),
  ];

  static Color accent(int index) => accents[index % accents.length];

  static Color presence(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.online:
        return online;
      case PresenceStatus.away:
        return away;
      case PresenceStatus.offline:
        return offline;
    }
  }
}

class DirRadius {
  const DirRadius._();

  static const double chip = 20;
  static const double card = 22;
  static const double sheet = 30;
}

class DirMotion {
  const DirMotion._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 460);

  /// Used for anything that moves in the chart — nodes settle rather than snap.
  static const Curve settle = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutBack;
}

class DirShadows {
  const DirShadows._();

  static List<BoxShadow> soft() => [
        BoxShadow(
          color: DirColors.ink.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> lifted() => [
        BoxShadow(
          color: DirColors.ink.withValues(alpha: 0.10),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> focus(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.26),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
      ];
}
