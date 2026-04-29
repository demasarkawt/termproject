// Central API configuration for the Kurdistan Go backend.
//
// Default matches production (same as dashboard `DEFAULT_API_URL`).
// For a local FastAPI server, run with:
//
//   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
//
// Android emulator → host machine:
//   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
//
// Other deploys:
//   flutter build web --dart-define=API_BASE_URL=https://YOUR-API.up.railway.app

const String kRailwayProdUrl = 'https://termproject-production.up.railway.app';

const String kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: kRailwayProdUrl,
);
