import 'dart:io';

import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/files/file_reference.dart';
import 'package:documentvault/features/documents/application/export/secure_export_models.dart';
import 'package:documentvault/features/documents/application/export/secure_export_service.dart';
import 'package:documentvault/features/documents/application/export/share_audit_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  late Directory root;
  late List<int> sourceBytes;
  late _MemoryStore files;
  late SecureExportService exports;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('documentvault-export-test-');
    final source = image.Image(width: 100, height: 80)
      ..clear(image.ColorUint8.rgb(250, 250, 250));
    source.setPixelRgb(50, 40, 200, 0, 0);
    sourceBytes = image.encodePng(source);
    files = _MemoryStore(sourceBytes);
    exports = SecureExportService(files, workspaceDirectory: () async => root);
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'selected image export permanently flattens redaction and strips format',
    () async {
      final prepared = await exports.prepare(
        _request(
          redactions: const [
            NormalizedRedaction(left: .4, top: .3, width: .2, height: .3),
          ],
        ),
      );
      addTearDown(prepared.dispose);

      expect(prepared.files, hasLength(1));
      final output = await prepared.files.single.readAsBytes();
      expect(output.take(2), [
        0xff,
        0xd8,
      ], reason: 'A new JPEG has no PNG metadata');
      final flattened = image.decodeJpg(output)!;
      final redacted = flattened.getPixel(50, 40);
      expect(redacted.r, lessThan(15));
      expect(redacted.g, lessThan(15));
      expect(redacted.b, lessThan(15));
      expect(sourceBytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);

      final workspace = prepared.files.single.parent;
      await prepared.dispose();
      expect(await workspace.exists(), isFalse);
    },
  );

  test('preview uses the same flattened pixels but creates no file', () async {
    final preview = await exports.preview(
      _request(
        watermark: const ExportWatermark('Shared copy'),
        redactions: const [
          NormalizedRedaction(left: 0, top: 0, width: .2, height: .2),
        ],
      ),
      1,
    );

    expect(preview.jpegBytes.take(2), [0xff, 0xd8]);
    expect(await root.list().isEmpty, isTrue);
  });

  test('watermark is flattened into a different export copy', () async {
    final plain = await exports.prepare(_request());
    final marked = await exports.prepare(
      _request(watermark: const ExportWatermark('Shared copy')),
    );
    addTearDown(plain.dispose);
    addTearDown(marked.dispose);

    expect(
      await plain.files.single.readAsBytes(),
      isNot(await marked.files.single.readAsBytes()),
    );
  });

  test(
    'exports only selected pages and removes abandoned workspaces',
    () async {
      final second = _reference('second');
      files.values[second.id] = sourceBytes;
      final request = SecureExportRequest(
        documentId: 'document',
        pages: [
          ExportSourcePage(pageNumber: 1, source: _reference('first')),
          ExportSourcePage(pageNumber: 2, source: second),
        ],
        selectedPageNumbers: const {2},
      );

      final prepared = await exports.prepare(request);
      expect(prepared.pageCount, 1);
      expect(prepared.files, hasLength(1));
      await prepared.dispose();

      final abandoned = await root.createTemp('export-interrupted-');
      await File('${abandoned.path}/opaque.jpg').writeAsBytes([1]);
      final viewer = await root.createTemp('viewer-');
      expect(
        await SecureExportWorkspaceCleanup(() async => root).cleanAbandoned(),
        1,
      );
      expect(await viewer.exists(), isTrue);
    },
  );

  test(
    'never falls back to sharing a raw PDF when no secure rasterizer exists',
    () async {
      final pdf = _reference('pdf', mimeType: 'application/pdf');
      files.values[pdf.id] = [37, 80, 68, 70];
      final request = SecureExportRequest(
        documentId: 'document',
        pages: [ExportSourcePage(pageNumber: 1, source: pdf)],
        selectedPageNumbers: const {1},
      );

      await expectLater(
        exports.prepare(request),
        throwsA(isA<UnsupportedFileFailure>()),
      );
      expect(await root.list().isEmpty, isTrue);
    },
  );

  test(
    'records only a successful OS handoff and always cleans output',
    () async {
      final audit = _AuditRepository();
      final destination = _Destination(true);
      final coordinator = SecureShareCoordinator(
        exports,
        destination,
        ShareAuditService(audit, clock: () => DateTime.utc(2026, 10, 7)),
      );

      expect(await coordinator.exportAndShare(_request()), isTrue);
      expect(destination.fileCount, 1);
      expect(audit.events, hasLength(1));
      final event = audit.events.single;
      expect(event.eventType.value, 'share_handoff');
      expect(event.pageCount.value, 1);
      expect(event.hadWatermark.value, isFalse);
      expect(event.hadRedactions.value, isFalse);
      expect(await root.list().isEmpty, isTrue);
    },
  );

  test(
    'cancellation leaves no audit event or private export workspace',
    () async {
      final audit = _AuditRepository();
      final coordinator = SecureShareCoordinator(
        exports,
        _Destination(false),
        ShareAuditService(audit),
      );

      expect(await coordinator.exportAndShare(_request()), isFalse);
      expect(audit.events, isEmpty);
      expect(await root.list().isEmpty, isTrue);
    },
  );
}

SecureExportRequest _request({
  ExportWatermark? watermark,
  List<NormalizedRedaction> redactions = const [],
}) => SecureExportRequest(
  documentId: 'document',
  pages: [
    ExportSourcePage(
      pageNumber: 1,
      source: _reference('first'),
      redactions: redactions,
    ),
  ],
  selectedPageNumbers: const {1},
  watermark: watermark,
);

SecureFileReference _reference(String id, {String mimeType = 'image/png'}) =>
    SecureFileReference(
      id: id,
      encryptedRelativePath: '$id/file.dvf',
      mimeType: mimeType,
      integrityHash: 'a' * 64,
      sizeBytes: 1,
    );

class _MemoryStore implements SecureFileStore {
  _MemoryStore(List<int> bytes) : values = {'first': bytes};
  final Map<String, List<int>> values;

  @override
  Future<void> delete(SecureFileReference reference) async {}

  @override
  Future<Stream<List<int>>> readDecrypted(
    SecureFileReference reference,
  ) async => Stream.value(values[reference.id]!);

  @override
  Future<SecureFileReference> writeEncrypted({
    required String documentId,
    required Stream<List<int>> bytes,
    required String mimeType,
  }) => throw UnimplementedError();
}

class _Destination implements SecureShareDestination {
  _Destination(this.result);
  final bool result;
  var fileCount = 0;

  @override
  Future<bool> share({
    required List<File> files,
    required String mimeType,
  }) async {
    fileCount = files.length;
    expect(files.every((file) => file.existsSync()), isTrue);
    return result;
  }
}

class _AuditRepository implements ShareAuditRepository {
  final events = <ShareAuditEventsCompanion>[];

  @override
  Future<List<ShareAuditEvent>> listForDocument(String documentId) =>
      throw UnimplementedError();

  @override
  Future<void> record(ShareAuditEventsCompanion event) async =>
      events.add(event);
}
