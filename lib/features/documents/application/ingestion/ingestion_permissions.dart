import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../../../../core/errors/app_failure.dart';

enum IngestionPermission { camera, photos }

class PermissionExplanation {
  const PermissionExplanation({required this.english, required this.bangla});
  final String english;
  final String bangla;
}

abstract interface class IngestionPermissionGateway {
  Future<bool> requestCamera();
  Future<bool> requestPhotos();
}

class PlatformIngestionPermissionGateway implements IngestionPermissionGateway {
  const PlatformIngestionPermissionGateway();
  @override
  Future<bool> requestCamera() =>
      Permission.camera.request().then((status) => status.isGranted);
  @override
  Future<bool> requestPhotos() =>
      Permission.photos.request().then((status) => status.isGranted);
}

/// Requests only after a user pressed Scan or Import Photos. Android's system
/// photo/file picker receives no broad media-storage permission request.
class IngestionPermissionService {
  const IngestionPermissionService(this._gateway, {bool Function()? isApple})
    : _isApple = isApple ?? _defaultIsApple;
  final IngestionPermissionGateway _gateway;
  final bool Function() _isApple;

  static bool _defaultIsApple() => Platform.isIOS;
  static const cameraExplanation = PermissionExplanation(
    english: 'Allow camera access to scan a document. Photos are not saved to your public gallery.',
    bangla: 'নথি স্ক্যান করতে ক্যামেরা ব্যবহারের অনুমতি দিন। ছবি আপনার পাবলিক গ্যালারিতে সংরক্ষণ করা হবে না।',
  );
  static const photosExplanation = PermissionExplanation(
    english: 'Choose photos to import into this private vault. Only the photos you select are used.',
    bangla: 'এই ব্যক্তিগত ভল্টে আনার জন্য ছবি বেছে নিন। শুধু আপনার নির্বাচিত ছবিই ব্যবহার করা হবে।',
  );

  Future<void> ensureCamera() async {
    if (!await _gateway.requestCamera()) {
      throw const PermissionFailure(
        'Camera permission is needed to scan a document.',
      );
    }
  }

  Future<void> ensurePhotosWhenRequired() async {
    if (_isApple() && !await _gateway.requestPhotos()) {
      throw const PermissionFailure(
        'Photo permission is needed to import selected images.',
      );
    }
  }
}
