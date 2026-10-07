# Restore specification

Restore authenticates a selected backup before disclosing its summary or
modifying the active vault. It validates supported format/encryption/schema
versions and available capacity, streams into private `staging_restore/`, runs
database migrations and integrity/foreign-key checks, verifies encrypted-file
references, then creates and verifies a rollback snapshot.

Only a validated staged vault is activated through recoverable sibling renames
and a recovery marker. Interrupted or failed activation restores the prior
vault when one existed. Post-restore processing recreates device key
protection, requests a new PIN where required, disables biometrics pending
opt-in, rebuilds in-memory search, and reconciles notifications.

See [ADR-009](../design/ADR-009_Staged_Restore_and_Recovery.md) and
[database backup compatibility](../database/backup-compatibility.md).

