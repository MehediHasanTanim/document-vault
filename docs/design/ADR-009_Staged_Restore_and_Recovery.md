# ADR-009: Staged restore and recovery

## Status

Accepted for the version-one restore path.

## Decision

A selected `.dvbak` is inspected for a supported public format header, then
authenticated with the supplied password before its content is used. The
password, corrupted ciphertext, malformed framing, and invalid manifest share
the same user-facing failure state. No backup summary is revealed before this
authentication succeeds.

The authenticated database and encrypted document containers are streamed into
private `staging_restore/<operation-id>/`. Each entry is SHA-256 checked before
its temporary file is renamed. The staged SQLite database is migrated only
forward to the current supported schema, checked with `integrity_check` and
`foreign_key_check`, and verified against every `DocumentFile` reference. A
backup with a schema newer than the app is rejected without modifying the
active vault.

Before activation, the active vault is copied to a private rollback directory
and compared file-for-file by relative path and byte length. Activation swaps
sibling private directories using rename operations, with a small recovery
marker recording `rollback_ready` and `activated`. On startup, a marker with no
active vault restores the rollback directory. Staging and marker data are
removed only after a successful finalization or recovery.

The restore path reserves three times the package size where the platform can
report available space: package extraction, the existing-vault rollback, and
filesystem overhead. The final post-restore phase recreates device key
protection, requires a new app PIN, leaves biometrics disabled until the user
opts in, rebuilds the in-memory search index, and reconciles local
notifications.

## Consequences

Restore does not require an account, server, cloud SDK, or plaintext copy.
It can use any operating-system document provider for file selection. A failed
or interrupted restore retains the old vault whenever one existed, while a new
device restore leaves no partially activated vault. Older schemas must remain
migratable by the app; removal of a migration path is a backup compatibility
change and requires a new backup format/version decision plus restore fixtures.
