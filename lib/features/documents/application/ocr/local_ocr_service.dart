import 'package:flutter/foundation.dart';

import '../../../../core/crypto/vault_data_protector.dart';
import '../../../../core/database/repositories.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/files/encrypted_file_store.dart';
import '../../../../core/files/file_reference.dart';
import '../search/search_index_builder.dart';
import 'ocr_models.dart';

/// Runs OCR only from encrypted vault input and stores output only after a
/// user accepts it. It never sends document bytes, text, or identifiers away.
class LocalOcrService {
  LocalOcrService(
    this._files,
    this._engine,
    this._documents,
    this._protector, {
    this.searchIndex,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final EncryptedFileStore _files;
  final LocalOcrEngine _engine;
  final DocumentRepository _documents;
  final VaultDataProtector _protector;
  final SearchIndexBuilder? searchIndex;
  final DateTime Function() _clock;

  Future<OcrRecognition> recognizeImage({
    required SecureFileReference source,
    required OcrLanguage language,
    void Function(OcrProgress progress)? onProgress,
  }) async {
    if (!source.mimeType.startsWith('image/')) {
      throw const UnsupportedFileFailure(
        'Local OCR currently supports images only. / লোকাল OCR এখন শুধু ছবির জন্য।',
      );
    }
    onProgress?.call(const OcrProgress(OcrProgressStage.preparing));
    try {
      final recognition = await _files.withDecryptedTemporaryFile(source, (
        privateImage,
      ) async {
        onProgress?.call(const OcrProgress(OcrProgressStage.recognizing));
        return OcrRecognition.fromEngineText(
          await _engine.recognizeImage(privateImage, language: language),
          language: language,
        );
      });
      onProgress?.call(const OcrProgress(OcrProgressStage.review));
      return recognition;
    } on Object catch (error) {
      throw OcrFailure(
        'Text could not be recognized locally. / লেখা লোকালভাবে শনাক্ত করা যায়নি।',
        cause: error,
      );
    }
  }

  Future<void> acceptRecognizedText({
    required String documentId,
    required OcrRecognition recognition,
    void Function(OcrProgress progress)? onProgress,
  }) async {
    if (!recognition.hasText) {
      throw const ValidationFailure(
        'There is no recognized text to save. / সংরক্ষণ করার মতো শনাক্ত করা লেখা নেই।',
      );
    }
    onProgress?.call(const OcrProgress(OcrProgressStage.saving));
    final context = 'document:$documentId';
    try {
      await _documents.saveAcceptedOcrText(
        documentId: documentId,
        encryptedLabel: await _protector.encrypt(
          'Recognized text / শনাক্ত করা লেখা',
          context: '$context:field-label:ocr_text',
        ),
        encryptedText: await _protector.encrypt(
          recognition.text,
          context: '$context:ocr-text',
        ),
        updatedAt: _clock().toUtc(),
      );
      // Only the unlocked in-memory index receives the accepted text. A lock
      // destroys it through SearchIndexLockHandler like all other search values.
      await searchIndex?.upsertDocument(documentId);
      onProgress?.call(const OcrProgress(OcrProgressStage.complete));
    } on Object catch (error) {
      throw OcrFailure(
        'Recognized text could not be saved. / শনাক্ত করা লেখা সংরক্ষণ করা যায়নি।',
        cause: error,
      );
    }
  }
}

/// Presentation-friendly OCR state. It holds candidate text only in memory;
/// call [clear] on navigation away or when the vault locks.
class LocalOcrController extends ChangeNotifier {
  LocalOcrController(this._service);
  final LocalOcrService _service;
  LocalOcrState _state = const LocalOcrIdle();
  LocalOcrState get state => _state;

  Future<void> recognize({
    required SecureFileReference source,
    required OcrLanguage language,
  }) async {
    _set(const LocalOcrRunning(OcrProgress(OcrProgressStage.preparing)));
    try {
      final recognition = await _service.recognizeImage(
        source: source,
        language: language,
        onProgress: (progress) => _set(LocalOcrRunning(progress)),
      );
      _set(LocalOcrReview(recognition));
    } on AppFailure catch (error) {
      _set(LocalOcrFailed(error.message));
    } on Object {
      _set(
        const LocalOcrFailed(
          'Text could not be recognized locally. / লেখা লোকালভাবে শনাক্ত করা যায়নি।',
        ),
      );
    }
  }

  Future<void> accept({required String documentId}) async {
    final review = _state;
    if (review is! LocalOcrReview) return;
    _set(const LocalOcrRunning(OcrProgress(OcrProgressStage.saving)));
    try {
      await _service.acceptRecognizedText(
        documentId: documentId,
        recognition: review.recognition,
        onProgress: (progress) => _set(LocalOcrRunning(progress)),
      );
      _set(const LocalOcrSuccess());
    } on AppFailure catch (error) {
      _set(LocalOcrFailed(error.message));
    } on Object {
      _set(
        const LocalOcrFailed(
          'Recognized text could not be saved. / শনাক্ত করা লেখা সংরক্ষণ করা যায়নি।',
        ),
      );
    }
  }

  void clear() => _set(const LocalOcrIdle());

  void _set(LocalOcrState value) {
    _state = value;
    notifyListeners();
  }
}
