# ADR-008: Portable encrypted backup package

## Status

Accepted for the version-one mobile backup format, pending representative-device
performance sign-off before release.

## Decision

Document Vault BD writes a `.dvbak` package with a non-sensitive binary header
followed by bounded AES-256-GCM encrypted chunks. The header contains only the
format/encryption/KDF versions, PBKDF2-HMAC-SHA-256 parameters, a fresh 16-byte
random salt, and the chunk size. It contains no document names, identifiers,
or account data.

The encrypted payload contains a manifest, SQLite database snapshot, and raw
encrypted document-file containers. Each payload chunk authenticates the exact
header and its sequence number as AEAD associated data, preventing header
tampering, reordering, truncation, and undetected trailing bytes.

Version one derives an independent 256-bit backup key with
PBKDF2-HMAC-SHA-256, 310,000 iterations, and the unique salt. PBKDF2 is used
because it is the reviewed cross-platform primitive available through the
current cryptography dependency; the parameter version is explicit and future
formats can migrate to Argon2id or scrypt after device benchmarking and review.
Passwords are supplied only for creation/verification and are never written to
SQLite, settings, backups outside the encrypted payload, diagnostics, or logs.

## Verification and lifecycle

The package is first written in private app storage. It is re-opened with the
password, every AEAD chunk is authenticated, and the manifest's count, sizes,
and SHA-256 values are checked before it is offered to a destination. The final
save is streamed through an OS document provider or a selected device folder.
History records only date, verified size, coarse destination type, and change
count; no pathname, destination URI, provider account, or password is stored.

The snapshot gate waits for cooperative app writes and prevents new ones while
the SQLite snapshot and encrypted-file set are captured. Interrupted staging
files remain private and are removed on next startup by `BackupWorkspaceCleanup`.

## Consequences

Backups can be stored with a device folder or any OS-exposed provider without
adding a cloud SDK or account. A forgotten backup password is unrecoverable.
The 500 MB profile is a manual release-device stress test because running it in
the ordinary unit-test suite would not represent Android/iOS storage behavior.
