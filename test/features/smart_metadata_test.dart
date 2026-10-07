import 'dart:typed_data';

import 'package:documentvault/core/crypto/vault_data_protector.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/files/file_reference.dart';
import 'package:documentvault/features/documents/application/creation/document_creation_models.dart';
import 'package:documentvault/features/documents/application/creation/document_selection.dart';
import 'package:documentvault/features/documents/application/library/document_library_models.dart';
import 'package:documentvault/features/documents/application/library/document_library_repository.dart';
import 'package:documentvault/features/documents/application/smart_metadata/duplicate_detection_service.dart';
import 'package:documentvault/features/documents/application/smart_metadata/smart_metadata_models.dart';
import 'package:documentvault/features/documents/application/smart_metadata/smart_metadata_suggester.dart';
import 'package:documentvault/features/documents/presentation/smart_metadata_suggestions_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  const categories = [
    CategorySearchEntry(
      id: 'passport',
      code: 'identity.passport',
      label: 'Passport / পাসপোর্ট',
    ),
    CategorySearchEntry(
      id: 'nid',
      code: 'identity.nid',
      label: 'National ID / জাতীয় পরিচয়পত্র',
    ),
  ];

  test('suggests passport metadata locally with confidence', () {
    final suggestions = const SmartMetadataSuggester().suggest(
      recognizedText: 'Bangladesh Passport No: AB1234567 Issue date: 2020-01-02 Expiry date: 2030-01-02',
      categories: categories,
    );

    expect(suggestions.category?.value.id, 'passport');
    expect(suggestions.title?.value, 'Passport / পাসপোর্ট');
    expect(suggestions.documentNumber?.value, 'AB1234567');
    expect(suggestions.issueDate?.value, DateTime.utc(2020, 1, 2));
    expect(suggestions.expiryDate?.value, DateTime.utc(2030, 1, 2));
    expect(suggestions.category!.confidence, greaterThan(.8));
  });

  test('normalizes Bengali numerals for a local NID suggestion', () {
    final suggestions = const SmartMetadataSuggester().suggest(
      recognizedText: 'জাতীয় পরিচয়পত্র NID ১২৩৪৫৬৭৮৯০১',
      categories: categories,
    );

    expect(suggestions.category?.value.id, 'nid');
    expect(suggestions.documentNumber?.value, '12345678901');
  });

  test('finds exact hashes and advisory metadata matches', () async {
    final detector = DuplicateDetectionService(
      _SnapshotRepository(_snapshot()),
      const _PlainProtector(),
    );
    final draft = _draft(number: 'ab-1234567');

    final metadata = await detector.findMetadataMatches(draft);
    final exact = await detector.findExactFileMatches(['a' * 64]);

    expect(metadata.single.kind, DuplicateKind.metadata);
    expect(metadata.single.documentIds, ['existing']);
    expect(exact.single.kind, DuplicateKind.exactFile);
    expect(exact.single.confidence, 1);
  });

  test('hashes a stream without retaining the source', () async {
    final detector = DuplicateDetectionService(
      _SnapshotRepository(_snapshot()),
      const _PlainProtector(),
    );

    final hashes = await detector.hashStagedFiles([
      Stream<List<int>>.fromIterable([
        Uint8List.fromList([1, 2]),
        Uint8List.fromList([3, 4]),
      ]),
    ]);

    expect(hashes, [
      '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a',
    ]);
  });

  test(
    'perceptual image prototype marks identical images as approximate',
    () async {
      final pixels = image.Image(width: 16, height: 16)
        ..setPixelRgb(4, 4, 255, 0, 0);
      final bytes = image.encodeJpg(pixels);
      final reference = _reference('first');
      final prototype = PerceptualImageDuplicatePrototype(_MemoryStore(bytes));

      final matches = await prototype.compare(
        source: reference,
        candidates: [
          PerceptualImageCandidate(documentId: 'existing', file: reference),
        ],
      );

      expect(matches.single.kind, DuplicateKind.perceptualImagePrototype);
      expect(matches.single.distance, 0);
      expect(matches.single.confidence, 1);
    },
  );

  testWidgets('suggestions require an explicit Use action', (tester) async {
    String? accepted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmartMetadataSuggestionsPanel(
            suggestions: const SmartMetadataSuggestions(
              title: SmartSuggestion(
                field: SmartMetadataField.title,
                value: 'Passport / পাসপোর্ট',
                confidence: .9,
                reason: 'Local OCR text',
              ),
            ),
            onUseTitle: (value) => accepted = value,
          ),
        ),
      ),
    );

    expect(accepted, isNull);
    await tester.tap(find.text('Use / ব্যবহার করুন'));
    expect(accepted, 'Passport / পাসপোর্ট');
  });
}

DocumentDraft _draft({String? number}) => DocumentDraft(
  title: 'Passport / পাসপোর্ট',
  categoryId: 'passport',
  categoryCode: 'identity.passport',
  owners: const DocumentOwnerSelection.household(),
  documentNumber: number,
);

DocumentLibrarySnapshot _snapshot() {
  final now = DateTime.utc(2026, 10, 7);
  return DocumentLibrarySnapshot(
    documents: [
      Document(
        id: 'existing',
        titleEncrypted: 'Passport / পাসপোর্ট',
        categoryId: 'passport',
        ownershipType: 'personal',
        documentNumberEncrypted: 'AB1234567',
        status: 'active',
        isFavorite: false,
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    categories: const [],
    members: const [],
    owners: const [],
    tags: const [],
    tagLinks: const [],
    locations: const [],
    files: [
      DocumentFile(
        id: 'file',
        documentId: 'existing',
        fileType: 'original',
        mimeType: 'image/jpeg',
        encryptedRelativePath: 'existing/file.dvf',
        sizeBytes: 1,
        integrityHash: 'a' * 64,
        encryptionVersion: 1,
        createdAt: now,
      ),
    ],
    pages: const [],
    fields: const [],
    reminders: const [],
  );
}

SecureFileReference _reference(String id) => SecureFileReference(
  id: id,
  encryptedRelativePath: '$id.dvf',
  mimeType: 'image/jpeg',
  integrityHash: 'hash',
  sizeBytes: 1,
);

class _SnapshotRepository implements DocumentLibraryRepository {
  const _SnapshotRepository(this.snapshot);
  final DocumentLibrarySnapshot snapshot;

  @override
  Future<DocumentLibrarySnapshot> loadSnapshot() async => snapshot;
}

class _PlainProtector implements VaultDataProtector {
  const _PlainProtector();

  @override
  Future<String> decrypt(String ciphertext, {required String context}) async =>
      ciphertext;

  @override
  Future<String> encrypt(String plaintext, {required String context}) async =>
      plaintext;

  @override
  Future<String> normalizedNameHash(
    String value, {
    required String context,
  }) async => value;
}

class _MemoryStore implements SecureFileStore {
  const _MemoryStore(this.bytes);
  final List<int> bytes;

  @override
  Future<void> delete(SecureFileReference reference) async {}

  @override
  Future<Stream<List<int>>> readDecrypted(
    SecureFileReference reference,
  ) async => Stream.value(bytes);

  @override
  Future<SecureFileReference> writeEncrypted({
    required String documentId,
    required Stream<List<int>> bytes,
    required String mimeType,
  }) => throw UnimplementedError();
}
