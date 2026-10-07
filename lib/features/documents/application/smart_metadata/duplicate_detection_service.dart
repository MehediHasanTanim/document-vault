import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:image/image.dart' as image;

import '../../../../core/crypto/vault_data_protector.dart';
import '../../../../core/files/file_reference.dart';
import '../creation/document_creation_models.dart';
import '../library/document_library_repository.dart';
import '../search/secure_search_index.dart';
import 'smart_metadata_models.dart';

/// Local-only duplicate matching. It decrypts metadata only after unlock and
/// keeps comparison values in memory; no normalized plaintext index is stored.
class DuplicateDetectionService {
  DuplicateDetectionService(this._repository, this._protector);
  final DocumentLibraryRepository _repository;
  final VaultDataProtector _protector;

  Future<List<DuplicateMatch>> findMetadataMatches(DocumentDraft draft) async {
    final snapshot = await _repository.loadSnapshot();
    final title = _normalize(draft.title);
    final number = _normalizeNumber(draft.documentNumber ?? '');
    if (title.isEmpty && number.isEmpty) return const [];
    final matches = <String>[];
    for (final document in snapshot.documents) {
      if (document.deletedAt != null) continue;
      final existingTitle = _normalize(
        await _protector.decrypt(
          document.titleEncrypted,
          context: 'document:${document.id}:title',
        ),
      );
      final existingNumber = document.documentNumberEncrypted == null
          ? ''
          : _normalizeNumber(
              await _protector.decrypt(
                document.documentNumberEncrypted!,
                context: 'document:${document.id}:number',
              ),
            );
      final sameNumber = number.isNotEmpty && number == existingNumber;
      final sameTitleAndCategory =
          title.isNotEmpty &&
          title == existingTitle &&
          document.categoryId == draft.categoryId;
      if (sameNumber || sameTitleAndCategory) matches.add(document.id);
    }
    if (matches.isEmpty) return const [];
    return [
      DuplicateMatch(
        kind: DuplicateKind.metadata,
        documentIds: matches,
        confidence: number.isNotEmpty ? .95 : .78,
        message:
            'Possible matching document metadata / সম্ভাব্য মিল থাকা নথির তথ্য',
      ),
    ];
  }

  Future<List<DuplicateMatch>> findExactFileMatches(
    Iterable<String> integrityHashes,
  ) async {
    final values = integrityHashes.where(_isSha256).toSet();
    if (values.isEmpty) return const [];
    final snapshot = await _repository.loadSnapshot();
    final active = snapshot.documents
        .where((document) => document.deletedAt == null)
        .map((document) => document.id)
        .toSet();
    final ids = snapshot.files
        .where(
          (file) =>
              active.contains(file.documentId) &&
              values.contains(file.integrityHash),
        )
        .map((file) => file.documentId)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return const [];
    return [
      DuplicateMatch(
        kind: DuplicateKind.exactFile,
        documentIds: ids,
        confidence: 1,
        message: 'An identical encrypted-file source already exists / একই ফাইলের উৎস আগে থেকেই আছে',
      ),
    ];
  }

  /// Computes source hashes before save without retaining input bytes.
  Future<List<String>> hashStagedFiles(
    Iterable<Stream<List<int>>> sources,
  ) async {
    final hashes = <String>[];
    for (final source in sources) {
      final sink = Sha256().toSync().newHashSink();
      await for (final chunk in source) {
        sink.add(chunk);
      }
      sink.close();
      hashes.add(_hex((await sink.hash()).bytes));
    }
    return hashes;
  }

