import 'package:permission_handler/permission_handler.dart';

import '../../authentication/application/biometric_authenticator.dart';
import '../../reminders/application/local_notification_gateway.dart';
import '../../reminders/application/reminder_models.dart';

enum DeviceAccessStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unavailable,
}

class PrivacyPermissionSnapshot {
  const PrivacyPermissionSnapshot({
    required this.camera,
    required this.photosAndFiles,
    required this.notifications,
    required this.biometrics,
  });
  final DeviceAccessStatus camera;
  final DeviceAccessStatus photosAndFiles;
  final DeviceAccessStatus notifications;
  final DeviceAccessStatus biometrics;
}

abstract interface class DevicePrivacyPermissions {
  Future<DeviceAccessStatus> camera();
  Future<DeviceAccessStatus> photosAndFiles();
  Future<DeviceAccessStatus> requestCamera();
  Future<DeviceAccessStatus> requestPhotosAndFiles();
  Future<void> openSettings();
}

class PermissionHandlerPrivacyPermissions implements DevicePrivacyPermissions {
  const PermissionHandlerPrivacyPermissions();
  @override
  Future<DeviceAccessStatus> camera() async =>
      _map(await Permission.camera.status);
  @override
  Future<DeviceAccessStatus> photosAndFiles() async {
    final photos = await Permission.photos.status;
    if (photos.isGranted || photos.isLimited) {
      return DeviceAccessStatus.granted;
    }
    // Android system file picker needs no broad storage permission. If Photos
    // is unavailable, its status still communicates that access is picker-only.
    return _map(photos);
  }

  @override
  Future<DeviceAccessStatus> requestCamera() async =>
      _map(await Permission.camera.request());
  @override
  Future<DeviceAccessStatus> requestPhotosAndFiles() async =>
      _map(await Permission.photos.request());
  @override
  Future<void> openSettings() => openAppSettings();

  DeviceAccessStatus _map(PermissionStatus value) {
    if (value.isGranted || value.isLimited) {
      return DeviceAccessStatus.granted;
    }
    if (value.isPermanentlyDenied) {
      return DeviceAccessStatus.permanentlyDenied;
    }
    if (value.isRestricted) {
      return DeviceAccessStatus.restricted;
    }
    if (value.isDenied) {
      return DeviceAccessStatus.denied;
    }
    return DeviceAccessStatus.unavailable;
  }
}

/// Provides a single status view without requesting access automatically.
/// Request methods are intentionally explicit for just-in-time UI flows.
class PrivacyPermissionsService {
  PrivacyPermissionsService(
    this._permissions,
    this._notifications,
    this._biometrics,
  );
  final DevicePrivacyPermissions _permissions;
  final LocalNotificationGateway _notifications;
  final BiometricAuthenticator _biometrics;

  Future<PrivacyPermissionSnapshot> status() async => PrivacyPermissionSnapshot(
    camera: await _permissions.camera(),
    photosAndFiles: await _permissions.photosAndFiles(),
    notifications: _notificationStatus(await _notifications.permission()),
    biometrics: _biometricStatus(await _biometrics.availability()),
  );

  Future<DeviceAccessStatus> requestCamera() => _permissions.requestCamera();
  Future<DeviceAccessStatus> requestPhotosAndFiles() =>
      _permissions.requestPhotosAndFiles();
  Future<void> openSystemSettings() => _permissions.openSettings();

  DeviceAccessStatus _notificationStatus(LocalNotificationPermission value) =>
      switch (value) {
        LocalNotificationPermission.granted => DeviceAccessStatus.granted,
        LocalNotificationPermission.denied => DeviceAccessStatus.denied,
        LocalNotificationPermission.permanentlyDenied =>
          DeviceAccessStatus.permanentlyDenied,
        LocalNotificationPermission.notDetermined =>
          DeviceAccessStatus.unavailable,
      };
  DeviceAccessStatus _biometricStatus(BiometricAvailability value) =>
      switch (value) {
        BiometricAvailability.available => DeviceAccessStatus.granted,
        BiometricAvailability.unavailable => DeviceAccessStatus.unavailable,
        BiometricAvailability.notEnrolled => DeviceAccessStatus.denied,
        BiometricAvailability.temporarilyUnavailable =>
          DeviceAccessStatus.restricted,
      };
}
