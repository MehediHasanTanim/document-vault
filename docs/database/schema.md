# Database schema

The authoritative schema is `lib/core/database/vault_database.dart`.
`VaultDatabase.currentSchemaVersion` is currently **6**. Sensitive user text
is stored in encrypted columns; the schema does not store raw vault keys.

## Primary groups

| Group | Tables |
| --- | --- |
| Vault and people | `vaults`, `family_members`, `physical_locations` |
| Documents | `documents`, `document_versions`, `document_owners`, `document_files`, `document_pages`, `document_field_values` |
| Organisation | `document_categories`, `tags`, `document_tags`, `document_links`, `emergency_collection_items` |
| Lifecycle | `reminders`, `backup_records`, `share_audit_events`, `pending_operations` |
| Configuration | `app_settings` |

Foreign keys express cascade/set-null behavior for document relationships;
indexes support category, owner, expiry, created/updated time, favorite,
archive, trash, reminder scheduling, and relationship lookups. See the
[migration guide](migration-guide.md) before changing any table or index.

