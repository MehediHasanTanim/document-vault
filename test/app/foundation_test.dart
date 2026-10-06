import 'package:documentvault/app/localization/locale_controller.dart';
import 'package:documentvault/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('themes use Document Vault blue', () {
    expect(AppTheme.light.colorScheme.primary, AppColors.blue);
    expect(AppTheme.dark.colorScheme.primary, AppColors.blue);
  });
  test('locale controller switches to Bengali', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('bn'));
    expect(container.read(localeControllerProvider), const Locale('bn'));
  });
}
