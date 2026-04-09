/// Central API configuration.
/// Update [kBaseUrl] to point at your deployed backend.

// The Railway endpoint is currently timing out, so you likely need to run the backend locally.
// Uncomment the line that matches your currently running emulator:

// For Android Emulator (uses 10.0.2.2 to refer to the host laptop's localhost):
const String kBaseUrl = 'http://10.0.2.2:8000';

// For iOS Simulator or Web:
// const String kBaseUrl = 'http://127.0.0.1:8000';

// Original Production URL (currently not responding):
// const String kBaseUrl = 'https://termproject-production.up.railway.app';
