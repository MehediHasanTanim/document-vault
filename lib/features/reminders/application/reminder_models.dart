import '../../../core/errors/app_failure.dart';

enum DocumentLifecycleState {
  valid,
  expiringSoon,
  expired,
  noExpiry,
  renewalInProgress,
}

class ExpiryEngine {
  const ExpiryEngine({this.expiringSoonDays = 30});
  final int expiringSoonDays;

  DocumentLifecycleState state({
    required DateTime? expiryDate,
    required DateTime now,
    bool renewalInProgress = false,
  }) {
    if (renewalInProgress) return DocumentLifecycleState.renewalInProgress;
    if (expiryDate == null) return DocumentLifecycleState.noExpiry;
    final today = _dateOnly(now);
    final expiry = _dateOnly(expiryDate);
    if (expiry.isBefore(today)) return DocumentLifecycleState.expired;
    if (!expiry.isAfter(today.add(Duration(days: expiringSoonDays)))) {
      return DocumentLifecycleState.expiringSoon;
    }
    return DocumentLifecycleState.valid;
  }

  int? daysUntil(DateTime? expiryDate, DateTime now) => expiryDate == null
      ? null
      : _dateOnly(expiryDate).difference(_dateOnly(now)).inDays;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

enum ReminderRuleKind { daysBefore, onDate, customDate }

class ReminderRule {
  const ReminderRule.daysBefore(this.days)
    : kind = ReminderRuleKind.daysBefore,
      customDate = null;
  const ReminderRule.onDate()
    : kind = ReminderRuleKind.onDate,
      days = 0,
      customDate = null;
  const ReminderRule.custom(this.customDate)
    : kind = ReminderRuleKind.customDate,
      days = null;

  final ReminderRuleKind kind;
  final int? days;
  final DateTime? customDate;

  static const defaults = <ReminderRule>[
    ReminderRule.daysBefore(90),
    ReminderRule.daysBefore(60),
    ReminderRule.daysBefore(30),
    ReminderRule.daysBefore(14),
    ReminderRule.daysBefore(7),
    ReminderRule.daysBefore(3),
    ReminderRule.daysBefore(1),
    ReminderRule.onDate(),
  ];

  DateTime scheduleFor(
    DateTime targetDate, {
    required int hour,
    required int minute,
  }) {
    final date = switch (kind) {
      ReminderRuleKind.daysBefore => targetDate.subtract(Duration(days: days!)),
      ReminderRuleKind.onDate => targetDate,
      ReminderRuleKind.customDate => customDate!,
    };
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String get databaseType => switch (kind) {
    ReminderRuleKind.daysBefore => 'expiry',
    ReminderRuleKind.onDate => 'on_date',
    ReminderRuleKind.customDate => 'custom',
  };
}

class ReminderSetup {
  const ReminderSetup({required this.rules, this.hour = 9, this.minute = 0});
  final List<ReminderRule> rules;
  final int hour;
  final int minute;

  void validate() {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw const ValidationFailure('Choose a valid reminder time.');
    }
    if (rules.isEmpty) {
      throw const ValidationFailure('Choose at least one reminder.');
    }
    if (rules.any(
      (rule) =>
          rule.kind == ReminderRuleKind.daysBefore &&
          (rule.days == null || rule.days! < 0),
    )) {
      throw const ValidationFailure('Choose a valid reminder offset.');
    }
    if (rules.any(
      (rule) =>
          rule.kind == ReminderRuleKind.customDate && rule.customDate == null,
    )) {
      throw const ValidationFailure('Choose a custom reminder date.');
    }
  }
}

enum LocalNotificationPermission {
  notDetermined,
  granted,
  denied,
  permanentlyDenied,
}

class PrivateNotificationContent {
  const PrivateNotificationContent({required this.title, required this.body});
  final String title;
  final String body;
}

class ReminderDocument {
  const ReminderDocument({
    required this.id,
    required this.title,
    required this.expiryDate,
    this.renewalInProgress = false,
  });
  final String id;
  final String title;
  final DateTime? expiryDate;
  final bool renewalInProgress;
}

enum ReminderDashboardSection {
  overdue,
  next7Days,
  next30Days,
  next90Days,
  later,
}

class ReminderDashboardItem {
  const ReminderDashboardItem({
    required this.reminderId,
    required this.documentId,
    required this.scheduledAt,
    required this.section,
  });
  final String reminderId;
  final String documentId;
  final DateTime scheduledAt;
  final ReminderDashboardSection section;
}
