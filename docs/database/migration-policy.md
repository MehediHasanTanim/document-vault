# Database migration policy

`VaultDatabase.currentSchemaVersion` is the authoritative schema version. The
current production schema is **version 6**. Database schema versions,
encrypted-file envelope versions, and portable-backup format/KDF versions are
independent compatibility contracts.

## Required implementation sequence

Every production schema change must, in the same pull request:

1. increment `VaultDatabase.currentSchemaVersion`;
2. add an explicit, forward-only `from < N && to >= N` branch to
   `VaultDatabase._upgrade`;
3. preserve existing rows and unknown data; use additive changes where
   possible, and perform the migration inside Drift's transaction;
4. add an immutable SQL fixture for the previous released schema and a test
   that migrates a populated database from that fixture to the new version;
5. test the failure path: a failed transactional migration must leave the old
   database version and schema usable, or a risky rewrite must first create and
   verify a safety snapshot with a documented restore/recovery path; and
6. update `docs/database/backup-compatibility.md`, relevant backup/restore
   tests, and any ADR when supported versions or recovery behavior changes.

Never edit a released production schema in place without the version increment,
migration branch, fixture, and coverage above. Do not use a destructive
downgrade. The app migrates forward only; an older app may not safely open a
vault after a newer schema migration.

## Current migration history

| Version | Change | Migration expectation |
| --- | --- | --- |
| 1 → 2 | Archive flag for physical locations | Additive column; preserve locations. |
| 2 → 3 | Document versions | Create table and lookup index. |
| 3 → 4 | Safe backup-history metadata | Additive nullable columns. |
| 4 → 5 | Share audit events | Create table and lookup index. |
| 5 → 6 | Version-history fields, emergency collection, document links | Additive version fields for v3–v5; create new relationship tables and indexes. |

## Test harness and recovery

Migration tests use `test/support/database_test_harness.dart` and immutable SQL
fixtures in `test/fixtures/`. Fixtures contain synthetic data only. Add a
fixture only when a schema is released; never rewrite an historical fixture.

The standard recovery strategy is SQLite/Drift transactional migration: on a
statement failure, the schema and `user_version` remain at the prior version
and the next launch can retry after the defect is fixed. For migrations that
rewrite encrypted metadata or files, transactional SQL alone is insufficient:
create a verified encrypted safety backup, journal progress where files are
touched, and provide staged restore/rollback before changing active data.

See [backup compatibility](backup-compatibility.md) for the restore contract.
