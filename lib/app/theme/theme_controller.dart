import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { system, light, dark }

abstract interface class ThemeStorage {
  String? readTheme();
  Future<void> writeTheme(String value);
}

final themeStorageProvider = Provider<ThemeStorage>(
  (ref) => const InMemoryThemeStorage(),
);
final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => _fromStored(ref.read(themeStorageProvider).readTheme());

  Future<void> setPreference(AppThemePreference preference) async {
    state = _toThemeMode(preference);
    await ref.read(themeStorageProvider).writeTheme(preference.name);
  }

  static ThemeMode _fromStored(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
  static ThemeMode _toThemeMode(AppThemePreference preference) =>
      switch (preference) {
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.system => ThemeMode.system,
      };
}

class SharedPreferencesThemeStorage implements ThemeStorage {
  const SharedPreferencesThemeStorage(this._preferences);
  static const _key = 'preferred_theme';
  final SharedPreferences _preferences;
  @override
  String? readTheme() => _preferences.getString(_key);
  @override
  Future<void> writeTheme(String value) => _preferences.setString(_key, value);
}

class InMemoryThemeStorage implements ThemeStorage {
  const InMemoryThemeStorage([this._value]);
  final String? _value;
  @override
  String? readTheme() => _value;
  @override
  Future<void> writeTheme(String value) async {}
}
