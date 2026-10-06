abstract interface class SecureFileStore {
  Future<SecureFileReference> writeEncrypted({
    required String documentId,
    required Stream<List<int>> bytes,
    required String mimeType,
  });
  Future<Stream<List<int>>> readDecrypted(SecureFileReference reference);
  Future<void> delete(SecureFileReference reference);
}

class SecureFileReference {
  const SecureFileReference({
    required this.id,
    required this.encryptedRelativePath,
    required this.mimeType,
    required this.integrityHash,
    required this.sizeBytes,
    this.encryptionVersion = 1,
  });
  final String id;
  final String encryptedRelativePath;
  final String mimeType;

  /// SHA-256 of plaintext, used to detect truncation and wrong-file swaps.
  final String integrityHash;
  final int sizeBytes;
  final int encryptionVersion;
}
