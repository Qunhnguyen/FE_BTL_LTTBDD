import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const _storageKey = 'theme_mode';
  final _storage = const FlutterSecureStorage();

  Future<void> _loadTheme() async {
    final savedTheme = await _storage.read(key: _storageKey);
    if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _storage.write(key: _storageKey, value: mode.name);
  }

  void toggleTheme(bool isDark) {
    setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