  static String _normalize(String value) => SecureSearchIndex.normalize(value);
  static String _normalizeNumber(String value) =>
      _normalize(value).replaceAll(RegExp(r'[^a-z0-9]'), '');
  static bool _isSha256(String value) =>
      RegExp(r'^[a-f0-9]{64}$').hasMatch(value);
  static String _hex(List<int> bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

/// Adapter for the existing document-save warning seam. It is intentionally
/// non-blocking: a matching metadata record is a review prompt, never a veto.
class MetadataDuplicateWarningHook implements DuplicateWarningHook {
  const MetadataDuplicateWarningHook(this._detector);
  final DuplicateDetectionService _detector;

  @override
  Future<List<DuplicateWarning>> check(DocumentDraft draft) async =>
      (await _detector.findMetadataMatches(draft))
          .map(
            (match) => DuplicateWarning(
              message: match.message,
              kind: DuplicateWarningKind.metadata,
              documentIds: match.documentIds,
              confidence: match.confidence,
            ),
          )
          .toList(growable: false);
}

/// Checks both non-sensitive file fingerprints and metadata before saving.
/// It emits warnings only; saving remains a deliberate user decision.
class SmartDuplicateWarningHook implements DuplicateWarningHook {
  const SmartDuplicateWarningHook(this._detector);
  final DuplicateDetectionService _detector;

  @override
  Future<List<DuplicateWarning>> check(DocumentDraft draft) async {
    final results = <DuplicateWarning>[];
    for (final match in await _detector.findMetadataMatches(draft)) {
      results.add(
        DuplicateWarning(
          message: match.message,
          kind: DuplicateWarningKind.metadata,
          documentIds: match.documentIds,
          confidence: match.confidence,
        ),
      );
    }
    final hashes = await _detector.hashStagedFiles(
      draft.pages.map((page) => page.file.openRead()),
    );
    for (final match in await _detector.findExactFileMatches(hashes)) {
      results.add(
        DuplicateWarning(
          message: match.message,
          kind: DuplicateWarningKind.exactFile,
          documentIds: match.documentIds,
          confidence: match.confidence,
        ),
      );
    }
    return results;
  }
}

class PerceptualImageCandidate {
  const PerceptualImageCandidate({
    required this.documentId,
    required this.file,
  });
  final String documentId;
  final SecureFileReference file;
}

/// Opt-in prototype for visually similar images. Its 8x8 average-hash values
/// are never persisted and a result is deliberately labelled as approximate.
class PerceptualImageDuplicatePrototype {
  PerceptualImageDuplicatePrototype(
    this._files, {
    this.maxSourceBytes = 16 * 1024 * 1024,
  });
  final SecureFileStore _files;
  final int maxSourceBytes;

  Future<List<DuplicateMatch>> compare({
    required SecureFileReference source,
    required Iterable<PerceptualImageCandidate> candidates,
    int maximumDistance = 6,
  }) async {
    if (!source.mimeType.startsWith('image/')) return const [];
    final sourceHash = await _averageHash(source);
    final matches = <DuplicateMatch>[];
    for (final candidate in candidates) {
      if (!candidate.file.mimeType.startsWith('image/')) continue;
      final distance = _hamming(sourceHash, await _averageHash(candidate.file));
      if (distance <= maximumDistance) {
        matches.add(
          DuplicateMatch(
            kind: DuplicateKind.perceptualImagePrototype,
            documentIds: [candidate.documentId],
            confidence: (1 - distance / 64).clamp(0, 1).toDouble(),
            distance: distance,
            message: 'Possible visually similar image (prototype) / সম্ভাব্য দৃশ্যত মিল ছবি (প্রোটোটাইপ)',
          ),
        );
      }
    }
    return matches;
  }

  Future<List<bool>> _averageHash(SecureFileReference reference) async {
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in await _files.readDecrypted(reference)) {
      if (bytes.length + chunk.length > maxSourceBytes) {
        throw const FormatException(
          'Image is too large for perceptual comparison.',
        );
      }
      bytes.add(chunk);
    }
    final decoded = image.decodeImage(bytes.takeBytes());
    if (decoded == null) {
      throw const FormatException('Image could not be decoded.');
    }
    final small = image.copyResize(decoded, width: 8, height: 8);
    final values = [
      for (final pixel in small) (pixel.r + pixel.g + pixel.b) ~/ 3,
    ];
    final average = values.reduce((a, b) => a + b) / values.length;
    return values.map((value) => value >= average).toList(growable: false);
  }

  int _hamming(List<bool> left, List<bool> right) {
    var distance = 0;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) distance++;
    }
    return distance;
  }
}
