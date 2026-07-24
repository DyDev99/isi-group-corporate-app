import 'package:flutter/material.dart';

/// Single source of truth for the assistant's visual language. The original
/// screen carried ~30 inline hex literals; every one of them now resolves
/// here so the palette can be themed or dark-mode'd in one place.
class HrColors {
  const HrColors._();

  // Surfaces
  static const Color canvas = Color(0xFFF6F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color hairline = Color(0xFFE2E8F0);

  // Ink
  static const Color ink = Color(0xFF0F172A);
  static const Color inkBody = Color(0xFF1E293B);
  static const Color inkMuted = Color(0xFF64748B);
  static const Color inkFaint = Color(0xFF94A3B8);

  // Brand
  static const Color brand = Color(0xFF2563EB);
  static const Color brandBright = Color(0xFF3B82F6);
  static const Color brandDeep = Color(0xFF1E3A8A);
  static const Color brandWash = Color(0xFFEFF6FF);

  // Signals
  static const Color online = Color(0xFF10B981);
  static const Color warn = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color cite = Color(0xFFFEF3C7);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandBright, brand, brandDeep],
  );

  static const LinearGradient userBubble = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, brandDeep],
  );
}

class HrRadius {
  const HrRadius._();

  static const double chip = 22;
  static const double card = 20;
  static const double bubble = 22;
  static const double sheet = 28;
}

class HrMotion {
  const HrMotion._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
}

class HrShadows {
  const HrShadows._();

  static List<BoxShadow> soft() => [
        BoxShadow(
          color: HrColors.ink.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> lifted() => [
        BoxShadow(
          color: HrColors.ink.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> brandGlow() => [
        BoxShadow(
          color: HrColors.brand.withValues(alpha: 0.28),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Icon per category — kept in presentation so the domain enum stays pure.
IconData iconForCategoryLabel(String label) {
  switch (label) {
    case 'Leave & Time':
      return Icons.event_available_rounded;
    case 'Payroll':
      return Icons.payments_rounded;
    case 'IT Support':
      return Icons.laptop_mac_rounded;
    case 'Policies':
      return Icons.gavel_rounded;
    case 'Benefits':
      return Icons.favorite_rounded;
    default:
      return Icons.apps_rounded;
  }
}
