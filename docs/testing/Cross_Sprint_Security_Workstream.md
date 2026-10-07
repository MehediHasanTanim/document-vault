# Cross-Sprint Security Workstream

This workstream applies to every pull request. It turns the repository's
privacy and recovery requirements into reviewable evidence; it does not grant
an exception to the local-only, encrypted-vault model.

## When the full review is mandatory

Complete all ten questions in the pull-request template when a change touches
document metadata, encrypted files, images/PDFs, OCR, search, logging,
temporary workspaces, notifications, sharing/export, platform integration,
authentication, backups, restore, database migrations, or settings that
govern those features. For unrelated presentation-only changes, state why the
change is outside this scope.

A `Yes` is not automatically a rejection. It is a change record: describe the
risk, mitigation, test evidence, and any compatibility or rollback plan. A
security reviewer must approve it before merge. Do not put real vault data,
credentials, keys, PINs, passwords, tokens, document numbers, filenames,
paths, OCR text, or private screenshots in the PR or its test evidence.

## Required answer and evidence for each question

| Review question | Required evidence before merge |
| --- | --- |
| 1. Plaintext sensitive storage | Show that persisted metadata remains encrypted and files remain in private encrypted storage. Any narrowly scoped plaintext must be private, ephemeral, documented, and removed on success, failure, lock, and restart. |
| 2. Decrypted-data lifetime | Identify when plaintext is created, who owns it, and the `finally`/dispose/lock cleanup path. Do not add caches or long-lived decrypted copies without an approved design decision. |
| 3. Sensitive logs | Use `SecureLogger` only with event IDs and sanitized scalar fields. Extend its blocked-key coverage and tests when a new sensitive field is introduced. Direct `print`/`debugPrint` calls in production Dart code are prohibited. |
| 4. New temporary file | Use a private workspace and opaque generated name. Define success, failure, cancellation, lock, and process-death cleanup; include the workspace in startup maintenance if it can survive a crash. |
| 5. Notification exposure | Keep titles/bodies generic and payloads non-sensitive. Never include document numbers, filenames, full titles, OCR text, or encrypted metadata. Verify lock-screen and denied-permission behavior on both platforms. |
| 6. Screenshot exposure | Preserve Android `FLAG_SECURE` behavior and iOS app-switcher privacy cover. Check the feature with the app backgrounded, in the switcher, and when system share/document-picker UI is active. |
| 7. Backup compatibility | Version every package/header or manifest change. State older-reader/newer-reader behavior, update fixtures, and test creation plus verification of existing supported backups. |
| 8. Key/encryption migration | Independently version envelope/key/KDF changes from database schema changes. Add an ADR or migration record, preserve supported reads, create a verified safety backup where required, and define rollback/failure behavior. |
| 9. Restore | Preserve authenticate-before-disclosure, private staging, database/file/reference validation, atomic activation, and verified rollback. Add a corrupted-input and failed-switch test for affected restore paths. |
| 10. App death midway | Identify each file/DB boundary. Use the operation journal, atomic rename, transaction, or restore marker as appropriate, and add a restart reconciliation test. |

## Non-negotiable implementation checks

- Private encrypted storage is the source of truth. Cloud providers, export
  providers, and share targets only receive explicit user-selected output.
- The database schema version, encrypted file envelope version, and backup
  package/KDF version are independent contracts. Never advance one implicitly
  because another changed.
- Public errors and QA evidence must be privacy-safe. They must not reveal
  whether a password, token, document, filename, or decrypted value was
  correct.
- Cleanup is safety-critical, not best effort: a failed cleanup must be
  reported through a typed, non-sensitive failure or included in the next
  startup reconciliation pass.
- New platform code requires Android and iOS review. iOS cannot block all
  screenshots through a public app-level API; retain the supported
  app-switcher cover and communicate that platform limitation accurately.

## Required tests by change type

| Change | Minimum automated coverage | Required manual evidence |
| --- | --- | --- |
| Encryption, files, import, OCR, sharing | round-trip, tamper/failure, cleanup, restart reconciliation | Android + iOS lock/background path; no plaintext residue in app workspace after the flow |
| Logging or error handling | sanitizer and source guard | device-log review with synthetic data only |
| Notification | scheduler content/payload and permission tests | lock-screen preview and denied-permission state on both platforms |
| Migration, backup, restore | old-fixture migration, verify, wrong-password/corruption, failed activation/rollback | supported older backup restore on a release candidate |
| Native privacy/display | source guard and relevant Dart contract tests | Android screenshots/switcher and iOS app-switcher on physical devices |

Run `flutter analyze` and the relevant `flutter test` suite before merge. The
CI workflow runs the full suite; native build and physical-device evidence is
still required for affected platform behavior. Record sign-off in the
cross-sprint QA evidence template.

## Release-blocking conditions

Do not merge or release when a sensitive change has an unanswered template
question, lacks a crash/recovery story, weakens authenticated backup/restore,
adds persistent plaintext, logs sensitive values, or removes a platform
privacy control without an explicit approved replacement.

