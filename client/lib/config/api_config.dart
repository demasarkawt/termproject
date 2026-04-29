// Central API configuration for the Kurdistan Go backend.
//
// The Flutter app talks to **FastAPI only**; the database is on the server (e.g. Railway).
//
// **Explicit override (all platforms):**
// ```sh
// flutter run --dart-define=API_BASE_URL=https://YOUR-SERVICE.up.railway.app
// flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
// ```
//
// **Defaults:**
// - **Web** (no dart-define): uses `<meta name="kurdistan-api-base">` in `web/index.html`,
//   then Railway. This avoids `flutter run -d chrome` in **debug** still posting to
//   `127.0.0.1:8000` when the API is only on Railway.
// - **Mobile — release / profile:** Railway URL below.
// - **Mobile — debug:** `http://127.0.0.1:8000` for a local Uvicorn instance.

import 'package:flutter/foundation.dart' show kIsWeb, kProfileMode, kReleaseMode;

import 'api_base_resolve_stub.dart'
    if (dart.library.html) 'api_base_resolve_web.dart';

const String _fromDefine = String.fromEnvironment('API_BASE_URL');

/// Match `dashboard` default — change if your Railway hostname differs.
const String kRailwayProductionUrl = 'https://termproject-production.up.railway.app';

/// Backend origin — **no trailing slash**. Use for all HTTP API calls.
String get kBaseUrl {
  final explicit = _fromDefine.trim();
  if (explicit.isNotEmpty) {
    return explicit.replaceAll(RegExp(r'/+$'), '');
  }
  if (kIsWeb) {
    return resolveApiBaseForWeb();
  }
  if (kReleaseMode || kProfileMode) {
    return kRailwayProductionUrl;
  }
  return 'http://127.0.0.1:8000';
}
