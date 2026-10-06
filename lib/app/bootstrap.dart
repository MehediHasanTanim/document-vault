import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'localization/locale_controller.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        localeStorageProvider.overrideWithValue(
          SharedPreferencesLocaleStorage(preferences),
        ),
      ],
      child: const DocumentVaultApp(),
    ),
  );
}
