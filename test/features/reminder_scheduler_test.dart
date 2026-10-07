import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/uuid/uuid_generator.dart';
import 'package:documentvault/features/reminders/application/local_notification_gateway.dart';
import 'package:documentvault/features/reminders/application/reminder_models.dart';
import 'package:documentvault/features/reminders/application/reminder_scheduler.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 6, 8);

  test('derives lifecycle states from date-only values across local timezone changes', () {
    const engine = ExpiryEngine();
    expect(
      engine.state(expiryDate: null, now: now),
      DocumentLifecycleState.noExpiry,
    );
    expect(
      engine.state(expiryDate: now.add(const Duration(days: 31)), now: now),
      DocumentLifecycleState.valid,
    );
    expect(
      engine.state(expiryDate: now.add(const Duration(days: 30)), now: now),
      DocumentLifecycleState.expiringSoon,
    );
    expect(
      engine.state(expiryDate: now.subtract(const Duration(days: 1)), now: now),
      DocumentLifecycleState.expired,
    );
    expect(
      engine.state(expiryDate: now, now: now, renewalInProgress: true),
      DocumentLifecycleState.renewalInProgress,
    );
    expect(
      engine.daysUntil(
        DateTime.utc(2026, 10, 7),
        DateTime(2026, 10, 6, 23, 59),
      ),
      1,
    );
  });

  test(
    'schedules privacy-safe default reminders and persists notification ids',
    () async {
      final repository = _ReminderRepository();
      final notifications = _Notifications();
      final scheduler = ReminderScheduler(
        repository,
        notifications,
        _Ids(),
        clock: () => now,
      );
      final ids = await scheduler.configure(
        document: _document(),
        setup: const ReminderSetup(
          rules: [ReminderRule.daysBefore(30), ReminderRule.onDate()],
        ),
      );
      expect(ids, hasLength(2));
      expect(notifications.scheduled, hasLength(2));
      expect(notifications.contents.first.title, 'Passport renewal reminder');
      expect(notifications.contents.first.body, 'Expires in 30 days');
      expect(notifications.contents.first.title, isNot(contains('AB123456')));
      expect(
        (await repository.listAll()).every(
          (value) => value.notificationId != null,
        ),
        isTrue,
      );
    },
  );

  test('keeps reminder setup when permission is denied and schedules after reconciliation', () async {
    final repository = _ReminderRepository();
    final notifications = _Notifications(
      permissionValue: LocalNotificationPermission.denied,
    );
    final scheduler = ReminderScheduler(
      repository,
      notifications,
      _Ids(),
      clock: () => now,
    );
    await scheduler.configure(
      document: _document(),
      setup: const ReminderSetup(rules: [ReminderRule.daysBefore(30)]),
    );
    expect(notifications.scheduled, isEmpty);
    notifications.permissionValue = LocalNotificationPermission.granted;
    await scheduler.reconcile([_document()]);
    expect(notifications.scheduled, hasLength(1));
  });

  test('retains reminder rows when an OS schedule attempt fails and retries on reconciliation', () async {
    final repository = _ReminderRepository();
    final notifications = _Notifications(scheduleError: StateError('OS quota'));
    final scheduler = ReminderScheduler(
      repository,
      notifications,
      _Ids(),
      clock: () => now,
    );
    await expectLater(
      scheduler.configure(
        document: _document(),
        setup: const ReminderSetup(rules: [ReminderRule.daysBefore(30)]),
      ),
      throwsStateError,
    );
    expect(await repository.listAll(), hasLength(1));
    notifications.scheduleError = null;
    await scheduler.reconcile([_document()]);
    expect(notifications.scheduled, hasLength(1));
  });

  test('enforces scheduling limits, snoozes, completes and reconciles after app restart', () async {
    final repository = _ReminderRepository();
    final notifications = _Notifications(pending: 64);
    final scheduler = ReminderScheduler(
      repository,
      notifications,
      _Ids(),
      clock: () => now,
      maximumScheduledNotifications: 64,
    );
    await expectLater(
      scheduler.configure(
        document: _document(),
        setup: const ReminderSetup(rules: [ReminderRule.daysBefore(1)]),
      ),
      throwsA(isA<NotificationSchedulingFailure>()),
    );
    notifications.pending = 0;
    final id = (await scheduler.configure(
      document: _document(),
      setup: const ReminderSetup(rules: [ReminderRule.daysBefore(30)]),
    )).single;
    await scheduler.snooze(
      reminderId: id,
      duration: const Duration(days: 2),
      document: _document(),
    );
    expect((await repository.getById(id))!.status, 'snoozed');
    expect(notifications.cancelled, isNotEmpty);
    final restarted = ReminderScheduler(
      repository,
      notifications,
      _Ids(),
      clock: () => now,
    );
    await restarted.reconcile([_document()]);
    expect(notifications.scheduled.length, greaterThanOrEqualTo(2));
    await restarted.complete(id);
    expect((await repository.getById(id))!.status, 'completed');
  });

  test(
    'groups reminder dashboard into overdue and future date windows',
    () async {
      final repository = _ReminderRepository();
      repository.rows['old'] = _row(
        'old',
        now.subtract(const Duration(days: 1)),
      );
      repository.rows['week'] = _row('week', now.add(const Duration(days: 7)));
      repository.rows['month'] = _row(
        'month',
        now.add(const Duration(days: 30)),
      );
      repository.rows['later'] = _row(
        'later',
        now.add(const Duration(days: 91)),
      );
      final scheduler = ReminderScheduler(
        repository,
        _Notifications(),
        _Ids(),
        clock: () => now,
      );
      final values = await scheduler.dashboard();
      expect(values.map((value) => value.section), [
        ReminderDashboardSection.overdue,
        ReminderDashboardSection.next7Days,
        ReminderDashboardSection.next30Days,
        ReminderDashboardSection.later,
      ]);
    },
  );
}

