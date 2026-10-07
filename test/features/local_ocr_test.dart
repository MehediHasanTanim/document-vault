import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:documentvault/core/crypto/vault_data_protector.dart';
import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/files/encrypted_file_store.dart';
import 'package:documentvault/core/files/file_reference.dart';
import 'package:documentvault/features/documents/application/library/document_library_repository.dart';
import 'package:documentvault/features/documents/application/ocr/local_ocr_service.dart';
import 'package:documentvault/features/documents/application/ocr/ocr_models.dart';
import 'package:documentvault/features/documents/application/search/search_index_builder.dart';
import 'package:documentvault/features/documents/application/search/secure_search_index.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../support/database_test_harness.dart';

void main() {
  late Directory root;
  late VaultDatabase database;
  late EncryptedFileStore files;
  late AesGcmVaultDataProtector protector;
  late SecureFileReference source;
  final now = DateTime.utc(2026, 10, 7);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('document-vault-ocr-');
    database = openTestDatabase();
    final key = SecretKey(List<int>.filled(32, 77));
    files = EncryptedFileStore(key, supportDirectory: () async => root);
    protector = AesGcmVaultDataProtector(key);
    await database
        .into(database.documentCategories)
        .insert(
          DocumentCategoriesCompanion.insert(
            id: 'category',
            code: 'identity',
            nameKey: const Value('Identity'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.documents)
        .insert(
          DocumentsCompanion.insert(
            id: 'document',
            titleEncrypted: await protector.encrypt(
              'National ID',
              context: 'document:document:title',
            ),
            categoryId: 'category',
            createdAt: now,
            updatedAt: now,
          ),
        );
    source = await files.writeEncrypted(
      documentId: 'document',
      mimeType: 'image/jpeg',
      bytes: Stream.value([0xff, 0xd8, 0xff, 0xd9]),
    );
  });

  tearDown(() async {
    await database.close();
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('keeps English and Bengali OCR transient until acceptance, then encrypts and indexes it', () async {
    final index = SecureSearchIndex();
    final builder = SearchIndexBuilder(
      DriftDocumentLibraryRepository(database),
      protector,
      index,
    );
    final engine = _RecordingEngine('জাতীয় পরিচয়পত্র National ID ১২৩৪');
    final service = LocalOcrService(
      files,
      engine,
      DriftDocumentRepository(database),
      protector,
      searchIndex: builder,
      clock: () => now,
    );
    final stages = <OcrProgressStage>[];

    final recognition = await service.recognizeImage(
      source: source,
      language: OcrLanguage.bengaliAndEnglish,
      onProgress: (progress) => stages.add(progress.stage),
    );

    expect(recognition.text, contains('জাতীয়'));
    expect(recognition.text, contains('National ID'));
    expect(engine.privatePath, isNotNull);
    expect(await File(engine.privatePath!).exists(), isFalse);
    expect(await database.select(database.documentFieldValues).get(), isEmpty);
    expect(stages, [
      OcrProgressStage.preparing,
      OcrProgressStage.recognizing,
      OcrProgressStage.review,
    ]);

    await service.acceptRecognizedText(
      documentId: 'document',
      recognition: recognition,
      onProgress: (progress) => stages.add(progress.stage),
    );
    final field =
        (await database.select(database.documentFieldValues).get()).single;
    expect(field.fieldKey, 'ocr_text');
    expect(field.valueType, 'ocr');
    expect(field.valueEncrypted, isNot(contains('জাতীয় পরিচয়পত্র')));
    expect(
      await protector.decrypt(
        field.valueEncrypted,
        context: 'document:document:ocr-text',
      ),
      recognition.text,
    );
    expect(index.search('জাতীয়').single.documentId, 'document');
    expect(index.search('national 1234').single.documentId, 'document');
    expect(stages.last, OcrProgressStage.complete);
  });

  test('replacing accepted OCR text does not overwrite user fields', () async {
    await database
        .into(database.documentFieldValues)
        .insert(
          DocumentFieldValuesCompanion.insert(
            id: 'user-field',
            documentId: 'document',
            fieldKey: 'document_number',
            valueEncrypted: await protector.encrypt(
              'USER-123',
              context: 'document:document:field:document_number',
            ),
            valueType: const Value('text'),
            sortOrder: const Value(0),
            createdAt: now,
            updatedAt: now,
          ),
        );
    final service = LocalOcrService(
      files,
      _RecordingEngine('first OCR text'),
      DriftDocumentRepository(database),
      protector,
      clock: () => now,
    );
    await service.acceptRecognizedText(
      documentId: 'document',
      recognition: OcrRecognition.fromEngineText(
        'first OCR text',
        language: OcrLanguage.english,
      ),
    );
    await service.acceptRecognizedText(
      documentId: 'document',
      recognition: OcrRecognition.fromEngineText(
        'updated OCR text',
        language: OcrLanguage.english,
      ),
    );
    final values = await database.select(database.documentFieldValues).get();
    expect(values.where((field) => field.fieldKey == 'ocr_text'), hasLength(1));
    expect(
      values.where((field) => field.fieldKey == 'document_number'),
      hasLength(1),
    );
  });

  test(
    'surfaces a privacy-safe failure and cleans the temporary OCR file',
    () async {
      final controller = LocalOcrController(
        LocalOcrService(
          files,
          const _FailingEngine(),
          DriftDocumentRepository(database),
          protector,
        ),
      );
      await controller.recognize(
        source: source,
        language: OcrLanguage.bengaliAndEnglish,
      );
      expect(controller.state, isA<LocalOcrFailed>());
      expect(
        (controller.state as LocalOcrFailed).message,
        isNot(contains('engine diagnostic')),
      );
      expect(await (await files.temporaryDirectory).list().isEmpty, isTrue);
    },
  );
}

class _RecordingEngine implements LocalOcrEngine {
  _RecordingEngine(this.text);
  final String text;
  String? privatePath;
  @override
  Future<String> recognizeImage(
    File privateImage, {
    required OcrLanguage language,
  }) async {
    expect(await privateImage.exists(), isTrue);
    privatePath = privateImage.path;
    return text;
  }
}

class _FailingEngine implements LocalOcrEngine {
  const _FailingEngine();
  @override
  Future<String> recognizeImage(
    File privateImage, {
    required OcrLanguage language,
  }) => Future.error(const OcrFailure('engine diagnostic: private details'));
}
