# Sprint 1 dependency review

All direct packages are resolved by `pubspec.lock`, checked with `flutter pub outdated`, and must be reassessed before every release.

| Package | Purpose | Licence / maintenance review | Native or security relevance |
| --- | --- | --- | --- |
| flutter_riverpod, go_router, intl | State, routing, localization | Actively maintained ecosystem packages; review changelog for breaking API changes | No vault data persistence or cryptography |
| drift, drift_flutter | Typed SQLite access | Drift is actively maintained; database encryption choice is deferred to Sprint 0 ADR | Native SQLite/SQLCipher bindings; never use it for plaintext sensitive fields without approved encryption design |
| uuid | Local IDs | Mature package | UUIDs are identifiers, not security secrets |
| flutter_secure_storage, local_auth | Key references and biometric prompts | Platform wrappers with native code; update and test on Android/iOS | Keystore/Keychain and biometric behavior are security-critical |
| file_picker, image_picker, path_provider | Import and private paths | Native platform integrations | Validate imports and never retain plaintext temporary files |
| flutter_local_notifications | Local reminders | Actively maintained platform plugin | Use minimal notification content; platform permission behavior must be tested |
| cryptography | Reviewed cryptographic primitives | Mature Dart cryptography library | Final algorithms, nonce handling, key hierarchy, and backup KDF require Sprint 0 ADR/security review |
| shared_preferences | Non-sensitive locale preference | Mature platform plugin | Never store secrets, PINs, keys, or vault metadata |

`sqlite3_flutter_libs` and `sqlcipher_flutter_libs` are transitive compatibility packages supplied by Drift. They are not called directly. The obsolete `sqlite3_flutter_libs` package remains a no-op compatibility dependency in the current Drift toolchain; revisit it when the database-encryption ADR pins the production driver.
