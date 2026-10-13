class AppConstants {
  static const String appName = 'Smart1';
  static const String appVersion = '1.0.0';

  // WebSocket
  static const int wsPort = 81;
  static const int otaPort = 8266;

  // Storage Keys
  static const String keyDevices = 'smart1_devices';
  static const String keyAuth = 'smart1_auth';
  static const String keyTheme = 'smart1_theme';

  // Default Admin
  static const String defaultAdmin = 'admin';
  static const String defaultPass = '123456';

  // Timeouts
  static const Duration wsConnectTimeout = Duration(seconds: 8);
  static const Duration wsReconnectDelay = Duration(seconds: 3);
  static const Duration deviceTimeout = Duration(seconds: 15);

  // Relay count
  static const int relayCount = 6;
  static const int maxDevices = 20;
}