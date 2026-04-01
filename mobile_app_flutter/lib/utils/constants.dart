/// API constants and configuration
class AppConstants {
  AppConstants._();

  static const String appName = 'KrushikaDhara';
  static const String tagline = 'Smart Farming Companion';

  // ─── API Base URLs ──────────────────────────────
  // 🌐 Online (Render.com) — works from anywhere, no USB needed
  static const String backendBaseUrl = 'https://krushikadhara-backend.onrender.com/api/v1';
  static const String aiServiceUrl = 'https://krushikadhara-backend.onrender.com/api/v1'; // TODO: Update when AI service is deployed separately

  // 🔌 Local development (uncomment these & comment above when testing locally)
  // static const String backendBaseUrl = 'http://10.50.7.144:5000/api/v1';
  // static const String aiServiceUrl = 'http://10.50.7.144:8000/api/v1';

  // ─── Storage Keys ──────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
