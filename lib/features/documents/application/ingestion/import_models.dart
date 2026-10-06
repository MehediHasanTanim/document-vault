import 'dart:io';

enum ImportSource { camera, photos, pdf, file }

class SelectedImportFile {
  const SelectedImportFile({
    required this.file,
    required this.source,
    this.declaredMimeType,
    this.rotation = 0,
  });
  final File file;
  final ImportSource source;
  final String? declaredMimeType;
  final int rotation;
}

class StagedImportFile {
  const StagedImportFile({
    required this.file,
    required this.source,
    required this.mimeType,
    required this.sizeBytes,
    this.rotation = 0,
  });
  final File file;
  final ImportSource source;
  final String mimeType;
  final int sizeBytes;
  final int rotation;

  StagedImportFile copyWith({int? rotation}) => StagedImportFile(
    file: file,
    source: source,
    mimeType: mimeType,
    sizeBytes: sizeBytes,
    rotation: rotation ?? this.rotation,
  );
}

class FileValidationResult {
  const FileValidationResult({required this.mimeType, required this.sizeBytes});
  final String mimeType;
  final int sizeBytes;
}