ReminderDocument _document() => ReminderDocument(
  id: 'document',
  title: 'Passport',
  expiryDate: DateTime(2026, 11, 5),
);
Reminder _row(String id, DateTime schedule) => Reminder(
  id: id,
  documentId: 'document',
  reminderType: 'expiry',
  targetDate: DateTime(2026, 11, 5),
  scheduledAt: schedule.toUtc(),
  status: 'scheduled',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

class _Ids implements UuidGenerator {
  var value = 0;
  @override
  String v4() =>
      '00000000-0000-4000-8000-${(++value).toString().padLeft(12, '0')}';
}

class _Notifications implements LocalNotificationGateway {
  _Notifications({
    this.permissionValue = LocalNotificationPermission.granted,
    this.pending = 0,
    this.scheduleError,
  });
  LocalNotificationPermission permissionValue;
  int pending;
  Object? scheduleError;
  final scheduled = <int>[];
  final cancelled = <int>[];
  final contents = <PrivateNotificationContent>[];
  @override
  Future<void> cancel(int notificationId) async =>
      cancelled.add(notificationId);
  @override
  Future<void> openSettings() async {}
  @override
  Future<int> pendingCount() async => pending;
  @override
  Future<LocalNotificationPermission> permission() async => permissionValue;
  @override
  Future<LocalNotificationPermission> requestPermission() async =>
      permissionValue;
  @override
  Future<void> schedule({
    required int notificationId,
    required DateTime at,
    required PrivateNotificationContent content,
  }) async {
    if (scheduleError != null) throw scheduleError!;
    scheduled.add(notificationId);
    contents.add(content);
  }
}

class _ReminderRepository implements ReminderRepository {
  final rows = <String, Reminder>{};
  @override
  Future<void> delete(String id) async => rows.remove(id);
  @override
  Future<Reminder?> getById(String id) async => rows[id];
  @override
  Future<List<Reminder>> listAll() async => rows.values.toList();
  @override
  Future<List<Reminder>> listForDocument(String documentId) async =>
      rows.values.where((value) => value.documentId == documentId).toList();
  @override
  Future<void> save(RemindersCompanion value) async {
    final existing = value.id.present ? rows[value.id.value] : null;
    if (existing == null) {
      rows[value.id.value] = Reminder(
        id: value.id.value,
        documentId: value.documentId.value,
        reminderType: value.reminderType.value,
        targetDate: value.targetDate.value,
        offsetDays: value.offsetDays.present ? value.offsetDays.value : null,
        scheduledAt: value.scheduledAt.value,
        status: value.status.value,
        notificationId: value.notificationId.present
            ? value.notificationId.value
            : null,
        snoozedUntil: value.snoozedUntil.present
            ? value.snoozedUntil.value
            : null,
        createdAt: value.createdAt.value,
        updatedAt: value.updatedAt.value,
      );
      return;
    }
    rows[existing.id] = Reminder(
      id: existing.id,
      documentId: value.documentId.present
          ? value.documentId.value
          : existing.documentId,
      reminderType: value.reminderType.present
          ? value.reminderType.value
          : existing.reminderType,
      targetDate: value.targetDate.present
          ? value.targetDate.value
          : existing.targetDate,
      offsetDays: value.offsetDays.present
          ? value.offsetDays.value
          : existing.offsetDays,
      scheduledAt: value.scheduledAt.present
          ? value.scheduledAt.value
          : existing.scheduledAt,
      status: value.status.present ? value.status.value : existing.status,
      notificationId: value.notificationId.present
          ? value.notificationId.value
          : existing.notificationId,
      snoozedUntil: value.snoozedUntil.present
          ? value.snoozedUntil.value
          : existing.snoozedUntil,
      createdAt: value.createdAt.present
          ? value.createdAt.value
          : existing.createdAt,
      updatedAt: value.updatedAt.present
          ? value.updatedAt.value
          : existing.updatedAt,
    );
  }

  @override
  Future<void> update(RemindersCompanion reminder) => save(reminder);

  @override
  Future<void> updateStatus(String id, String status, DateTime updatedAt) =>
      save(
        RemindersCompanion(
          id: Value(id),
          status: Value(status),
          updatedAt: Value(updatedAt),
        ),
      );
  @override
  Stream<List<Reminder>> watchScheduled() => Stream.value(
    rows.values.where((value) => value.status == 'scheduled').toList(),
  );
}
