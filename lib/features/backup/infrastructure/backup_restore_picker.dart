import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../../../core/errors/app_failure.dart';

/// Uses the operating system document picker. The chosen backup is never
/// copied into public storage; extraction always goes to private staging.
class BackupRestorePicker {
  const BackupRestorePicker();

  Future<File> pick() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['dvbak'],
    );
    if (files.isEmpty) {
      throw const BackupCancelledFailure();
    }
    final path = files.singleOrNull?.path;
    if (path == null || !await File(path).exists()) {
      throw const UnsupportedFileFailure(
        'Choose a valid Document Vault backup file.',
      );
    }
    return File(path);
  }
}
