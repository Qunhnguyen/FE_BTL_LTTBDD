import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/student/notifications/repositories/notification_repository.dart';

final pushNotificationServiceProvider =
    Provider((ref) => PushNotificationService(ref));

class PushNotificationService {
  PushNotificationService(this._ref);

  final Ref _ref;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void>? _initializeFuture;
  String? _cachedToken;

  Future<void> initialize() async {
    if (!_supportsPushNotifications || Firebase.apps.isEmpty) {
      return;
    }

    await (_initializeFuture ??= _initializeInternal());
  }

  Future<void> _initializeInternal() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'Thong bao quan trong',
      description: 'Kenh hien thi push notification quan trong.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _cacheToken(
      await _fcm.getToken(),
      source: 'initial load',
    );

    FirebaseMessaging.onMessage.listen(_showLocalNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

    _fcm.onTokenRefresh.listen((token) async {
      await _cacheToken(token, source: 'token refresh');
      if (_shouldRegisterCurrentDevice()) {
        await registerDevice();
      }
    });
  }

  Future<String?> getToken({bool forceRefresh = false}) async {
    await initialize();

    if (!forceRefresh && _cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }

    final token = await _fcm.getToken();
    await _cacheToken(
      token,
      source: forceRefresh ? 'manual refresh' : 'manual request',
    );
    return token;
  }

  Future<void> registerDevice() async {
    if (!_shouldRegisterCurrentDevice()) {
      return;
    }

    final token = await getToken();
    if (token == null) {
      return;
    }

    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    var deviceId = 'unknown';
    var deviceName = 'unknown';

    try {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      deviceName = androidInfo.model;
    } catch (_) {
      // Keep the default values on non-Android devices.
    }

    await _ref.read(notificationRepositoryProvider).registerDevice(
          token: token,
          deviceId: deviceId,
          deviceName: deviceName,
          appVersion: packageInfo.version,
        );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Thong bao quan trong',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    // Navigation can be added here when the payload structure is finalized.
  }

  Future<void> _cacheToken(String? token, {required String source}) async {
    if (token == null || token.isEmpty) {
      debugPrint('Khong lay duoc FCM token ($source).');
      return;
    }

    _cachedToken = token;
    debugPrint('FCM token ($source): $token');
  }

  bool get _supportsPushNotifications {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool _shouldRegisterCurrentDevice() {
    final authState = _ref.read(authProvider);
    return authState.status == AuthStatus.authenticated &&
        authState.user?.role == 'STUDENT';
  }
}
