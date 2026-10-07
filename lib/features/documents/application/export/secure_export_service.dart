import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/files/file_reference.dart';
import 'secure_export_models.dart';
import 'share_audit_service.dart';

/// Produces private, flattened JPEG copies for sharing. It never changes the
/// encrypted source document, stores no preview or redaction geometry, and
/// deletes every workspace on success, cancellation, or failure.
class SecureExportService {
  factory SecureExportService(
    SecureFileStore files, {
    required Future<Directory> Function() workspaceDirectory,
    SecurePdfExportRasterizer? pdfRasterizer,
    Uuid? uuid,
    int maxImageBytes = 32 * 1024 * 1024,
  }) => SecureExportService._(
    files,
    workspaceDirectory: workspaceDirectory,
    pdfRasterizer: pdfRasterizer,
    uuid: uuid ?? const Uuid(),
    maxImageBytes: maxImageBytes,
  );

  SecureExportService._(
    this._files, {
    required this._workspaceDirectory,
    required this._pdfRasterizer,
    required this._uuid,
    required this.maxImageBytes,
  });

  final SecureFileStore _files;
  final Future<Directory> Function() _workspaceDirectory;
  final SecurePdfExportRasterizer? _pdfRasterizer;
  final Uuid _uuid;
  final int maxImageBytes;

  Future<ExportPreview> preview(
    SecureExportRequest request,
    int pageNumber,
  ) async {
    _validateRequest(request);
    final page = request.selectedPages
        .where((candidate) => candidate.pageNumber == pageNumber)
        .firstOrNull;
    if (page == null) {
      throw const ValidationFailure('Choose a page before previewing it.');
    }
    final bytes = await _renderPage(page, request.watermark);
    return ExportPreview(pageNumber: pageNumber, jpegBytes: bytes);
  }

  Future<PreparedSecureExport> prepare(SecureExportRequest request) async {
    _validateRequest(request);
    final selected = request.selectedPages;
    if (request.documentId.isEmpty || selected.isEmpty) {
      throw const ValidationFailure(
        'Choose at least one page to export / রপ্তানির জন্য অন্তত একটি পৃষ্ঠা বেছে নিন।',
      );
    }
    final root = await _workspaceDirectory();
    await root.create(recursive: true);
    final workspace = await root.createTemp('export-');
    try {
      final outputs = <File>[];
      for (var index = 0; index < selected.length; index++) {
        final rendered = await _renderPage(selected[index], request.watermark);
        // Opaque filenames avoid leaking titles or document numbers through an
        // exported URI, recents list, or another app's diagnostic logging.
        final output = File('${workspace.path}/${_uuid.v4()}-$index.jpg');
        await output.writeAsBytes(rendered, flush: true);
        outputs.add(output);
      }
      return PreparedSecureExport(
        files: List.unmodifiable(outputs),
        pageCount: selected.length,
        hadWatermark: request.watermark != null,
        hadRedactions: selected.any((page) => page.redactions.isNotEmpty),
        onDispose: () => _deleteWorkspace(workspace),
      );
    } on Object catch (error) {
      await _deleteWorkspace(workspace);
      if (error is AppFailure) rethrow;
      throw StorageFailure('Could not prepare a secure export.', cause: error);
    }
  }

  Future<Uint8List> _renderPage(
    ExportSourcePage page,
    ExportWatermark? watermark,
  ) async {
    if (page.source.mimeType == 'application/pdf') {
      return _renderPdfPage(page, watermark);
    }
    if (!page.source.mimeType.startsWith('image/')) {
      throw const UnsupportedFileFailure(
        'Only image pages can be securely exported on this device.',
      );
    }
    final source = await _readBounded(page.source);
    return _flattenImage(source, page.redactions, watermark);
  }

  Future<Uint8List> _renderPdfPage(
    ExportSourcePage page,
    ExportWatermark? watermark,
  ) async {
    final rasterizer = _pdfRasterizer;
    if (rasterizer == null) {
      throw const UnsupportedFileFailure(
        'PDF sharing needs the approved secure PDF renderer. Original PDFs are not exported as a redaction fallback.',
      );
    }
    // This path must remain private even if the underlying renderer requires a
    // File rather than a stream. The temporary file is scoped to this call.
    final root = await _workspaceDirectory();
    await root.create(recursive: true);
    final workspace = await root.createTemp('pdf-render-');
    final input = File('${workspace.path}/${_uuid.v4()}.pdf');
    IOSink? sink;
    try {
      sink = input.openWrite(mode: FileMode.writeOnly);
      await for (final chunk in await _files.readDecrypted(page.source)) {
        sink.add(chunk);
      }
      await sink.flush();
      await sink.close();
      sink = null;
      final pages = await rasterizer.rasterizeSelectedPages(
        privatePdf: input,
        pageNumbers: {page.pageNumber},
      );
      if (pages.length != 1) {
        throw const UnsupportedFileFailure(
          'The secure PDF renderer returned an invalid page set.',
        );
      }
      return _flattenImage(pages.single, page.redactions, watermark);
    } finally {
      try {
        await sink?.close();
      } on Object {
        // Workspace deletion is the cleanup guarantee.
      }
      await _deleteWorkspace(workspace);
    }
  }

