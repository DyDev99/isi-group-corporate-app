import 'package:flutter_test/flutter_test.dart';
import 'package:isi_group_corporate_app/core/security/biometric/identity_verification_cache.dart';

void main() {
  // A controllable clock: the grace window must be tested by moving time, not
  // by sleeping, or the suite gets slow and flaky.
  late DateTime now;
  IdentityVerificationCache build({Duration? window}) =>
      IdentityVerificationCache(
        graceWindow: window ?? const Duration(seconds: 60),
        clock: () => now,
      );

  setUp(() => now = DateTime.utc(2026, 7, 28, 9, 0, 0));

  group('the grace window', () {
    test('is closed before anyone verifies', () {
      expect(build().isValidFor('user_001'), isFalse);
    });

    test('opens on a successful check', () {
      final cache = build()..recordSuccess('user_001');
      expect(cache.isValidFor('user_001'), isTrue);
    });

    test('is still open just before it elapses', () {
      final cache = build()..recordSuccess('user_001');
      now = now.add(const Duration(seconds: 59));
      expect(cache.isValidFor('user_001'), isTrue);
    });

    test('is closed exactly at the boundary', () {
      final cache = build()..recordSuccess('user_001');
      now = now.add(const Duration(seconds: 60));
      expect(cache.isValidFor('user_001'), isFalse);
    });

    test('is closed well after', () {
      final cache = build()..recordSuccess('user_001');
      now = now.add(const Duration(minutes: 5));
      expect(cache.isValidFor('user_001'), isFalse);
    });

    test('is NOT extended by repeatedly checking it', () {
      // It expires 60s after the verification, not 60s after the last read —
      // otherwise a user browsing continuously would never be re-checked.
      final cache = build()..recordSuccess('user_001');

      for (var i = 1; i <= 5; i++) {
        now = now.add(const Duration(seconds: 11));
        cache.isValidFor('user_001');
      }

      // 55s of polling: still open.
      expect(cache.isValidFor('user_001'), isTrue);
      now = now.add(const Duration(seconds: 6)); // 61s total
      expect(cache.isValidFor('user_001'), isFalse);
    });

    test('a fresh check restarts the window', () {
      final cache = build()..recordSuccess('user_001');
      now = now.add(const Duration(seconds: 59));

      cache.recordSuccess('user_001');
      now = now.add(const Duration(seconds: 59));

      expect(cache.isValidFor('user_001'), isTrue);
    });

    test('honours a custom duration', () {
      final cache = build(window: const Duration(seconds: 50))
        ..recordSuccess('user_001');
      now = now.add(const Duration(seconds: 49));
      expect(cache.isValidFor('user_001'), isTrue);
      now = now.add(const Duration(seconds: 2));
      expect(cache.isValidFor('user_001'), isFalse);
    });
  });

  group('SECURITY: the window is bound to one identity', () {
    test('another user cannot ride on someone else\'s verification', () {
      final cache = build()..recordSuccess('user_001');

      expect(cache.isValidFor('user_001'), isTrue);
      // Account switch on a shared device — must re-verify.
      expect(cache.isValidFor('user_002'), isFalse);
    });

    test('logging out and back in as someone else closes the window', () {
      final cache = build()..recordSuccess('user_001');
      // A logout clears the session; the next user is a different id, so the
      // window is dead without needing an explicit invalidation call.
      expect(cache.isValidFor('user_002'), isFalse);
    });

    test('invalidate closes it immediately', () {
      final cache = build()..recordSuccess('user_001');
      expect(cache.isValidFor('user_001'), isTrue);

      cache.invalidate();

      expect(cache.isValidFor('user_001'), isFalse);
    });

    test('a new instance starts closed — the window never survives a restart',
        () {
      // The cache is in-memory only and deliberately never persisted, so a
      // fresh process (app killed and reopened) always re-verifies.
      build().recordSuccess('user_001');
      expect(build().isValidFor('user_001'), isFalse);
    });

    test('defaults to 60 seconds', () {
      expect(
        IdentityVerificationCache().graceWindow,
        const Duration(seconds: 60),
      );
    });
  });
}
