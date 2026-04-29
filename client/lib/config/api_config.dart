// Central API configuration for the Kurdistan Go backend.
//
// The dashboard and Flutter app share the same FastAPI backend.
//
// Default is local development. Override without editing this file:
//
//   flutter run --dart-define=API_BASE_URL=https://YOUR-RAILWAY-URL.up.railway.app
//   flutter build apk --dart-define=API_BASE_URL=https://...
//
// Android emulator → host machine localhost:
//   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

const String kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);
