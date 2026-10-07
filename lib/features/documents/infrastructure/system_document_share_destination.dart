import 'dart:io';

import 'package:flutter/services.dart';

import '../../../core/errors/app_failure.dart';
import '../application/export/secure_export_models.dart';

/// Opens the OS-native share surface. It passes only opaque private file paths
/// to native code; no title, number, watermark, recipient, or audit content.
class SystemDocumentShareDestination implements SecureShareDestination {
  static const _channel = MethodChannel('documentvault/secure_share');

  @override
  Future<bool> share({
    required List<File> files,
    required String mimeType,
  }) async {
    if (files.isEmpty || files.any((file) => !file.existsSync())) {
      throw const StorageFailure('The secure export is no longer available.');
    }
    try {
      return await _channel.invokeMethod<bool>('share', {
            'sourcePaths': files.map((file) => file.path).toList(),
            'mimeType': mimeType,
          }) ??
          false;
    } on PlatformException catch (error) {
      throw StorageFailure(
        'Could not open the system share sheet.',
        cause: error,
      );
    } on MissingPluginException catch (error) {
      throw StorageFailure(
        'Sharing is unavailable on this device.',
        cause: error,
      );
    }
  }
}
