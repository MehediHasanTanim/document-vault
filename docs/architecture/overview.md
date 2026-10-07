# Architecture overview

Document Vault BD is an offline-first Flutter application. The device vault is
the source of truth: there is no app account, backend, remote application
database, or analytics pipeline. Optional cloud providers receive only a
user-selected, already encrypted backup package.

## Main boundaries

```text
Presentation (Flutter + Riverpod)
        ↓
Feature application services and typed failures
        ↓
Repositories / Drift SQLite / operation journal
        ↓                         ↓
Private encrypted files       Platform secure storage and OS integrations
```

- **Presentation:** feature-oriented Flutter screens, generated localization,
  accessibility defaults, and lock-aware routing.
- **Application:** validation, document lifecycle, reminder scheduling,
  search, backup/restore, and recovery orchestration.
- **Persistence:** Drift schema and repositories retain encrypted metadata,
  safe identifiers, relationships, and journal records. Search indexes are
  in memory only after unlock.
- **Files:** document bytes are encrypted in private app storage using
  versioned authenticated containers; temporary plaintext is bounded and
  cleaned.
- **Platform:** Android/iOS key protection, biometrics, notifications,
  document providers, privacy display controls, camera, and sharing are
  exposed through explicit adapters.

See the [technical design](../design/Document_Vault_BD_Technical_Design.md)
for the full design and the [security workstream](../testing/Cross_Sprint_Security_Workstream.md)
for change-review requirements.

