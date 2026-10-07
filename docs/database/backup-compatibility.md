# Database and backup compatibility

This document records the supported boundary between database migrations and
portable backups. It must be updated in the same pull request as a production
schema, backup format, envelope, or KDF compatibility change.

## Current supported versions

| Contract | Current version | Compatibility rule |
| --- | ---: | --- |
| SQLite/Drift vault schema | 6 | Restore accepts a schema at or below 6, then migrates it forward before activation. A schema above 6 is rejected without touching the active vault. |
| Portable backup format | 1 | The public header must match exactly before extraction. |
| Portable backup encryption envelope | 1 | The authenticated envelope version must match exactly. |
| Backup KDF parameters | 1 | The version, PBKDF2-HMAC-SHA256 algorithm, 256-bit output, and supported iteration range are validated before use. |

## Schema-change requirements

A database schema change does not by itself require a portable-backup format
bump. It does require all of the following:

1. The current app can restore a supported older backup, migrate its staged
   database, validate SQLite integrity and foreign keys, validate encrypted
   file references, and activate only after a verified rollback snapshot.
2. The current app rejects a backup database whose schema is newer than it
   supports before it reveals protected summary data or replaces the active
   vault.
3. Migration fixtures and backup/restore tests cover the old → new schema
   boundary. New fields must have a backward-safe default or an explicit data
   migration.
4. If a migration changes encrypted metadata/file meaning, envelope handling,
   or key derivation, update the corresponding independent format version and
   add read-old/write-new, verification, interruption, and rollback coverage.

## Recovery contract

Backups restore into private staging. The staged database is migrated and
validated before activation; the active vault has a verified rollback copy;
activation uses recoverable rename operations and a startup recovery marker.
Thus a failed migration or unsupported schema never silently replaces the
active vault. See [ADR-009](../design/ADR-009_Staged_Restore_and_Recovery.md).
