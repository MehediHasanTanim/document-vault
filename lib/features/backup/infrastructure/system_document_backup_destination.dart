import 'dart:io';

import 'package:flutter/services.dart';

import '../../../../core/errors/app_failure.dart';
import '../application/backup_models.dart';
import '../application/backup_service.dart';

/// Delegates the final streaming copy of an already verified private package
/// to Android's Storage Access Framework or iOS's document exporter. Dart
/// never loads the package into memory and no cloud account is contacted.
class SystemDocumentBackupDestination implements BackupDestination {
  static const _channel = MethodChannel('documentvault/backup_destination');

  @override
  Future<BackupSaveResult> save({
    required File stagedBackup,
    required String suggestedFilename,
  }) async {
    try {
      final saved = await _channel.invokeMethod<bool>('saveBackup', {
        'sourcePath': stagedBackup.path,
        'suggestedFilename': suggestedFilename,
      });
      if (saved != true) throw const BackupCancelledFailure();
      return const BackupSaveResult(
        destinationType: BackupDestinationType.systemProvider,
      );
    } on BackupCancelledFailure {
      rethrow;
    } on PlatformException catch (error) {
      throw BackupFailure(
        'Could not save the backup to that location.',
        cause: error,
      );
    } on MissingPluginException catch (error) {
      throw BackupFailure(
        'Backup saving is unavailable on this device.',
        cause: error,
      );
    }
  }
}
