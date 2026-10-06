# Database migration policy

`VaultDatabase.currentSchemaVersion` is the authoritative schema version. The
current production schema is version 2. Version 2 adds archival state to
physical storage locations; its v1 → v2 migration is additive.

Every schema change must increment that constant and add an explicit,
forward-only branch to `VaultDatabase._upgrade`. A migration must preserve
unknown data, run inside Drift's migration transaction where possible, and be
tested from a populated fixture representing the previous released schema.

Before any future migration that can rewrite encrypted metadata or files, the
application must create a verified encrypted backup/safety snapshot and record
the migration outcome. Database schema migrations and encrypted-file envelope
migrations are independently versioned; never infer one from the other.

Migration tests use `test/support/database_test_harness.dart` and immutable SQL
fixtures in `test/fixtures/`. Add a fixture only when a schema is released; do
not replace a historical fixture after release.
