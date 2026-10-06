import 'dart:typed_data';

import 'package:image/image.dart' as image;

import '../../../../core/errors/app_failure.dart';
import '../../../../core/files/file_reference.dart';

/// An in-memory-only thumbnail cache. It is protected by the already-unlocked
/// process boundary, has a hard byte budget, and must be cleared on vault lock.
class ProtectedThumbnailService {
  ProtectedThumbnailService(
    this._files, {
    this.maxEntries = 200,
    this.maxBytes = 24 * 1024 * 1024,
    this.maxSourceBytes = 32 * 1024 * 1024,
  });

  final SecureFileStore _files;
  final int maxEntries;
  final int maxBytes;
  final int maxSourceBytes;
  final _cache = <String, Uint8List>{};
  var _bytes = 0;

  int get entryCount => _cache.length;
  int get cachedBytes => _bytes;

  Future<Uint8List?> thumbnail(
    SecureFileReference reference, {
    int maxDimension = 240,
  }) async {
    if (!reference.mimeType.startsWith('image/')) return null;
    final key = '${reference.id}:$maxDimension';
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return cached;
    }
    final source = BytesBuilder(copy: false);
    await for (final chunk in await _files.readDecrypted(reference)) {
      if (source.length + chunk.length > maxSourceBytes) {
        throw const StorageFailure(
          'This image is too large to preview safely.',
        );
      }
      source.add(chunk);
    }
    final decoded = image.decodeImage(source.takeBytes());
    if (decoded == null) {
      throw const StorageFailure('This image preview could not be decoded.');
    }
    final resized = image.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? maxDimension : null,
      height: decoded.height > decoded.width ? maxDimension : null,
      interpolation: image.Interpolation.average,
    );
    final value = Uint8List.fromList(image.encodeJpg(resized, quality: 80));
    _put(key, value);
    return value;
  }

  void invalidate(String fileId) {
    final keys = _cache.keys
        .where((key) => key.startsWith('$fileId:'))
        .toList();
    for (final key in keys) {
      final value = _cache.remove(key);
      if (value != null) _bytes -= value.lengthInBytes;
    }
  }

  void clear() {
    _cache.clear();
    _bytes = 0;
  }

  void _put(String key, Uint8List value) {
    while (_cache.isNotEmpty &&
        (_cache.length >= maxEntries ||
            _bytes + value.lengthInBytes > maxBytes)) {
      final oldest = _cache.keys.first;
      _bytes -= _cache.remove(oldest)!.lengthInBytes;
    }
    // A single oversize thumbnail isn't retained, but can still be used by
    // the requesting view for this frame.
    if (value.lengthInBytes > maxBytes) return;
    _cache[key] = value;
    _bytes += value.lengthInBytes;
  }
}
