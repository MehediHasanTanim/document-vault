import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/files/encrypted_file_store.dart';
import 'import_file_validator.dart';
import 'import_models.dart';

/// A short-lived private staging area. It never retains source filenames.
class PrivateImportWorkspace {
  PrivateImportWorkspace(this._store, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();
  final EncryptedFileStore _store;
  final Uuid _uuid;

  Future<PrivateImportSession> open() async {
    final root = await _store.temporaryDirectory;
    return PrivateImportSession(
      await Directory(root.path).createTemp('import-'),
      _uuid,
    );
  }
}

class PrivateImportSession {
  PrivateImportSession(this._directory, this._uuid);
  final Directory _directory;
  final Uuid _uuid;
  Future<void>? _disposeFuture;

  Future<StagedImportFile> copyAndValidate(
    SelectedImportFile selected,
    ImportFileValidator validator,
  ) async {
    final destination = File('${_directory.path}/${_uuid.v4()}.source');
    IOSink? sink;
    try {
      sink = destination.openWrite(mode: FileMode.writeOnly);
      await selected.file.openRead().pipe(sink);
      sink = null; // [pipe] closes the destination sink on normal completion.
      final validation = await validator.validate(
        destination,
        declaredMimeType: selected.declaredMimeType,
      );
      return StagedImportFile(
        file: destination,
        source: selected.source,
        mimeType: validation.mimeType,
        sizeBytes: validation.sizeBytes,
        rotation: selected.rotation,
      );
    } on Object catch (error) {
      try {
        await sink?.close();
      } on Object {
        // Delete the incomplete private staging file below either way.
      }
      if (await destination.exists()) await destination.delete();
      if (error is AppFailure) rethrow;
      throw StorageFailure(
        'Could not prepare the selected file for import.',
        cause: error,
      );
    }
  }

  /// Safe when normal completion and lifecycle cleanup overlap.
  Future<void> dispose() => _disposeFuture ??= _dispose();

  Future<void> _dispose() async {
    if (await _directory.exists()) await _directory.delete(recursive: true);
  }
}
