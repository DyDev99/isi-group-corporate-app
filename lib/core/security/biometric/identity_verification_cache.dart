/// A short grace window after a successful identity check, so a user moving
/// between protected screens is not re-prompted every few seconds.
///
/// ## Why this exists
///
/// Payslips, Performance and Leave are each guarded. Without a grace window,
/// opening all three in a row means three biometric prompts in thirty seconds
/// — users learn to resent the control, and a control people resent is one
/// they route around.
///
/// ## Why it is safe
///
///  * **In memory only.** Deliberately never written to secure storage or
///    anywhere else. Killing the app ends the grace, so a phone picked up
///    tomorrow proves identity again from scratch.
///  * **Bound to one user.** The grace records *who* verified. A logout clears
///    the session, so [isValidFor] stops matching and the window is dead — no
///    separate invalidation call to forget.
///  * **Short and fixed.** 60 seconds by default, and it is never extended by
///    activity; it expires 60s after the *verification*, not 60s after the
///    last tap.
///
/// This mirrors iOS's own `touchIDAuthenticationAllowableReuseDuration`, which
/// exists for exactly this reason and caps out at five minutes.
class IdentityVerificationCache {
  IdentityVerificationCache({
    this.graceWindow = const Duration(seconds: 60),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// How long a successful check stays good for. Kept short on purpose.
  final Duration graceWindow;

  /// Injectable clock — the tests must not depend on real elapsed time.
  final DateTime Function() _clock;

  String? _userId;
  DateTime? _verifiedAt;

  /// Records that [userId] proved their identity just now.
  ///
  /// Called only after a positive OS biometric match or a verified password —
  /// never on a cancel, a failure, or merely opening a guarded screen.
  void recordSuccess(String userId) {
    _userId = userId;
    _verifiedAt = _clock();
  }

  /// Whether [userId] may skip the prompt right now.
  ///
  /// False when nobody has verified, when a *different* user is signed in, or
  /// when the window has elapsed.
  bool isValidFor(String userId) {
    final verifiedAt = _verifiedAt;
    if (verifiedAt == null || _userId != userId) return false;
    return _clock().difference(verifiedAt) < graceWindow;
  }

  /// Ends the grace immediately.
  ///
  /// Not needed for logout — that changes the signed-in user, which
  /// [isValidFor] already rejects. This is for an explicit "lock now" action
  /// or a security-settings change.
  void invalidate() {
    _userId = null;
    _verifiedAt = null;
  }
}
