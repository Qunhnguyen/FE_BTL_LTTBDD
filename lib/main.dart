import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/push_notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseIfNeeded();
  runApp(const ProviderScope(child: QuizApp()));
}

Future<void> _initializeFirebaseIfNeeded() async {
  if (!_supportsPushNotificationsPlatform) {
    return;
  }

  try {
    await Firebase.initializeApp();
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

bool get _supportsPushNotificationsPlatform {
  if (kIsWeb) {
    return false;
  }

  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

class QuizApp extends ConsumerStatefulWidget {
  const QuizApp({super.key});

  @override
  ConsumerState<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends ConsumerState<QuizApp> {
  late final ProviderSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription = ref.listenManual<AuthState>(
      authProvider,
      (previous, next) {
        if (next.status == AuthStatus.authenticated &&
            next.user?.role == 'STUDENT') {
          unawaited(
            ref.read(pushNotificationServiceProvider).registerDevice(),
          );
        }
      },
    );

    Future.microtask(_bootstrapPushNotifications);
  }

  Future<void> _bootstrapPushNotifications() async {
    if (!_supportsPushNotificationsPlatform) {
      return;
    }

    final pushNotificationService = ref.read(pushNotificationServiceProvider);
    await pushNotificationService.initialize();

    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated &&
        authState.user?.role == 'STUDENT') {
      await pushNotificationService.registerDevice();
    }
  }

  @override
  void dispose() {
    _authSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Quiz System',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
