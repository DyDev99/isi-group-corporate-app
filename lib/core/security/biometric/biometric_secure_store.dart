import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isi_group_corporate_app/core/error/exceptions.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_settings.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';

/// Persists [BiometricSettings] in hardware-backed secure storage.
///
/// `flutter_secure_storage` only — never `SharedPreferences`, Hive, SQLite or
/// Drift (`SECURITY.md` §3, `ARCHITECTURE.md` §3 Layer 3). The preference is
/// small and arguably non-secret, but it is a *security control*: an attacker
/// who can flip `biometricEnabled` or `biometricRegistered` in a plaintext
/// store can change how the app authenticates. Keystore/Keychain makes that
/// tamper require device compromise rather than a file edit.
///
/// Five keys, matching [BiometricSettings] exactly. Nothing else is ever
/// written here, and no biometric material can be — the OS never hands it out.
abstract interface class BiometricSecureStore {
  Future<BiometricSettings> read();
  Future<void> write(BiometricSettings settings);

  /// Wipes registration entirely. Used on account deletion / device unbinding,
  /// **not** on logout — see [BiometricSettings.clearedForLogout].
  Future<void> clear();
}

class BiometricSecureStoreImpl implements BiometricSecureStore {
  const BiometricSecureStoreImpl(this._storage);

  final FlutterSecureStorage _storage;

  // Namespaced so these can never collide with the auth token keys living in
  // the same Keychain/Keystore container.
  static const String _kEnabled = 'isi.biometric.enabled';
  static const String _kTypes = 'isi.biometric.type';
  static const String _kRegistered = 'isi.biometric.registered';
  static const String _kLastVerifiedAt = 'isi.biometric.last_verified_at';
  static const String _kPreference = 'isi.biometric.auth_preference';

  @override
  Future<BiometricSettings> read() async {
    try {
      final enabled = await _storage.read(key: _kEnabled);
      final types = await _storage.read(key: _kTypes);
      final registered = await _storage.read(key: _kRegistered);
      final verifiedAt = await _storage.read(key: _kLastVerifiedAt);
      final preference = await _storage.read(key: _kPreference);

      return BiometricSettings(
        biometricEnabled: enabled == 'true',
        biometricType: _decodeModalities(types),
        biometricRegistered: registered == 'true',
        lastVerifiedAt: _decodeTimestamp(verifiedAt),
        authenticationPreference:
            AuthenticationPreference.fromStorageKey(preference),
      );
    } catch (e) {
      // Fail closed. An unreadable store must resolve to "biometrics off" so
      // the user always lands on the credential form, never on a lock they
      // cannot clear.
      throw CacheException(message: 'biometric_settings_read_failed: $e');
    }
  }

  @override
  Future<void> write(BiometricSettings settings) async {
    try {
      await _storage.write(
        key: _kEnabled,
        value: settings.biometricEnabled.toString(),
      );
      await _storage.write(
        key: _kTypes,
        value: settings.biometricType.map((m) => m.storageKey).join(','),
      );
      await _storage.write(
        key: _kRegistered,
        value: settings.biometricRegistered.toString(),
      );
      await _storage.write(
        key: _kLastVerifiedAt,
        value: settings.lastVerifiedAt?.toUtc().toIso8601String() ?? '',
      );
      await _storage.write(
        key: _kPreference,
        value: settings.authenticationPreference.storageKey,
      );
    } catch (e) {
      throw CacheException(message: 'biometric_settings_write_failed: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await Future.wait([
        _storage.delete(key: _kEnabled),
        _storage.delete(key: _kTypes),
        _storage.delete(key: _kRegistered),
        _storage.delete(key: _kLastVerifiedAt),
        _storage.delete(key: _kPreference),
      ]);
    } catch (e) {
      throw CacheException(message: 'biometric_settings_clear_failed: $e');
    }
  }

  /// Decodes by stable name, not ordinal — reordering [BiometricModality]
  /// must never silently re-map a user's stored preference. Unknown tokens
  /// (e.g. a modality removed in a later release) are dropped.
  Set<BiometricModality> _decodeModalities(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    return raw
        .split(',')
        .map((token) => BiometricModality.fromStorageKey(token.trim()))
        .whereType<BiometricModality>()
        .toSet();
  }

  DateTime? _decodeTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
