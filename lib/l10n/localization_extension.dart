import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Short, null-safe access to the generated ARB localization contract.
/// Widgets must resolve visible copy at build time so a language change is
/// reflected immediately and no bilingual fallback literal is needed.
extension LocalizationBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
