// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Document Vault BD';

  @override
  String get home => 'Home';

  @override
  String get documents => 'Documents';

  @override
  String get scan => 'Scan';

  @override
  String get reminders => 'Reminders';

  @override
  String get more => 'More';

  @override
  String get getStarted => 'Get Started';

  @override
  String get unlockVault => 'Unlock Document Vault';
}