  Future<Uint8List> _readBounded(SecureFileReference source) async {
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in await _files.readDecrypted(source)) {
      if (bytes.length + chunk.length > maxImageBytes) {
        throw const InsufficientStorageFailure(
          'This image is too large to prepare safely for sharing.',
        );
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  Uint8List _flattenImage(
    Uint8List source,
    List<NormalizedRedaction> redactions,
    ExportWatermark? watermark,
  ) {
    final decoded = image.decodeImage(source);
    if (decoded == null) {
      throw const UnsupportedFileFailure(
        'The image could not be decoded safely.',
      );
    }
    for (final redaction in redactions) {
      image.fillRect(
        decoded,
        x1: (redaction.left * decoded.width).floor(),
        y1: (redaction.top * decoded.height).floor(),
        x2: ((redaction.left + redaction.width) * decoded.width).ceil() - 1,
        y2: ((redaction.top + redaction.height) * decoded.height).ceil() - 1,
        color: image.ColorUint8.rgb(0, 0, 0),
        alphaBlend: false,
      );
    }
    if (watermark != null) {
      _drawWatermark(decoded, watermark);
    }
    // Decoding then encoding yields a new raster image: EXIF/XMP, embedded
    // thumbnails, comments and any recoverable hidden image payload are gone.
    return Uint8List.fromList(image.encodeJpg(decoded, quality: 92));
  }

  void _drawWatermark(image.Image canvas, ExportWatermark watermark) {
    final font = canvas.width >= 1200 ? image.arial48 : image.arial24;
    const margin = 20;
    final y = canvas.height > 80 ? canvas.height - 64 : margin;
    image.drawString(
      canvas,
      watermark.text,
      font: font,
      x: margin + 2,
      y: y + 2,
      color: image.ColorUint8.rgb(0, 0, 0),
    );
    image.drawString(
      canvas,
      watermark.text,
      font: font,
      x: margin,
      y: y,
      color: image.ColorUint8.rgb(255, 255, 255),
    );
  }

  Future<void> _deleteWorkspace(Directory workspace) async {
    if (await workspace.exists()) await workspace.delete(recursive: true);
  }

  void _validateRequest(SecureExportRequest request) {
    final watermark = request.watermark;
    if (watermark != null &&
        !RegExp(r'^[\x20-\x7e]{1,80}$').hasMatch(watermark.text)) {
      throw const ValidationFailure(
        'Use supported watermark characters for secure export.',
      );
    }
  }
}

/// Coordinates handoff, non-sensitive audit recording, and cleanup. The OS
/// destination resolves when its share UI returns, so source files remain
/// available only for the share duration and are then deleted even on cancel.
class SecureShareCoordinator {
  SecureShareCoordinator(this._exports, this._destination, this._audit);
  final SecureExportService _exports;
  final SecureShareDestination _destination;
  final ShareAuditService _audit;

  Future<bool> exportAndShare(SecureExportRequest request) async {
    final prepared = await _exports.prepare(request);
    try {
      final handedOff = await _destination.share(
        files: prepared.files,
        mimeType: 'image/jpeg',
      );
      if (handedOff) {
        await _audit.recordHandoff(
          documentId: request.documentId,
          pageCount: prepared.pageCount,
          hadWatermark: prepared.hadWatermark,
          hadRedactions: prepared.hadRedactions,
        );
      }
      return handedOff;
    } finally {
      await prepared.dispose();
    }
  }
}

class SecureExportWorkspaceCleanup {
  const SecureExportWorkspaceCleanup(this._root);
  final Future<Directory> Function() _root;

  /// Startup recovery removes only export/PDF-render workspaces, never viewer
  /// or import workspaces which are managed by their own cleanup services.
  Future<int> cleanAbandoned() async {
    final root = await _root();
    if (!await root.exists()) return 0;
    var removed = 0;
    await for (final entity in root.list()) {
      final name = entity.uri.pathSegments
          .where((value) => value.isNotEmpty)
          .last;
      if (entity is Directory &&
          (name.startsWith('export-') || name.startsWith('pdf-render-'))) {
        await entity.delete(recursive: true);
        removed++;
      }
    }
    return removed;
  }
}
