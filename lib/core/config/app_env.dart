class AppEnv {
  AppEnv._();

  // 10.0.2.2 là IP đặc biệt để Android Emulator truy cập localhost của máy tính
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String appName = 'Quiz System';

  static bool get hasValidBaseUrl => apiBaseUrl.isNotEmpty;
}

