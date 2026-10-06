import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocaleStorage {
  String? readLanguageCode();
  Future<void> writeLanguageCode(String languageCode);
}

final localeStorageProvider = Provider<LocaleStorage>(
  (ref) => const InMemoryLocaleStorage(),
);
final localeControllerProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  static const _supportedCodes = {'en', 'bn'};
  @override
  Locale build() {
    final code = ref.read(localeStorageProvider).readLanguageCode();
    return Locale(_supportedCodes.contains(code) ? code! : 'en');
  }

  Future<void> setLocale(Locale locale) async {
    if (!_supportedCodes.contains(locale.languageCode)) return;
    state = Locale(locale.languageCode);
    await ref
        .read(localeStorageProvider)
        .writeLanguageCode(locale.languageCode);
  }
}

class SharedPreferencesLocaleStorage implements LocaleStorage {
  const SharedPreferencesLocaleStorage(this._preferences);
  static const _key = 'preferred_language_code';
  final SharedPreferences _preferences;
  @override
  String? readLanguageCode() => _preferences.getString(_key);
  @override
  Future<void> writeLanguageCode(String value) =>
      _preferences.setString(_key, value);
}

class InMemoryLocaleStorage implements LocaleStorage {
  const InMemoryLocaleStorage([this._languageCode]);
  final String? _languageCode;
  @override
  String? readLanguageCode() => _languageCode;
  @override
  Future<void> writeLanguageCode(String value) async {}
}
