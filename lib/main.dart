import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isi_group_corporate_app/app.dart';
import 'package:isi_group_corporate_app/core/bootstrap/app_bootstrap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(release-gate): DEBUG ONLY. Trusts every TLS certificate so network
  // images load behind an HTTPS-inspecting antivirus/proxy on dev machines
  // (the CERTIFICATE_VERIFY_FAILED handshake error). This MUST NOT ship: it
  // disables certificate validation app-wide. kDebugMode gates it out of
  // release builds; CI greps for release-gate tags (ENGINEERING_STANDARD §11).
  if (kDebugMode) {
    HttpOverrides.global = _DevTrustAllCerts();
  }

  // All initialization lives in AppBootstrapService so the boot sequence has one
  // documented, testable home. It performs no network I/O and no navigation —
  // see that class's doc comment for why (ADR-002 §3/§5, OFFLINE_FIRST §2.2).
  await const AppBootstrapService().run();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // The app starts regardless of bootstrap outcome: SplashScreen owns the first
  // transition and a guest can always browse local data. Surfacing a hard boot
  // error screen would contradict "offline is a normal state, not an error
  // state" (ADR-002 §4).
  runApp(const ISISteelSalesApp());
}

/// Debug-only: makes Dart's HTTP stack accept self-signed / intercepted
/// certificates so `Image.network` works behind corporate TLS inspection.
/// Never enabled in release — see the kDebugMode guard in main().
class _DevTrustAllCerts extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}