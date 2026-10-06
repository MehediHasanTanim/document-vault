import 'package:drift/drift.dart' show Value;

import '../../../core/database/repositories.dart';
import '../../../core/database/vault_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/uuid/uuid_generator.dart';
import 'local_notification_gateway.dart';
import 'reminder_models.dart';

/// Coordinates Drift reminder rows with platform-local notifications. It never
/// sends a document number, encrypted value, or vault content to the OS.
class ReminderScheduler {
  ReminderScheduler(
    this._repository,
    this._notifications,
    this._uuid, {
    DateTime Function()? clock,
    this.maximumScheduledNotifications = 64,
  }) : _clock = clock ?? DateTime.now;

  final ReminderRepository _repository;
  final LocalNotificationGateway _notifications;
  final UuidGenerator _uuid;
  final DateTime Function() _clock;
  final int maximumScheduledNotifications;

  Future<List<String>> configure({
    required ReminderDocument document,
    required ReminderSetup setup,
  }) async {
    setup.validate();
    if (document.expiryDate == null) {
      throw const ValidationFailure(
        'An expiry date is needed before setting expiry reminders.',
      );
    }
    await _cancelForDocument(document.id);
    final ids = <String>[];
    final permission = await _notifications.permission();
    if (permission == LocalNotificationPermission.granted) {
      final pending = await _notifications.pendingCount();
      if (pending + setup.rules.length > maximumScheduledNotifications) {
        throw const NotificationSchedulingFailure(
          'The device notification limit would be exceeded.',
        );
      }
    }
    for (final rule in setup.rules) {
      final id = _uuid.v4();
      final scheduledAt = rule.scheduleFor(
        document.expiryDate!,
        hour: setup.hour,
        minute: setup.minute,
      );
      final notificationId = _notificationId(id);
      final now = _clock().toUtc();
      await _repository.save(
        RemindersCompanion.insert(
          id: id,
          documentId: document.id,
          reminderType: Value(rule.databaseType),
          targetDate: _dateOnlyUtc(document.expiryDate!),
          offsetDays: Value(rule.days),
          scheduledAt: scheduledAt.toUtc(),
          status: const Value('scheduled'),
          notificationId: Value(notificationId),
          createdAt: now,
          updatedAt: now,
        ),
      );
      if (permission == LocalNotificationPermission.granted &&
          scheduledAt.isAfter(_clock())) {
        await _notifications.schedule(
          notificationId: notificationId,
          at: scheduledAt,
          content: notificationContent(document.title, document.expiryDate!),
        );
      }
      ids.add(id);
    }
    return ids;
  }

  /// Call after an expiry-date or reminder-rule edit; old platform alarms are
  /// cancelled before replacement rows and schedules are created.
  Future<List<String>> reschedule({
    required ReminderDocument document,
    required ReminderSetup setup,
  }) => configure(document: document, setup: setup);

