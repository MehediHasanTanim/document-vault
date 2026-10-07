# Backup specification

Portable backups use the `.dvbak` `DVBK` version-one envelope. Its public
header contains only format, encryption, KDF versions, salt, and chunk size.
The encrypted stream contains a manifest, SQLite snapshot, and encrypted
document-file containers. It exposes no document names, document numbers,
account data, provider path, or password.

The backup password derives an independent 256-bit key with versioned
PBKDF2-HMAC-SHA256 parameters and a fresh salt. Bounded AES-256-GCM chunks
authenticate the public header and sequence. Creation is successful only after
the package is re-opened, authenticated, and checked against manifest hashes,
sizes, and counts.

Capture occurs under a cooperative backup lock; output is staged privately and
streamed to an OS-selected destination. History retains only non-sensitive
date, size, verification state, coarse destination type, and change count.
See [ADR-008](../design/ADR-008_Backup_Package_Format.md).

