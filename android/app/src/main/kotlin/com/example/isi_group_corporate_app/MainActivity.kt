package com.example.isi_group_corporate_app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.hardware.biometrics.BiometricManager.Authenticators
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Extends [FlutterFragmentActivity] rather than `FlutterActivity` because
 * `local_auth` shows the Android biometric prompt via `androidx.biometric`'s
 * `BiometricPrompt`, which requires a `FragmentActivity` host. With a plain
 * `FlutterActivity` the plugin throws `no_fragment_activity` at call time.
 *
 * This also requires `LaunchTheme`/`NormalTheme` to inherit from an AppCompat
 * theme (see `res/values/styles.xml`): a `FragmentActivity` hosting an
 * AppCompat-based dialog under a plain `android:Theme.*` parent crashes with
 * "You need to use a Theme.AppCompat theme (or descendant) with this activity".
 */
class MainActivity : FlutterFragmentActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEVICE_SETTINGS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openBiometricEnrollment" -> result.success(openBiometricEnrollment())
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Sends the user to the most specific enrolment screen this OS version
     * offers, degrading gracefully:
     *
     *  - API 30+ : biometric enrolment, pre-filtered to the authenticator
     *              classes the app accepts.
     *  - API 28+ : fingerprint enrolment.
     *  - older   : general security settings, then all settings.
     *
     * Returns false rather than throwing when nothing can handle the intent,
     * so the Flutter side falls back to written instructions.
     */
    private fun openBiometricEnrollment(): Boolean {
        val candidates = buildList {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                add(
                    Intent(Settings.ACTION_BIOMETRIC_ENROLL).apply {
                        // Framework constants (API 30+), so this needs no
                        // androidx.biometric compile dependency of our own.
                        putExtra(
                            Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                            Authenticators.BIOMETRIC_STRONG or
                                Authenticators.DEVICE_CREDENTIAL,
                        )
                    },
                )
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                @Suppress("DEPRECATION")
                add(Intent(Settings.ACTION_FINGERPRINT_ENROLL))
            }
            add(Intent(Settings.ACTION_SECURITY_SETTINGS))
            add(Intent(Settings.ACTION_SETTINGS))
        }

        return candidates.any { launch(it) }
    }

    private fun launch(intent: Intent): Boolean = try {
        // resolveActivity returns null when nothing on the device handles the
        // intent — common for ACTION_FINGERPRINT_ENROLL on face-only hardware.
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
            true
        } else {
            false
        }
    } catch (_: ActivityNotFoundException) {
        false
    } catch (_: SecurityException) {
        false
    }

    private companion object {
        /** Must match `DeviceSettingsLauncherImpl._channelName`. */
        const val DEVICE_SETTINGS_CHANNEL = "isi.corporate/device_settings"
    }
}
