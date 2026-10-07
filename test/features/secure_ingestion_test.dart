import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/files/encrypted_file_store.dart';
import 'package:documentvault/core/files/file_reference.dart';
import 'package:documentvault/core/files/file_operation_journal.dart';
import 'package:documentvault/features/documents/application/ingestion/import_file_validator.dart';
import 'package:documentvault/features/documents/application/ingestion/import_models.dart';
import 'package:documentvault/features/documents/application/ingestion/ingestion_permissions.dart';
import 'package:documentvault/features/documents/application/ingestion/multi_page_capture_draft.dart';
import 'package:documentvault/features/documents/application/ingestion/private_import_workspace.dart';
import 'package:documentvault/features/documents/application/ingestion/secure_import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

import '../support/database_test_harness.dart';

void main() {
  late Directory root;
  late VaultDatabase database;
  late EncryptedFileStore files;
  late SecureImportService importer;
  final now = DateTime.utc(2026, 10, 6);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('document-vault-ingestion-');
    database = openTestDatabase();
    final key = SecretKey(List<int>.filled(32, 9));
    files = EncryptedFileStore(key, supportDirectory: () async => root);
    final journal = FileOperationJournal(
      database,
      files,
      AesGcmOperationPayloadCodec(key),
      clock: () => now,
    );
    importer = SecureImportService(
      DriftDocumentRepository(database),
      files,
      journal,
      PrivateImportWorkspace(files),
      const _Capacity(1024 * 1024 * 1024),
      clock: () => now,
    );
    await DriftCategoryRepository(database).save(
      DocumentCategoriesCompanion.insert(
        id: 'category-1',
        code: 'other',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await DriftDocumentRepository(database).create(
      DocumentWrite(
        document: DocumentsCompanion.insert(
          id: 'document-1',
          titleEncrypted: 'encrypted',
          categoryId: 'category-1',
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
  });
  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  test(
    'validates, privately stages, encrypts and commits imported image metadata',
    () async {
      final source = await _jpeg(root);
      final session = await importer.openWorkspace();
      final staged = await importer.stage(
        [
          SelectedImportFile(
            file: source,
            source: ImportSource.photos,
            declaredMimeType: 'image/jpeg',
          ),
        ],
        session,
        const ImportFileValidator(),
      );
      final result = await importer.importPages(
        documentId: 'document-1',
        pages: staged,
      );
      await session.dispose();
      await session.dispose();

      expect(result.fileIds, hasLength(1));
      final stored = await database.select(database.documentFiles).getSingle();
      expect(
        stored.encryptedRelativePath,
        isNot(contains(source.path.split('/').last)),
      );
      expect(await database.select(database.documentPages).get(), hasLength(1));
      final restored = <int>[];
      final reference = SecureFileReference(
        id: stored.id,
        encryptedRelativePath: stored.encryptedRelativePath,
        mimeType: stored.mimeType,
        integrityHash: stored.integrityHash,
        sizeBytes: stored.sizeBytes,
        encryptionVersion: stored.encryptionVersion,
      );
      await for (final chunk in await files.readDecrypted(reference)) {
        restored.addAll(chunk);
      }
      expect(restored, await source.readAsBytes());
    },
  );

  test('rejects an unsupported signature and corrupt PDF', () async {
    final unsupported = File('${root.path}/unsafe.txt')
      ..writeAsStringSync('not a document');
    await expectLater(
      const ImportFileValidator().validate(unsupported),
      throwsA(isA<UnsupportedFileFailure>()),
    );
    final incompletePdf = File('${root.path}/broken.pdf')
      ..writeAsStringSync('%PDF-1.7\nmissing eof');
    await expectLater(
      const ImportFileValidator().validate(incompletePdf),
      throwsA(isA<UnsupportedFileFailure>()),
    );
  });

  test(
    'rejects import cleanly when reported free storage is insufficient',
    () async {
      final lowStorageImporter = SecureImportService(
        DriftDocumentRepository(database),
        files,
        FileOperationJournal(
          database,
          files,
          AesGcmOperationPayloadCodec(SecretKey(List<int>.filled(32, 9))),
        ),
        PrivateImportWorkspace(files),
        const _Capacity(0),
      );
      final session = await lowStorageImporter.openWorkspace();
      await expectLater(
        lowStorageImporter.stage(
          [
            SelectedImportFile(
              file: await _jpeg(root),
              source: ImportSource.photos,
            ),
          ],
          session,
          const ImportFileValidator(),
        ),
        throwsA(isA<InsufficientStorageFailure>()),
      );
      await session.dispose();
    },
  );

  test('restart recovery removes encrypted output left before database commit', () async {
    final key = SecretKey(List<int>.filled(32, 9));
    final journal = FileOperationJournal(
      database,
      files,
      AesGcmOperationPayloadCodec(key),
    );
    final reference = await files.writeEncrypted(
      documentId: 'document-1',
      mimeType: 'image/jpeg',
      bytes: Stream.value([1, 2, 3]),
    );
    final operation = await journal.start(
      operationType: 'document_import',
      entityId: 'document-1',
    );
    await journal.markFilesWritten(
      operation,
      FileOperationPayload(
        encryptedPaths: [reference.encryptedRelativePath],
        fileIds: [reference.id],
      ),
    );
    final recovery = ImportRecoveryService(
      database,
      journal,
      EncryptedStorageCleanupManager(files),
    );
    expect((await recovery.reconcile()).cleanedUp, 1);
    expect(
      await File(
        '${(await files.documentsDirectory).path}/${reference.encryptedRelativePath}',
      ).exists(),
      isFalse,
    );
  });

  test('restart recovery removes a partial encrypted write from interrupted encryption', () async {
    final partial = File(
      '${(await files.documentsDirectory).path}/document-1/.interrupted.pending',
    );
    await partial.parent.create(recursive: true);
    await partial.writeAsBytes([1, 2, 3]);
    final key = SecretKey(List<int>.filled(32, 9));
    final recovery = ImportRecoveryService(
      database,
      FileOperationJournal(database, files, AesGcmOperationPayloadCodec(key)),
      EncryptedStorageCleanupManager(files),
    );
    await recovery.reconcile();
    expect(await partial.exists(), isFalse);
  });

  test('multi-page drafts support add, rotate, retake, delete and reorder', () {
    final first = File('${root.path}/first.jpg');
    final second = File('${root.path}/second.jpg');
    final replacement = File('${root.path}/replacement.jpg');
    final draft = const MultiPageCaptureDraft()
        .add(first)
        .add(second)
        .rotateClockwise(0)
        .reorder(0, 2)
        .retake(1, replacement)
        .removeAt(0);
    expect(draft.pageCount, 1);
    expect(draft.pages.single.file.path, replacement.path);
  });

  test(
    'camera permission is requested only for scan and denial is surfaced',
    () async {
      final permission = IngestionPermissionService(
        const _Permissions(camera: false, photos: true),
        isApple: () => true,
      );
      await expectLater(
        permission.ensureCamera(),
        throwsA(isA<PermissionFailure>()),
      );
      await permission.ensurePhotosWhenRequired();
    },
  );
}

Future<File> _jpeg(Directory root) async {
  final file = File('${root.path}/picked-image.jpg');
  await file.writeAsBytes(image.encodeJpg(image.Image(width: 2, height: 2)));
  return file;
}

class _Capacity implements StorageCapacityProvider {
  const _Capacity(this.value);
  final int value;
  @override
  Future<int?> availableBytes() async => value;
}

class _Permissions implements IngestionPermissionGateway {
  const _Permissions({required this.camera, required this.photos});
  final bool camera;
  final bool photos;
  @override
  Future<bool> requestCamera() async => camera;
  @override
  Future<bool> requestPhotos() async => photos;
}
