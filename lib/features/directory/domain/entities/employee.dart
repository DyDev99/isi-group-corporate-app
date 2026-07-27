/// Pure Dart domain model — no Flutter imports (ENGINEERING_STANDARD §3).

enum PresenceStatus {
  online('Online'),
  away('Away'),
  offline('Offline');

  const PresenceStatus(this.label);

  final String label;
}

class Employee {
  final String id;
  final String name;
  final String role;
  final String companyId;
  final String departmentId;
  final String location;
  final String email;
  final String phone;
  final String? managerId;
  final PresenceStatus status;
  final DateTime joinedAt;

  /// Remote avatar URL, or null to fall back to the initials-on-gradient
  /// avatar. Loads over the network — requires connectivity, and behind an
  /// HTTPS-inspecting proxy needs the debug TLS override in main.dart. The
  /// avatar widget falls back to initials on any load failure, so a dead URL
  /// or offline device degrades gracefully rather than throwing.
  final String? imageUrl;

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.companyId,
    required this.departmentId,
    required this.location,
    required this.email,
    required this.phone,
    required this.status,
    required this.joinedAt,
    this.managerId,
    this.imageUrl,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// Matches free-text search across the fields a person would actually type.
  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return true;
    final needle = query.trim().toLowerCase();
    return name.toLowerCase().contains(needle) ||
        role.toLowerCase().contains(needle) ||
        location.toLowerCase().contains(needle) ||
        email.toLowerCase().contains(needle);
  }
}

class Company {
  final String id;
  final String name;
  final String tagline;
  final String emoji;

  const Company({
    required this.id,
    required this.name,
    required this.tagline,
    required this.emoji,
  });
}

class Department {
  final String id;
  final String name;
  final String emoji;

  /// Index into the presentation accent palette — the domain stays free of
  /// Flutter `Color`s.
  final int accent;

  const Department({
    required this.id,
    required this.name,
    required this.emoji,
    required this.accent,
  });
}