import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../application/local_notification_gateway.dart';
import '../application/reminder_models.dart';

/// Production local-only notification adapter. Payloads contain only a UUID;
/// titles/bodies are deliberately constructed by [ReminderScheduler] without
/// document numbers or encrypted metadata.
class FlutterLocalNotificationGateway implements LocalNotificationGateway {
  FlutterLocalNotificationGateway(this._plugin);
  final FlutterLocalNotificationsPlugin _plugin;

  static Future<void> initializeTimeZones({String? locationName}) async {
    tzdata.initializeTimeZones();
    if (locationName != null) tz.setLocalLocation(tz.getLocation(locationName));
  }

  Future<void> initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<LocalNotificationPermission> permission() async =>
      _map(await Permission.notification.status);

  @override
  Future<LocalNotificationPermission> requestPermission() async =>
      _map(await Permission.notification.request());

  @override
  Future<void> openSettings() => openAppSettings();

  @override
  Future<int> pendingCount() async =>
      (await _plugin.pendingNotificationRequests()).length;

  @override
  Future<void> schedule({
    required int notificationId,
    required DateTime at,
    required PrivateNotificationContent content,
  }) => _plugin.zonedSchedule(
    id: notificationId,
    title: content.title,
    body: content.body,
    scheduledDate: tz.TZDateTime.from(at, tz.local),
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'document_expiry_reminders',
        'Document expiry reminders',
        channelDescription: 'Private reminders for document lifecycle dates.',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.private,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: 'vault-reminder',
  );

  @override
  Future<void> cancel(int notificationId) => _plugin.cancel(id: notificationId);

  LocalNotificationPermission _map(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return LocalNotificationPermission.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return LocalNotificationPermission.permanentlyDenied;
    }
    if (status.isDenied) {
      return LocalNotificationPermission.denied;
    }
    return LocalNotificationPermission.notDetermined;
  }
}
