import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/files/encrypted_file_store.dart';
import '../../../../core/files/file_reference.dart';

/// A scoped private plaintext file for renderers which cannot consume streams.
/// It is created only inside the vault temp directory and removed on [close].
class SecureViewerSession {
  SecureViewerSession._(this.file, this._workspace);
  final File file;
  final Directory _workspace;

  static Future<SecureViewerSession> open(
    EncryptedFileStore store,
    SecureFileReference reference, {
    Uuid? uuid,
  }) async {
    final workspace = await Directory((await store.temporaryDirectory).path)
        .createTemp('viewer-');
    final file = File('${workspace.path}/${(uuid ?? const Uuid()).v4()}.bin');
    try {
      final sink = file.openWrite(mode: FileMode.writeOnly);
      await for (final chunk in await store.readDecrypted(reference)) {
        sink.add(chunk);
      }
      await sink.close();
      return SecureViewerSession._(file, workspace);
    } on Object catch (error) {
      if (await workspace.exists()) await workspace.delete(recursive: true);
      if (error is AppFailure) rethrow;
      throw StorageFailure(
        'The document could not be opened securely.',
        cause: error,
      );
    }
  }

  Future<void> close() async {
    if (await _workspace.exists()) await _workspace.delete(recursive: true);
  }
}

/// PDF renderers are injected behind this abstraction. An implementation must
/// render only while [SecureViewerSession] is alive; it must not retain its
/// temporary PDF path or write thumbnails outside the protected cache.
abstract interface class SecurePdfRenderer<TPage> {
  Future<int> pageCount(File privatePdf);
  Future<TPage> renderPage(File privatePdf, int page, {required double scale});
}
