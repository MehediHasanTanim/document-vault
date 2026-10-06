import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as image;

import '../../../../core/errors/app_failure.dart';
import 'import_models.dart';

/// Validates content instead of trusting a filename or Android/iOS MIME hint.
class ImportFileValidator {
  const ImportFileValidator({this.maximumBytes = 100 * 1024 * 1024});
  final int maximumBytes;

  Future<FileValidationResult> validate(
    File file, {
    String? declaredMimeType,
  }) async {
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file || stat.size <= 0) {
      throw const UnsupportedFileFailure(
        'The selected file is empty or unavailable.',
      );
    }
    if (stat.size > maximumBytes) {
      throw UnsupportedFileFailure(
        'The selected file is larger than the ${maximumBytes ~/ (1024 * 1024)} MB import limit.',
      );
    }
    final header = await _readHeader(file, 32);
    final detected = _detectMime(header);
    if (detected == null) {
      throw const UnsupportedFileFailure('This file type is not supported.');
    }
    final normalizedDeclared = _normalizeMime(declaredMimeType);
    if (normalizedDeclared != null &&
        normalizedDeclared != 'application/octet-stream' &&
        normalizedDeclared != detected) {
      throw const UnsupportedFileFailure(
        'The file type does not match its contents.',
      );
    }
    if (detected == 'application/pdf') {
      await _validatePdf(file, stat.size);
    } else {
      await _validateImage(file);
    }
    return FileValidationResult(mimeType: detected, sizeBytes: stat.size);
  }

  static Future<Uint8List> _readHeader(File file, int count) async {
    final input = await file.open();
    try {
      return Uint8List.fromList(await input.read(count));
    } finally {
      await input.close();
    }
  }

  static String? _detectMime(List<int> header) {
    if (_startsWith(header, const [0xff, 0xd8, 0xff])) {
      return 'image/jpeg';
    }
    if (_startsWith(header, const [
      0x89,
      0x50,
      0x4e,
      0x47,
      0x0d,
      0x0a,
      0x1a,
      0x0a,
    ])) {
      return 'image/png';
    }
    if (_startsWith(header, const [0x52, 0x49, 0x46, 0x46]) &&
        _startsWith(header.sublist(8), const [0x57, 0x45, 0x42, 0x50])) {
      return 'image/webp';
    }
    if (_startsWith(header, const [0x25, 0x50, 0x44, 0x46, 0x2d])) {
      return 'application/pdf';
    }
    return null;
  }

  static Future<void> _validateImage(File file) async {
    final bytes = await file.readAsBytes();
    if (image.decodeImage(bytes) == null) {
      throw const UnsupportedFileFailure(
        'The image file is corrupt or cannot be decoded.',
      );
    }
  }

  static Future<void> _validatePdf(File file, int length) async {
    if (length < 6) {
      throw const UnsupportedFileFailure('The PDF file is incomplete.');
    }
    final input = await file.open();
    try {
      await input.setPosition(length > 2048 ? length - 2048 : 0);
      final tail = await input.read(2048);
      if (!String.fromCharCodes(tail).contains('%%EOF')) {
        throw const UnsupportedFileFailure(
          'The PDF file is incomplete or corrupt.',
        );
      }
    } finally {
      await input.close();
    }
  }

  static bool _startsWith(List<int> value, List<int> prefix) =>
      value.length >= prefix.length &&
      List.generate(
        prefix.length,
        (index) => value[index] == prefix[index],
      ).every((same) => same);

  static String? _normalizeMime(String? value) =>
      value?.toLowerCase().trim().replaceFirst('image/jpg', 'image/jpeg');
}
