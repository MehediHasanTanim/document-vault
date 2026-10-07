import 'dart:convert';

enum DateFormatPreference { dayMonthYear, monthDayYear, yearMonthDay }

enum DocumentViewPreference { list, grid, recent }

enum AutoLockPreference { immediate, seconds30, minute1, minutes5 }

enum BackupReminderPreference { off, weekly, monthly, quarterly }

class GeneralSettings {
  const GeneralSettings({
    this.languageCode = 'en',
    this.theme = 'system',
    this.dateFormat = DateFormatPreference.dayMonthYear,
    this.defaultView = DocumentViewPreference.list,
    this.defaultProfileId,
  });
  final String languageCode;
  final String theme;
  final DateFormatPreference dateFormat;
  final DocumentViewPreference defaultView;
  final String? defaultProfileId;

  Map<String, Object?> toJson() => {
    'languageCode': languageCode,
    'theme': theme,
    'dateFormat': dateFormat.name,
    'defaultView': defaultView.name,
    'defaultProfileId': defaultProfileId,
  };

  factory GeneralSettings.fromJson(Map<String, dynamic> json) =>
      GeneralSettings(
        languageCode: _language(json['languageCode'] as String?),
        theme: _theme(json['theme'] as String?),
        dateFormat: _dateFormat(json['dateFormat'] as String?),
        defaultView: _documentView(json['defaultView'] as String?),
        defaultProfileId: json['defaultProfileId'] as String?,
      );
}

class SecuritySettings {
  const SecuritySettings({
    this.biometricsEnabled = false,
    this.autoLock = AutoLockPreference.minute1,
    this.hideInAppSwitcher = true,
    this.screenshotProtection = true,
    this.hideSensitiveNotificationPreview = true,
  });
  final bool biometricsEnabled;
  final AutoLockPreference autoLock;
  final bool hideInAppSwitcher;
  final bool screenshotProtection;
  final bool hideSensitiveNotificationPreview;

  Map<String, Object> toJson() => {
    'biometricsEnabled': biometricsEnabled,
    'autoLock': autoLock.name,
    'hideInAppSwitcher': hideInAppSwitcher,
    'screenshotProtection': screenshotProtection,
    'hideSensitiveNotificationPreview': hideSensitiveNotificationPreview,
  };

  factory SecuritySettings.fromJson(Map<String, dynamic> json) =>
      SecuritySettings(
        biometricsEnabled: json['biometricsEnabled'] as bool? ?? false,
        autoLock: _autoLock(json['autoLock'] as String?),
        hideInAppSwitcher: json['hideInAppSwitcher'] as bool? ?? true,
        screenshotProtection: json['screenshotProtection'] as bool? ?? true,
        hideSensitiveNotificationPreview:
            json['hideSensitiveNotificationPreview'] as bool? ?? true,
      );
}

class NotificationSettings {
  const NotificationSettings({
    this.expiryRemindersEnabled = true,
    this.defaultOffsets = const [90, 60, 30, 14, 7, 3, 1, 0],
    this.backupReminder = BackupReminderPreference.monthly,
  });
  final bool expiryRemindersEnabled;
  final List<int> defaultOffsets;
  final BackupReminderPreference backupReminder;

  Map<String, Object> toJson() => {
    'expiryRemindersEnabled': expiryRemindersEnabled,
    'defaultOffsets': defaultOffsets,
    'backupReminder': backupReminder.name,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final offsets =
        (json['defaultOffsets'] as List<dynamic>? ?? const [])
            .whereType<num>()
            .map((value) => value.toInt())
            .where((value) => value >= 0 && value <= 3650)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
    return NotificationSettings(
      expiryRemindersEnabled: json['expiryRemindersEnabled'] as bool? ?? true,
      defaultOffsets: offsets.isEmpty
          ? const NotificationSettings().defaultOffsets
          : List.unmodifiable(offsets),
      backupReminder: _backupReminder(json['backupReminder'] as String?),
    );
  }
}

String encodeSettings(Map<String, Object?> value) => jsonEncode(value);
Map<String, dynamic> decodeSettings(String value) =>
    jsonDecode(value) as Map<String, dynamic>;

String _language(String? value) => value == 'bn' ? 'bn' : 'en';
String _theme(String? value) => switch (value) {
  'light' || 'dark' || 'system' => value!,
  _ => 'system',
};
DateFormatPreference _dateFormat(String? value) =>
    DateFormatPreference.values
        .where((item) => item.name == value)
        .firstOrNull ??
    DateFormatPreference.dayMonthYear;
DocumentViewPreference _documentView(String? value) =>
    DocumentViewPreference.values
        .where((item) => item.name == value)
        .firstOrNull ??
    DocumentViewPreference.list;
AutoLockPreference _autoLock(String? value) =>
    AutoLockPreference.values.where((item) => item.name == value).firstOrNull ??
    AutoLockPreference.minute1;
BackupReminderPreference _backupReminder(String? value) =>
    BackupReminderPreference.values
        .where((item) => item.name == value)
        .firstOrNull ??
    BackupReminderPreference.monthly;
