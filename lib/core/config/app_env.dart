class AppEnv {
  AppEnv._();

  // 10.0.2.2: Địa chỉ đặc biệt của Android Emulator truy cập vào localhost máy tính
  // 192.168.0.104: Địa chỉ IP Wi-Fi của máy tính (dùng khi chạy trên máy thật)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String appName = 'Quiz System';

  static bool get hasValidBaseUrl => apiBaseUrl.isNotEmpty;
}
