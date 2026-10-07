import 'dart:io';

import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/uuid/uuid_generator.dart';
import 'package:documentvault/features/backup/application/backup_models.dart';
import 'package:documentvault/features/documents/application/emergency/emergency_export_service.dart';
import 'package:documentvault/features/documents/application/lifecycle/document_link_service.dart';
import 'package:documentvault/features/documents/application/lifecycle/document_version_service.dart';
import 'package:documentvault/features/documents/application/lifecycle/emergency_collection_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../support/database_test_harness.dart';

void main() {
  late VaultDatabase database;
  late DriftDocumentRepository documents;
  late DateTime now;

  setUp(() async {
    database = openTestDatabase();
    documents = DriftDocumentRepository(database);
    now = DateTime.utc(2026, 10, 7, 9);
    await DriftCategoryRepository(database).save(
      DocumentCategoriesCompanion.insert(
        id: 'category',
        code: 'identity',
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() => database.close());

  Future<void> create(String id, {bool household = false}) => documents.create(
    DocumentWrite(
      document: DocumentsCompanion.insert(
        id: id,
        titleEncrypted: 'encrypted-$id',
        categoryId: 'category',
        ownershipType: Value(household ? 'household' : 'personal'),
        createdAt: now,
        updatedAt: now,
      ),
    ),
  );

  test(
    'emergency collection accepts only explicit available documents',
    () async {
      await create('first');
      await create('second');
      final collection = EmergencyCollectionService(
        DriftEmergencyCollectionRepository(database),
        documents,
        clock: () => now,
      );

      await collection.selectExplicitly(['second', 'first']);
      expect((await collection.items()).map((item) => item.documentId), [
        'second',
        'first',
      ]);

      await documents.moveToTrash('second', deletedAt: now);
      await expectLater(
        collection.selectExplicitly(['second']),
        throwsA(isA<ValidationFailure>()),
      );
    },
  );

  test('links are canonical, cascade-safe, and household-aware', () async {
    await create('a');
    await create('b');
    await create('house-a', household: true);
    await create('house-b', household: true);
    final links = DocumentLinkService(
      documents,
      DriftDocumentLinkRepository(database),
      clock: () => now,
    );

    await links.link(
      documentId: 'b',
      relatedDocumentId: 'a',
      relationship: DocumentRelationship.supporting,
    );
    final stored = await links.linksFor('a');
    expect(stored, hasLength(1));
    expect(stored.single.sourceDocumentId, 'a');
    expect(stored.single.targetDocumentId, 'b');

    await expectLater(
      links.linkHouseholdDocuments(documentId: 'a', relatedDocumentId: 'b'),
      throwsA(isA<ValidationFailure>()),
    );
    await links.linkHouseholdDocuments(
      documentId: 'house-b',
      relatedDocumentId: 'house-a',
    );
    expect(
      (await links.linksFor('house-a')).single.relationshipType,
      'household',
    );

    await documents.deletePermanently('a');
    expect(await links.linksFor('b'), isEmpty);
  });

  test(
    'renewal keeps a version history and supersedes the prior document',
    () async {
      await create('old');
      await create('new');
      final service = DocumentVersionService(
        documents,
        DriftDocumentVersionRepository(database),
        _SequenceUuid(['old-version', 'new-version']),
        clock: () => now,
      );

      await service.beginRenewal('old');
      expect((await documents.getById('old'))!.status, 'renewal_in_progress');
      await service.markReplacement(
        supersededDocumentId: 'old',
        replacementDocumentId: 'new',
      );

      expect((await documents.getById('old'))!.status, 'superseded');
      final history = await service.historyFor('new');
      expect(history.map((entry) => entry.id), ['new-version', 'old-version']);
      expect(history.map((entry) => entry.versionNumber), [2, 1]);
      expect(history.last.supersededAt!.toUtc(), now);
      expect((await service.historyFor('old')).map((entry) => entry.id), [
        'new-version',
        'old-version',
      ]);
    },
  );

  test(
    'emergency packages are password-encrypted and reject tampering',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'documentvault-emergency-',
      );
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      final source = File('${root.path}/source.jpg');
      await source.writeAsBytes(
        List<int>.generate(100000, (index) => index % 251),
      );
      final destination = File('${root.path}/emergency.dvep');
      final password = BackupPassword.create(
        password: 'Emergency Pack 2026!',
        confirmation: 'Emergency Pack 2026!',
        acknowledgedRecoveryWarning: true,
      );
      final codec = EmergencyPackageCodec();

      await codec.create(
        files: [source],
        password: password,
        destination: destination,
      );
      expect(
        await codec
            .verify(file: destination, password: password)
            .then((value) => value.sizeBytes),
        greaterThan(await source.length()),
      );
      final tampered = await destination.readAsBytes();
      tampered[tampered.length ~/ 2] ^= 0x01;
      await destination.writeAsBytes(tampered, flush: true);
      await expectLater(
        codec.verify(file: destination, password: password),
        throwsA(isA<StorageFailure>()),
      );
      final abandoned = await root.createTemp('emergency-pack-interrupted-');
      await File('${abandoned.path}/opaque.dvep').writeAsBytes([1]);
      expect(
        await EmergencyExportWorkspaceCleanup(() async => root)
            .cleanAbandoned(),
        1,
      );
      expect(await abandoned.exists(), isFalse);
    },
  );
}

class _SequenceUuid implements UuidGenerator {
  _SequenceUuid(this._ids);
  final List<String> _ids;
  @override
  String v4() => _ids.removeAt(0);
}
