/// One leave type and how much of it the employee has left.
class LeaveBucket {
  final String code;
  final String label;
  final double entitled;
  final double used;
  final double pending;

  const LeaveBucket({
    required this.code,
    required this.label,
    required this.entitled,
    required this.used,
    this.pending = 0,
  });

  double get remaining => (entitled - used - pending).clamp(0, entitled).toDouble();

  /// 0..1 — share of the entitlement already consumed or locked by an approval.
  double get consumedRatio =>
      entitled == 0 ? 0 : ((used + pending) / entitled).clamp(0, 1).toDouble();
}

class LeaveBalance {
  final String employeeName;
  final String employeeCode;
  final DateTime asOf;
  final List<LeaveBucket> buckets;

  const LeaveBalance({
    required this.employeeName,
    required this.employeeCode,
    required this.asOf,
    required this.buckets,
  });

  double get totalRemaining =>
      buckets.fold(0, (sum, bucket) => sum + bucket.remaining);
}
