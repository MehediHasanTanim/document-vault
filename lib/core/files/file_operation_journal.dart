import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/vault_database.dart';
import '../errors/app_failure.dart';
import 'encrypted_file_store.dart';

enum FileOperationState {
  started('started'),
  filesWritten('files_written'),
  databaseCommitted('database_committed'),
  completed('completed'),
  failed('failed');

  const FileOperationState(this.databaseValue);
  final String databaseValue;
}

class FileOperationPayload {
  const FileOperationPayload({
    this.encryptedPaths = const [],
    this.fileIds = const [],
  });
  final List<String> encryptedPaths;
  final List<String> fileIds;

  Map<String, Object> toJson() => {'paths': encryptedPaths, 'fileIds': fileIds};
  factory FileOperationPayload.fromJson(Map<String, dynamic> json) =>
      FileOperationPayload(
        encryptedPaths: (json['paths'] as List<dynamic>? ?? const [])
            .cast<String>(),
        fileIds: (json['fileIds'] as List<dynamic>? ?? const []).cast<String>(),
      );
}

abstract interface class OperationPayloadCodec {
  Future<String> encrypt(FileOperationPayload payload);
  Future<FileOperationPayload> decrypt(String value);
}

/// The journal payload remains encrypted even though it normally contains only
/// generated paths and UUIDs; future operations may need more sensitive data.
class AesGcmOperationPayloadCodec implements OperationPayloadCodec {
  AesGcmOperationPayloadCodec(this._key);
  final SecretKey _key;
  final Cipher _cipher = AesGcm.with256bits();

  @override
  Future<String> encrypt(FileOperationPayload payload) async {
    final box = await _cipher.encrypt(
      utf8.encode(jsonEncode(payload.toJson())),
      secretKey: _key,
    );
    return jsonEncode({
      'n': base64Encode(box.nonce),
      'c': base64Encode(box.cipherText),
      'm': base64Encode(box.mac.bytes),
    });
  }

  @override
  Future<FileOperationPayload> decrypt(String value) async {
    final json = jsonDecode(value) as Map<String, dynamic>;
    final plaintext = await _cipher.decrypt(
      SecretBox(
        base64Decode(json['c'] as String),
        nonce: base64Decode(json['n'] as String),
        mac: Mac(base64Decode(json['m'] as String)),
      ),
      secretKey: _key,
    );
    return FileOperationPayload.fromJson(
      jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>,
    );
  }
}

class FileOperationReconciliationReport {
  const FileOperationReconciliationReport({
    required this.completed,
    required this.cleanedUp,
    required this.failed,
  });
  final int completed;
  final int cleanedUp;
  final int failed;
}

/// Coordinates the recoverable state machine around filesystem and database
/// work. Call it after vault unlock, when the journal key is available.
class FileOperationJournal {
  FileOperationJournal(
    this._db,
    this._storage,
    this._codec, {
    Uuid? uuid,
    DateTime Function()? clock,
  }) : _uuid = uuid ?? const Uuid(),
       _clock = clock ?? DateTime.now;

  final VaultDatabase _db;
  final EncryptedFileStore _storage;
  final OperationPayloadCodec _codec;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<String> start({
    required String operationType,
    required String entityId,
  }) async {
    final id = _uuid.v4();
    final now = _clock().toUtc();
    await _db
        .into(_db.pendingOperations)
        .insert(
          PendingOperationsCompanion.insert(
            id: id,
            operationType: operationType,
            entityId: entityId,
            state: FileOperationState.started.databaseValue,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> markFilesWritten(String id, FileOperationPayload payload) =>
      _transition(id, FileOperationState.filesWritten, payload: payload);

  Future<void> markDatabaseCommitted(String id) =>
      _transition(id, FileOperationState.databaseCommitted);

  Future<void> complete(String id) =>
      _transition(id, FileOperationState.completed);

  Future<void> fail(String id) => _transition(id, FileOperationState.failed);

  Future<void> _transition(
    String id,
    FileOperationState state, {
    FileOperationPayload? payload,
  }) async {
    final values = PendingOperationsCompanion(
      state: Value(state.databaseValue),
      updatedAt: Value(_clock().toUtc()),
      payloadEncrypted: payload == null
          ? const Value.absent()
          : Value(await _codec.encrypt(payload)),
    );
    final updated = await (_db.update(
      _db.pendingOperations,
    )..where((op) => op.id.equals(id))).write(values);
    if (updated != 1) {
      throw const StorageFailure('Operation journal entry was not found.');
    }
  }

  Future<FileOperationReconciliationReport> reconcileAtStartup() async {
    var completed = 0;
    var cleanedUp = 0;
    var failed = 0;
    final pending =
        await (_db.select(_db.pendingOperations)..where(
              (op) => op.state.isNotIn(<String>[
                FileOperationState.completed.databaseValue,
                FileOperationState.failed.databaseValue,
              ]),
            ))
            .get();
    for (final operation in pending) {
      try {
        final payload = operation.payloadEncrypted == null
            ? const FileOperationPayload()
            : await _codec.decrypt(operation.payloadEncrypted!);
        if (operation.state == FileOperationState.started.databaseValue) {
          await fail(operation.id);
          failed++;
          continue;
        }
        final deletion = operation.operationType == 'document_delete';
        final committed = deletion
            ? await _metadataWasDeleted(payload.fileIds)
            : await _metadataWasCommitted(payload.fileIds);
        if (committed) {
          if (deletion) {
            for (final path in payload.encryptedPaths) {
              await _storage.deleteRelativePath(path);
            }
          }
          await markDatabaseCommitted(operation.id);
          await complete(operation.id);
          completed++;
        } else {
          for (final path in payload.encryptedPaths) {
            await _storage.deleteRelativePath(path);
          }
          await fail(operation.id);
          cleanedUp++;
        }
      } on Object {
        // Do not expose operation payload or identifiers in logs/errors.
        await fail(operation.id);
        failed++;
      }
    }
    return FileOperationReconciliationReport(
      completed: completed,
      cleanedUp: cleanedUp,
      failed: failed,
    );
  }

  Future<bool> _metadataWasCommitted(List<String> fileIds) async {
    if (fileIds.isEmpty) return false;
    final count = _db.documentFiles.id.count();
    final query = _db.selectOnly(_db.documentFiles)
      ..addColumns([count])
      ..where(_db.documentFiles.id.isIn(fileIds));
    final committed = await query
        .map((row) => row.read(count) ?? 0)
        .getSingle();
    return committed == fileIds.length;
  }

  /// A delete is committed once the document-file rows have disappeared. Its
  /// encrypted paths are then safe to remove during startup recovery.
  Future<bool> _metadataWasDeleted(List<String> fileIds) async {
    // A metadata-only document deletion is already complete once its database
    // transaction committed; there are no encrypted paths left to reconcile.
    if (fileIds.isEmpty) return true;
    final count = _db.documentFiles.id.count();
    final query = _db.selectOnly(_db.documentFiles)
      ..addColumns([count])
      ..where(_db.documentFiles.id.isIn(fileIds));
    final remaining = await query
        .map((row) => row.read(count) ?? 0)
        .getSingle();
    return remaining == 0;
  }
}