  Future<void> cancel(String reminderId) async {
    final reminder = await _repository.getById(reminderId);
    if (reminder == null) return;
    if (reminder.notificationId != null) {
      await _notifications.cancel(reminder.notificationId!);
    }
    await _repository.update(
      RemindersCompanion(
        id: Value(reminder.id),
        status: const Value('cancelled'),
        notificationId: const Value(null),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  Future<void> complete(String reminderId) async {
    final reminder = await _repository.getById(reminderId);
    if (reminder == null) return;
    if (reminder.notificationId != null) {
      await _notifications.cancel(reminder.notificationId!);
    }
    await _repository.update(
      RemindersCompanion(
        id: Value(reminder.id),
        status: const Value('completed'),
        notificationId: const Value(null),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  Future<void> snooze({
    required String reminderId,
    required Duration duration,
    required ReminderDocument document,
  }) async {
    if (duration <= Duration.zero) {
      throw const ValidationFailure('Choose a future snooze time.');
    }
    final reminder = await _repository.getById(reminderId);
    if (reminder == null) {
      throw const ValidationFailure('Reminder was not found.');
    }
    if (reminder.notificationId != null) {
      await _notifications.cancel(reminder.notificationId!);
    }
    final scheduledAt = _clock().add(duration);
    final notificationId =
        reminder.notificationId ?? _notificationId(reminder.id);
    final permission = await _notifications.permission();
    if (permission == LocalNotificationPermission.granted) {
      await _notifications.schedule(
        notificationId: notificationId,
        at: scheduledAt,
        content: notificationContent(document.title, document.expiryDate),
      );
    }
    await _repository.update(
      RemindersCompanion(
        id: Value(reminder.id),
        scheduledAt: Value(scheduledAt.toUtc()),
        status: const Value('snoozed'),
        notificationId: Value(notificationId),
        snoozedUntil: Value(scheduledAt.toUtc()),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  /// Replays future schedules after unlock/startup, restore, permission change,
  /// app upgrade, timezone change, or device reboot where the OS drops alarms.
  Future<void> reconcile(Iterable<ReminderDocument> documents) async {
    final byDocument = {
      for (final document in documents) document.id: document,
    };
    final permission = await _notifications.permission();
    for (final reminder in await _repository.listAll()) {
      if (reminder.status != 'scheduled' && reminder.status != 'snoozed') {
        continue;
      }
      final document = byDocument[reminder.documentId];
      if (document == null || document.expiryDate == null) {
        await cancel(reminder.id);
        continue;
      }
      if (permission != LocalNotificationPermission.granted ||
          !reminder.scheduledAt.toLocal().isAfter(_clock())) {
        continue;
      }
      final notificationId =
          reminder.notificationId ?? _notificationId(reminder.id);
      await _notifications.schedule(
        notificationId: notificationId,
        at: reminder.scheduledAt.toLocal(),
        content: notificationContent(document.title, document.expiryDate),
      );
      if (reminder.notificationId == null) {
        await _repository.update(
          RemindersCompanion(
            id: Value(reminder.id),
            notificationId: Value(notificationId),
            updatedAt: Value(_clock().toUtc()),
          ),
        );
      }
    }
  }

  Future<List<ReminderDashboardItem>> dashboard() async {
    final now = _clock();
    final result = <ReminderDashboardItem>[];
    for (final reminder in await _repository.listAll()) {
      if (reminder.status != 'scheduled' && reminder.status != 'snoozed') {
        continue;
      }
      final date = reminder.scheduledAt.toLocal();
      result.add(
        ReminderDashboardItem(
          reminderId: reminder.id,
          documentId: reminder.documentId,
          scheduledAt: date,
          section: _section(date, now),
        ),
      );
    }
    result.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result;
  }

  Future<void> _cancelForDocument(String documentId) async {
    for (final reminder in await _repository.listForDocument(documentId)) {
      if (reminder.status == 'scheduled' || reminder.status == 'snoozed') {
        await cancel(reminder.id);
      }
    }
  }

  PrivateNotificationContent notificationContent(
    String title,
    DateTime? expiryDate,
  ) {
    final days = expiryDate == null
        ? null
        : ExpiryEngine().daysUntil(expiryDate, _clock());
    final body = days == null
        ? 'Reminder due today'
        : days < 0
        ? 'Expired ${-days} days ago'
        : days == 0
        ? 'Expires today'
        : 'Expires in $days days';
    return PrivateNotificationContent(
      title: '$title renewal reminder',
      body: body,
    );
  }

  static ReminderDashboardSection _section(DateTime scheduledAt, DateTime now) {
    final days = _dateOnly(scheduledAt).difference(_dateOnly(now)).inDays;
    if (days < 0) return ReminderDashboardSection.overdue;
    if (days <= 7) return ReminderDashboardSection.next7Days;
    if (days <= 30) return ReminderDashboardSection.next30Days;
    if (days <= 90) return ReminderDashboardSection.next90Days;
    return ReminderDashboardSection.later;
  }

  static int _notificationId(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  static DateTime _dateOnlyUtc(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);
  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
