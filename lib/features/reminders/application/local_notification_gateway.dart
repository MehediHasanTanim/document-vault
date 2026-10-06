import 'reminder_models.dart';

abstract interface class LocalNotificationGateway {
  Future<LocalNotificationPermission> permission();
  Future<LocalNotificationPermission> requestPermission();
  Future<void> openSettings();
  Future<int> pendingCount();
  Future<void> schedule({
    required int notificationId,
    required DateTime at,
    required PrivateNotificationContent content,
  });
  Future<void> cancel(int notificationId);
}
