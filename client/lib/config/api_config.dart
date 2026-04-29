import 'package:flutter/foundation.dart';

/// Central API configuration — the Flutter app talks to **FastAPI only**;
/// PostgreSQL lives on the server (e.g. Railway). There is no direct DB link from the app.
///
/// **Compile-time override (always wins if non-empty):**
/// ```sh
/// flutter run --dart-define=API_BASE_URL=https://YOUR-SERVICE.up.railway.app
/// flutter build apk --dart-define=API_BASE_URL=https://...
/// ```
///
/// **Default behaviour:**
/// - **Release / profile** builds → Railway URL below (same host as `dashboard` default).
/// - **Debug** builds → `http://127.0.0.1:8000` (local backend).
///
/// Android emulator → host machine:
/// ```sh
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
/// ```

const String _fromDefine = String.fromEnvironment('API_BASE_URL');

/// Match `dashboard` / `DEPLOYMENT.md` — change here if your Railway URL differs.
const String _railwayProductionUrl = 'https://termproject-production.up.railway.app';

/// Resolved backend origin — **no trailing slash**.
String get kBaseUrl {
  final d = _fromDefine.trim();
  if (d.isNotEmpty) {
    return d.replaceAll(RegExp(r'/+$'), '');
  }
  if (kReleaseMode || kProfileMode) {
    return _railwayProductionUrl;
  }
  return 'http://127.0.0.1:8000';
}
