import 'dart:io';
import 'dart:typed_data';

import '../../../../core/files/file_reference.dart';

/// A rectangle expressed as fractions of the source image dimensions. Keeping
/// geometry transient prevents an export-redaction map becoming new sensitive
/// persistent metadata.
class NormalizedRedaction {
  const NormalizedRedaction({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  }) : assert(left >= 0 && left <= 1),
       assert(top >= 0 && top <= 1),
       assert(width > 0 && width <= 1),
       assert(height > 0 && height <= 1),
       assert(left + width <= 1),
       assert(top + height <= 1);

  final double left;
  final double top;
  final double width;
  final double height;
}

class ExportSourcePage {
  const ExportSourcePage({
    required this.pageNumber,
    required this.source,
    this.redactions = const [],
  });

  /// One-based, user-visible page number.
  final int pageNumber;
  final SecureFileReference source;
  final List<NormalizedRedaction> redactions;
}

class ExportWatermark {
  const ExportWatermark(this.text) : assert(text.length <= 80);

  /// The bundled bitmap font is intentionally restricted to printable ASCII;
  /// silently dropping Bangla characters would create a misleading watermark.
  final String text;
}

class SecureExportRequest {
  const SecureExportRequest({
    required this.documentId,
    required this.pages,
    required this.selectedPageNumbers,
    this.watermark,
  });

  final String documentId;
  final List<ExportSourcePage> pages;
  final Set<int> selectedPageNumbers;
  final ExportWatermark? watermark;

  List<ExportSourcePage> get selectedPages => pages
      .where((page) => selectedPageNumbers.contains(page.pageNumber))
      .toList(growable: false);
}

class ExportPreview {
  const ExportPreview({required this.pageNumber, required this.jpegBytes});
  final int pageNumber;
  final Uint8List jpegBytes;
}

class PreparedSecureExport {
  factory PreparedSecureExport({
    required List<File> files,
    required int pageCount,
    required bool hadWatermark,
    required bool hadRedactions,
    required Future<void> Function() onDispose,
  }) => PreparedSecureExport._(
    files: files,
    pageCount: pageCount,
    hadWatermark: hadWatermark,
    hadRedactions: hadRedactions,
    onDispose: onDispose,
  );

  PreparedSecureExport._({
    required this.files,
    required this.pageCount,
    required this.hadWatermark,
    required this.hadRedactions,
    required this._onDispose,
  });

  /// Private temporary files. They must be handed directly to an OS picker or
  /// share sheet and never surfaced as an application-visible path.
  final List<File> files;
  final int pageCount;
  final bool hadWatermark;
  final bool hadRedactions;
  final Future<void> Function() _onDispose;
  Future<void>? _disposeFuture;

  Future<void> dispose() => _disposeFuture ??= _onDispose();
}

abstract interface class SecureShareDestination {
  /// Resolves only after the platform share UI has been dismissed. A true
  /// result means the OS accepted the handoff; it never identifies recipients.
  Future<bool> share({required List<File> files, required String mimeType});
}

/// A vetted native implementation must rasterize requested PDF pages. The
/// returned pixels become JPEG exports, so annotations, text, attachments and
/// other recoverable PDF structures cannot survive redaction.
abstract interface class SecurePdfExportRasterizer {
  Future<List<Uint8List>> rasterizeSelectedPages({
    required File privatePdf,
    required Set<int> pageNumbers,
  });
}
