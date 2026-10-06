# Document Vault BD --- Sprint-wise Technical Implementation Plan

**Product:** Document Vault BD\
**Platform:** Android and iOS\
**Recommended framework:** Flutter\
**Architecture:** Offline-first, local-only core\
**Backend:** None\
**Remote application database:** None\
**Primary local database:** Drift + SQLite\
**State management:** Riverpod\
**Languages:** বাংলা and English\
**Target market:** Bangladesh

------------------------------------------------------------------------

# 1. Purpose

This document converts the approved Document Vault BD feature
specification and technical design into an implementation-oriented
sprint plan.

The plan prioritizes the highest-risk technical areas early:

-   Vault encryption.
-   Key management.
-   PIN and biometric access.
-   Encrypted file storage.
-   Database security.
-   Search over protected metadata.
-   Backup encryption.
-   Safe restore.
-   Process-death and failure recovery.

The goal is to avoid building the entire user interface before
validating the architecture required to protect user documents.

------------------------------------------------------------------------

# 2. Recommended Delivery Model

Recommended cadence:

-   **Sprint length:** 2 weeks.
-   **Team:** 2--4 engineers depending on schedule.
-   **QA:** Continuous from Sprint 1.
-   **Security review:** Continuous, with dedicated hardening sprints.
-   **Design:** At least one sprint ahead of implementation.

Suggested roadmap:

  Phase         Sprints Focus
  ---------- ---------- -------------------------------------------------
  Phase 0      Sprint 0 Architecture and security spikes
  Phase 1          1--3 Foundation, vault security, persistence
  Phase 2          4--7 Core document management
  Phase 3         8--10 Search, reminders, lifecycle
  Phase 4        11--12 Backup, restore, migration
  Phase 5        13--14 Settings, localization, UX completeness
  Phase 6        15--16 Hardening, performance, security, release
  Post-MVP          17+ OCR, cloud backup, redaction, advanced features

A smaller team can extend sprint durations or split larger sprints
without changing dependency order.

------------------------------------------------------------------------

# 3. Definition of Done

A task is not considered complete until applicable items are satisfied:

-   Implementation completed.
-   Code reviewed.
-   Unit tests added.
-   Integration tests added where applicable.
-   Error states implemented.
-   বাংলা and English strings added.
-   Accessibility semantics included.
-   No sensitive data written to logs.
-   Security implications reviewed.
-   Database migrations included if schema changed.
-   Android tested.
-   iOS tested.
-   Process-death/app-restart behavior considered.
-   Documentation updated.
-   Acceptance criteria passed.

------------------------------------------------------------------------

# 4. Engineering Standards

Every sprint should maintain:

-   Feature-oriented Clean Architecture.
-   Riverpod for state/application orchestration.
-   Repository abstraction around persistence.
-   Typed failures.
-   Immutable domain models where practical.
-   UUID identifiers.
-   Explicit database migrations.
-   Private application storage.
-   No plaintext sensitive documents.
-   No hardcoded encryption keys.
-   No remote application database.
-   No remote analytics in MVP.
-   No document content in logs.

------------------------------------------------------------------------

# 5. Sprint 0 --- Architecture, Security and Technical Spikes

## Objective

Validate critical architectural decisions before production feature
development begins.

## 5.1 Project Architecture Decisions

Tasks:

-   Create ADR template.
-   Write ADR-001: Flutter framework.
-   Write ADR-002: Riverpod state management.
-   Write ADR-003: Drift/SQLite persistence.
-   Write ADR-004: Local device as source of truth.
-   Write ADR-005: No backend for MVP.
-   Define feature-module boundaries.
-   Define dependency rules.
-   Define coding conventions.
-   Define error-handling conventions.
-   Define test directory conventions.

## 5.2 Database Encryption Spike

Tasks:

-   Evaluate current encrypted SQLite options compatible with Flutter.
-   Prototype encrypted database creation.
-   Prototype database unlock.
-   Test wrong-key behavior.
-   Test database reopening.
-   Benchmark startup.
-   Verify Android support.
-   Verify iOS support.
-   Document limitations.
-   Decide full DB encryption vs hybrid field encryption.

Deliverable:

`ADR-006 Database Encryption Strategy`

## 5.3 File Encryption Spike

Tasks:

-   Implement proof-of-concept authenticated file encryption.
-   Use approved AEAD primitive such as AES-256-GCM.
-   Generate unique nonce per encryption operation.
-   Define versioned encrypted file envelope.
-   Encrypt sample JPG.
-   Encrypt sample PDF.
-   Decrypt and validate.
-   Tamper ciphertext and confirm authentication failure.
-   Test large files.
-   Measure memory usage.
-   Test streaming/chunk strategy if required.

Deliverable:

`ADR-007 Document File Encryption Format`

## 5.4 Key Management Spike

Tasks:

-   Prototype secure random vault master key generation.
-   Prototype Android Keystore protection.
-   Prototype iOS Keychain protection.
-   Evaluate biometric-protected key access.
-   Design PIN-based key wrapping/authentication.
-   Evaluate Argon2id/scrypt/PBKDF2 implementation options.
-   Benchmark KDF on representative Android devices.
-   Define key versioning.
-   Define key rotation approach.
-   Ensure raw keys never enter logs.

Deliverable:

`ADR-008 Vault Key Hierarchy`

## 5.5 Backup Cryptography Spike

Tasks:

-   Design encrypted backup envelope.
-   Prototype passphrase-based key derivation.
-   Generate random backup salt.
-   Encrypt sample backup.
-   Verify integrity.
-   Test wrong password.
-   Test corrupted backup.
-   Benchmark a realistic 500 MB vault backup.
-   Determine streaming requirements.

Deliverable:

`ADR-009 Backup Encryption`

## 5.6 Secure Search Spike

Tasks:

-   Prototype in-memory decrypted metadata index.
-   Test 100 documents.
-   Test 1,000 documents.
-   Test 10,000 metadata records.
-   Measure unlock/index build time.
-   Verify index destruction on lock.
-   Document future searchable-encryption alternatives.

Deliverable:

`ADR-010 Secure Search Architecture`

## 5.7 Sprint Acceptance Criteria

-   Critical cryptographic approach proven on Android and iOS.
-   Database security strategy selected.
-   Key hierarchy documented.
-   Backup format direction selected.
-   Secure search strategy selected.
-   No unresolved architecture blocker remains for Sprint 1.

------------------------------------------------------------------------

# 6. Sprint 1 --- Flutter Foundation and Application Shell

## Objective

Create the production application foundation.

## 6.1 Repository and Project Setup

Tasks:

-   Create Flutter project.
-   Configure Android application ID.
-   Configure iOS bundle identifier.
-   Define dev/test/prod flavors.
-   Configure lint rules.
-   Configure formatter.
-   Add static analysis.
-   Establish branch strategy.
-   Configure CI pipeline.
-   Add unit-test execution to CI.
-   Add build verification.

## 6.2 Core Dependencies

Integrate approved versions of:

-   Riverpod.
-   Drift.
-   SQLite driver.
-   UUID library.
-   Localization packages.
-   Secure storage.
-   Biometrics.
-   File picker.
-   Image picker/camera.
-   Local notifications.
-   Path provider.
-   Cryptography libraries.

Review every dependency for:

-   Maintenance.
-   Licence.
-   Native code.
-   Security relevance.

## 6.3 Project Structure

Create:

``` text
lib/app
lib/core
lib/features
```

Create core packages:

-   Errors.
-   Result types.
-   Logging.
-   Validation.
-   Time/date abstraction.
-   UUID abstraction.
-   File abstraction.
-   Security interfaces.

## 6.4 Routing

Implement initial routes:

-   Splash.
-   Onboarding.
-   Vault setup.
-   Unlock.
-   Home.
-   Documents.
-   Scan.
-   Reminders.
-   More.

Ensure locked users cannot navigate into vault routes.

## 6.5 Theme

Implement:

-   Light theme.
-   Dark theme.
-   System theme.
-   Typography.
-   Spacing tokens.
-   Shape/radius tokens.
-   Common button styles.
-   Form styles.
-   Cards.
-   Status chips.

## 6.6 Localization Foundation

Implement:

-   English ARB.
-   Bengali ARB.
-   Runtime language switch.
-   Locale persistence.
-   Date formatting helpers.
-   Bengali-friendly typography testing.

## 6.7 Logging

Implement sanitized structured logging.

Add rules preventing:

-   Document numbers.
-   User PINs.
-   Keys.
-   Filenames.
-   OCR text.
-   Document content.

## 6.8 Tests

-   App startup test.
-   Router guard test.
-   Theme test.
-   Locale switch test.
-   Provider initialization tests.

## 6.9 Sprint Deliverables

-   Running app shell.
-   CI pipeline.
-   Navigation.
-   Themes.
-   Localization.
-   Core abstractions.

------------------------------------------------------------------------

# 7. Sprint 2 --- Vault Creation, PIN, Biometrics and Lock Lifecycle

## Objective

Implement the secure vault lifecycle.

## 7.1 First Launch

Screens:

-   Welcome.
-   Language selection.
-   Privacy explanation.
-   Local-storage explanation.
-   Create PIN.
-   Confirm PIN.
-   Enable biometrics.
-   Setup complete.

## 7.2 Vault Creation Service

Tasks:

-   Generate vault UUID.
-   Generate cryptographically secure vault master key.
-   Create vault security metadata.
-   Wrap/protect key using approved design.
-   Persist only protected key material.
-   Initialize secure database.
-   Create initial vault record.

## 7.3 PIN

Implement:

-   PIN setup.
-   PIN confirmation.
-   PIN validation.
-   Failed attempt counter.
-   Attempt delay/rate limiting.
-   Change PIN.
-   Secure verifier/key wrapper.

Do not store raw PIN.

## 7.4 Biometric Authentication

Implement:

-   Capability detection.
-   Enable/disable.
-   Face ID/Touch ID/BiometricPrompt flow.
-   Fallback to PIN.
-   Handle changed biometric enrollment.
-   Handle temporarily unavailable biometrics.

## 7.5 Lock State

Implement:

-   Manual lock.
-   Immediate lock.
-   Background timeout.
-   Configurable timeout architecture.
-   Clear sensitive caches on lock.
-   Clear secure search state.
-   Remove temporary decrypted files.

## 7.6 App Switcher Privacy

Android:

-   Apply approved screenshot/privacy mechanism.

iOS:

-   Cover sensitive UI before app snapshot.

## 7.7 Security Tests

Test:

-   Correct PIN.
-   Wrong PIN.
-   Repeated wrong PIN.
-   Biometrics success.
-   Biometrics failure.
-   Biometrics unavailable.
-   Background/foreground.
-   Process restart.
-   Manual lock.
-   Key retrieval failure.

## 7.8 Sprint Deliverables

-   Secure vault setup.
-   PIN unlock.
-   Biometric unlock.
-   Lock lifecycle.
-   Privacy protection.

------------------------------------------------------------------------

# 8. Sprint 3 --- Database, Repositories and Secure File Storage

## Objective

Build production persistence foundations.

## 8.1 Drift Database

Create initial tables:

-   Vault.
-   FamilyMember.
-   DocumentCategory.
-   Document.
-   DocumentOwner.
-   DocumentFile.
-   DocumentPage.
-   DocumentFieldValue.
-   Tag.
-   DocumentTag.
-   PhysicalLocation.
-   Reminder.
-   BackupRecord.
-   AppSetting.
-   PendingOperation.

## 8.2 Constraints

Implement:

-   Primary keys.
-   Foreign keys.
-   Unique constraints.
-   Required fields.
-   Cascade/restrict behavior.

## 8.3 Indexes

Add indexes for:

-   Category.
-   Owner.
-   Expiry date.
-   Created/updated dates.
-   Favorite.
-   Archive.
-   Trash.
-   Reminder schedule.

## 8.4 Repository Layer

Implement interfaces and concrete repositories:

-   VaultRepository.
-   FamilyRepository.
-   CategoryRepository.
-   DocumentRepository.
-   TagRepository.
-   ReminderRepository.
-   SettingsRepository.

## 8.5 Secure File Storage

Implement:

-   Private vault directory.
-   Generated filenames.
-   Encrypt file.
-   Decrypt stream/file.
-   Integrity verification.
-   Delete encrypted file.
-   Safe temporary workspace.
-   Cleanup manager.

## 8.6 File Operation Journal

Implement states:

-   Started.
-   Files written.
-   DB committed.
-   Completed.
-   Failed.

Implement startup reconciliation.

## 8.7 Migration Framework

-   Set schema version.
-   Create migration test harness.
-   Add test fixtures.
-   Document migration policy.

## 8.8 Tests

-   CRUD repository tests.
-   Transaction tests.
-   Encryption/decryption tests.
-   Tampered file tests.
-   Interrupted operation tests.
-   Orphan cleanup tests.

## 8.9 Sprint Deliverables

-   Production local persistence.
-   Encrypted file service.
-   Repository layer.
-   Migration framework.
-   Operation recovery.

------------------------------------------------------------------------

# 9. Sprint 4 --- Family Profiles, Categories and Tags

## Objective

Implement the organizational model around document owners.

## 9.1 Family Member List

Implement:

-   Empty state.
-   List.
-   Profile avatar.
-   Relationship.
-   Document count.

## 9.2 Add Family Member

Fields:

-   Name.
-   Nickname.
-   Relationship.
-   Date of birth.
-   Blood group.
-   Avatar.
-   Notes.

Validation:

-   Name required.
-   Relationship required.
-   Date validation.

## 9.3 Edit/Archive Member

Implement:

-   Edit.
-   Archive.
-   Restore.
-   Prevent destructive deletion when documents reference member.
-   Reassignment workflow if permanent deletion is later supported.

## 9.4 Household Ownership

Add virtual/system ownership option:

`Household / পরিবার`

## 9.5 System Categories

Seed:

-   Identity.
-   Tax and Financial.
-   Education.
-   Land and Property.
-   Vehicle.
-   Medical.
-   Marriage and Family.
-   Employment.
-   Business.
-   School and Children.
-   Travel.
-   Warranty and Purchases.
-   Legal.
-   Other.

Add relevant subcategories.

## 9.6 Tags

Implement:

-   Tag list.
-   Create.
-   Rename.
-   Delete.
-   Assign/remove.
-   Prevent duplicate normalized names.

## 9.7 Physical Storage Locations

Implement:

-   Create.
-   Edit.
-   Archive.
-   Assign to document.

## 9.8 Tests

-   Member CRUD.
-   Category seeding.
-   Tag uniqueness.
-   Ownership.
-   Archive behavior.

------------------------------------------------------------------------

# 10. Sprint 5 --- Camera Capture and Document Import

## Objective

Build secure document ingestion.

## 10.1 Add Document Entry

Implement actions:

-   Scan with camera.
-   Import image.
-   Import PDF.
-   Import file.

## 10.2 Permissions

Implement just-in-time:

-   Camera permission.
-   Photo permission where required.
-   File access through system picker.

Provide Bengali and English explanations.

## 10.3 Camera

Implement:

-   Capture.
-   Flash.
-   Retake.
-   Preview.
-   Rotate.
-   Crop integration where approved.

## 10.4 Multi-Page Capture

Implement:

-   Add page.
-   Delete page.
-   Reorder.
-   Rotate.
-   Retake.
-   Page counter.

## 10.5 File Validation

Validate:

-   MIME.
-   Signature where feasible.
-   Size.
-   Image decode.
-   PDF validity.
-   Unsupported type.

## 10.6 Import Pipeline

Implement:

-   Private temporary copy.
-   UUID assignment.
-   Integrity fingerprint.
-   Encryption.
-   Final secure write.
-   Metadata transaction.
-   Cleanup.

## 10.7 Process Interruption

Test:

-   Kill app during capture.
-   Kill during encryption.
-   Kill after file write before DB commit.
-   Restart and reconcile.

## 10.8 Low Storage

Implement:

-   Available-space check.
-   Warning.
-   Graceful failure.
-   Cleanup temporary artifacts.

## 10.9 Sprint Deliverables

-   Camera capture.
-   Gallery/file import.
-   Multi-page document ingestion.
-   Secure encrypted storage.

------------------------------------------------------------------------

# 11. Sprint 6 --- Document Metadata and Creation Workflow

## Objective

Complete the end-to-end Add Document workflow.

## 11.1 Owner Selection

Implement:

-   Single owner.
-   Multiple owners.
-   Household.
-   Search member.

## 11.2 Category Selection

Implement:

-   Category list.
-   Subcategories.
-   Recent categories.
-   Search categories.

## 11.3 Basic Metadata

Fields:

-   Title.
-   Document number.
-   Issue date.
-   Expiry date.
-   Issuing authority.
-   Description.

## 11.4 Dynamic Fields

Create field-template architecture.

Examples:

Passport:

-   Passport number.
-   Issue date.
-   Expiry date.
-   Authority.

Warranty:

-   Brand.
-   Model.
-   Serial number.
-   Purchase date.
-   Warranty end.

## 11.5 Tags and Notes

Implement:

-   Existing tags.
-   Create tag inline.
-   Notes.
-   Physical original location.

## 11.6 Validation

Implement:

-   Required title.
-   Owner.
-   Category.
-   Valid date relationships.
-   Duplicate warning hooks.

## 11.7 Save

Implement atomic/recoverable save pipeline.

Show:

-   Saving.
-   Success.
-   Failure.
-   Retry.

## 11.8 Tests

-   Complete create flow.
-   Invalid dates.
-   Multiple owners.
-   Dynamic fields.
-   Failed encryption.
-   Failed DB write.
-   Process interruption.

------------------------------------------------------------------------

# 12. Sprint 7 --- Document Library, Details and Secure Viewer

## Objective

Allow users to efficiently browse and view vault content.

## 12.1 Document Library

Implement:

-   All documents.
-   Recent.
-   Favorites.
-   Category view.
-   Person view.
-   Archived.

## 12.2 Document Card

Display:

-   Safe thumbnail/icon.
-   Title.
-   Owner.
-   Category.
-   Expiry state.
-   Favorite state.

## 12.3 Sorting

Implement:

-   Recently added.
-   Recently updated.
-   Title.
-   Issue date.
-   Expiry.
-   Category.
-   Owner.

## 12.4 Filters

Implement:

-   Owner.
-   Category.
-   Tag.
-   Expiry state.
-   Favorite.
-   Archived.
-   File type.

## 12.5 Document Details

Implement:

-   Preview.
-   Metadata.
-   Owners.
-   Dates.
-   Tags.
-   Notes.
-   Physical location.
-   Reminder summary.
-   Created/updated information.

## 12.6 Image Viewer

Implement:

-   Zoom.
-   Pan.
-   Rotate view.
-   Full screen.
-   Page navigation.

## 12.7 PDF Viewer

Implement:

-   Secure PDF access.
-   Page navigation.
-   Zoom.
-   Thumbnails if safe.
-   Large-PDF memory management.

## 12.8 Thumbnail Service

Implement:

-   Protected thumbnail generation.
-   Cache.
-   Invalidation.
-   Cleanup on lock according to chosen architecture.

## 12.9 Performance Tests

Test:

-   1,000 documents.
-   Hundreds of thumbnails.
-   Large images.
-   100+ page PDF.
-   Rapid scrolling.

------------------------------------------------------------------------

# 13. Sprint 8 --- Secure Search and Advanced Filtering

## Objective

Implement fast search without persistent plaintext indexes.

## 13.1 Search Index Service

Implement:

-   Build after unlock.
-   Normalize searchable values.
-   Keep only in memory.
-   Update incrementally after CRUD.
-   Destroy on lock.

## 13.2 Searchable Fields

Support:

-   Title.
-   Document number.
-   Owner.
-   Category.
-   Tag.
-   Notes.
-   Issuing authority.

## 13.3 Search UI

Implement:

-   Search screen.
-   Search suggestions.
-   Recent searches if privacy design permits.
-   Clear query.
-   No results.
-   Filter integration.

## 13.4 Bengali Search

Test:

-   Bengali text.
-   English text.
-   Mixed Bengali/English.
-   Numerals.
-   Case normalization.

## 13.5 Performance

Benchmark:

-   100 records.
-   1,000 records.
-   10,000 records.

## 13.6 Security

Verify:

-   No plaintext search index on disk.
-   Search cache cleared on lock.
-   No query logging.

------------------------------------------------------------------------

# 14. Sprint 9 --- Expiry, Reminders and Local Notifications

## Objective

Implement document lifecycle reminders without a server.

## 14.1 Expiry Engine

Implement derived states:

-   Valid.
-   Expiring soon.
-   Expired.
-   No expiry.
-   Renewal in progress.

## 14.2 Reminder Rules

Default options:

-   90 days.
-   60 days.
-   30 days.
-   14 days.
-   7 days.
-   3 days.
-   1 day.
-   On date.
-   Custom.

## 14.3 Reminder Setup

Implement during:

-   Add document.
-   Edit document.
-   Document details.

## 14.4 Notification Scheduling

Implement:

-   Schedule.
-   Cancel.
-   Reschedule.
-   Snooze.
-   Complete.

## 14.5 Notification Permission

Implement:

-   Permission explanation.
-   Request.
-   Denied state.
-   Settings guidance.

## 14.6 Privacy

Default notification:

``` text
Passport renewal reminder
Expires in 30 days
```

Do not expose document numbers.

## 14.7 Reminder Dashboard

Sections:

-   Overdue.
-   Next 7 days.
-   Next 30 days.
-   Next 90 days.
-   Later.

## 14.8 Reconciliation

Run after:

-   Unlock/startup.
-   Restore.
-   Document date changes.
-   Permission changes.
-   App upgrade.

## 14.9 Tests

-   Timezone changes.
-   Date changes.
-   App restart.
-   Device reboot where testable.
-   Permission denied.
-   Notification scheduling limits.
-   Snooze.

------------------------------------------------------------------------

# 15. Sprint 10 --- Favorites, Archive, Trash and Document Lifecycle

## Objective

Complete everyday lifecycle management.

## 15.1 Favorites

Implement:

-   Favorite/unfavorite.
-   Favorites screen.
-   Quick access.

## 15.2 Archive

Implement:

-   Archive.
-   Restore.
-   Archived list.
-   Exclude archived from normal active views.

## 15.3 Trash

Implement:

-   Move to trash.
-   Trash list.
-   Restore.
-   Permanent delete.

## 15.4 Permanent Deletion

Delete:

-   Metadata.
-   Relationships.
-   Encrypted files.
-   Thumbnails.
-   Search entries.
-   Reminder schedules.

Use operation journal for recovery.

## 15.5 Automatic Trash Cleanup

Add configurable architecture.

MVP option:

-   Default 30 days.
-   User may disable.
-   User may empty manually.

## 15.6 Version Foundation

Add document-version model needed for renewals.

Implement minimal:

-   Mark old version superseded.
-   Add replacement/current version.

## 15.7 Tests

-   Restore from trash.
-   Delete with files.
-   Interrupted deletion.
-   Archived search.
-   Reminder cancellation.

------------------------------------------------------------------------

# 16. Sprint 11 --- Encrypted Backup

## Objective

Implement reliable portable vault backup.

This is a release-critical feature.

## 16.1 Backup Format

Finalize:

-   Header.
-   Manifest.
-   Database snapshot.
-   Files.
-   Integrity metadata.
-   Format version.
-   Encryption version.

## 16.2 Backup Password

Implement:

-   Enter password.
-   Confirm password.
-   Strength guidance.
-   Warning about unrecoverable password.
-   Never persist plaintext password.

## 16.3 Backup KDF

Implement approved:

-   Salt generation.
-   KDF.
-   Parameter version.
-   Backup key derivation.

## 16.4 Consistent Snapshot

Implement:

-   Backup lock.
-   Finish active writes.
-   Snapshot DB.
-   Capture file set.
-   Immutable backup inputs.

## 16.5 Packaging

Implement streaming packaging to avoid excessive memory.

## 16.6 Encryption

Encrypt complete portable package or protected payload according to ADR.

## 16.7 Verification

After creation:

-   Re-open.
-   Validate header.
-   Authenticate encrypted content.
-   Validate manifest.
-   Validate expected files/counts.
-   Mark successful only after verification.

## 16.8 Destination

Use system document provider/share-save flow.

Support:

-   Device folder.
-   User-selected storage provider exposed by OS.

## 16.9 Backup History

Store non-sensitive local metadata:

-   Date.
-   Size.
-   Verification result.
-   Destination type if safe.
-   Vault changes since backup.

## 16.10 Backup Reminder

Implement:

-   Weekly.
-   Monthly.
-   Quarterly.
-   Custom future extension.

## 16.11 Tests

-   Small vault.
-   Large vault.
-   Wrong password.
-   Storage full.
-   User cancellation.
-   Process termination.
-   Corrupted output.
-   500 MB+ stress case.

------------------------------------------------------------------------

# 17. Sprint 12 --- Restore, Recovery and Device Migration

## Objective

Guarantee that backups can actually recover user data.

## 17.1 Restore Selection

Implement:

-   File picker.
-   Backup header validation.
-   Unsupported file handling.

## 17.2 Password

Implement:

-   Password entry.
-   Wrong-password state.
-   Attempt handling.

## 17.3 Validation

Before modifying current vault:

-   Authenticate backup.
-   Check format.
-   Check encryption version.
-   Check schema version.
-   Check integrity.
-   Check free storage.

## 17.4 Restore Summary

Display:

-   Backup date.
-   Document count.
-   Family-member count.
-   Approximate size.

Do not reveal data until authentication succeeds.

## 17.5 Safety Snapshot

Before replacing active vault:

-   Create local rollback state.
-   Verify rollback state.

## 17.6 Staging Restore

Restore to:

``` text
staging_restore/
```

Then:

-   Run DB migrations.
-   Validate database.
-   Verify document files.
-   Validate references.

## 17.7 Atomic Activation

Switch staging vault into active position only after validation.

Keep previous vault temporarily for rollback.

## 17.8 Post-Restore

-   Recreate device-specific key protection.
-   Ask user to configure new app PIN if required.
-   Re-enable biometrics.
-   Rebuild search.
-   Reconcile notifications.
-   Clean old staging state.

## 17.9 Device Migration UX

Create:

-   Old phone instructions.
-   New phone instructions.
-   Backup transfer guidance.
-   Restore checklist.

## 17.10 Disaster Tests

Test:

-   App killed during restore.
-   Corrupted DB.
-   Missing file.
-   Wrong password.
-   Older schema.
-   Newer unsupported schema.
-   Low storage.
-   Failed final switch.
-   Rollback.

------------------------------------------------------------------------

# 18. Sprint 13 --- Settings, Storage Management and Privacy Controls

## Objective

Complete user configuration and vault maintenance.

## 18.1 General Settings

Implement:

-   Language.
-   Theme.
-   Date format.
-   Default view.
-   Default profile.

## 18.2 Security Settings

Implement:

-   Change PIN.
-   Biometrics.
-   Auto-lock interval.
-   Screenshot/privacy option where supported.
-   Sensitive notification preview setting.

## 18.3 Notification Settings

Implement:

-   Enable/disable expiry reminders.
-   Default reminder offsets.
-   Backup reminders.

## 18.4 Storage Management

Display:

-   Document count.
-   Page/file count.
-   Database size.
-   Attachment size.
-   Thumbnail/cache size.
-   Trash size.
-   Estimated backup size.

## 18.5 Maintenance Actions

Implement:

-   Clear safe temporary files.
-   Empty trash.
-   Find large files.
-   Integrity check.

Never silently delete originals.

## 18.6 Privacy and Permissions

Display:

-   Camera status.
-   Photo/file access status.
-   Notification status.
-   Biometric status.

Provide settings links where appropriate.

## 18.7 Help/About

Implement:

-   App version.
-   Privacy explanation.
-   Security information.
-   Backup warning.
-   Licence notices.
-   Legal disclaimer.

------------------------------------------------------------------------

# 19. Sprint 14 --- Home Dashboard, UX Completion and Accessibility

## Objective

Bring all MVP capabilities into a cohesive user experience.

## 19.1 Home Dashboard

Implement:

-   Greeting.
-   Search.
-   Lock action.
-   Quick actions.
-   Favorites.
-   Expiring soon.
-   Family shortcuts.
-   Recent documents.
-   Backup health.

## 19.2 Bottom Navigation

Finalize:

1.  Home.
2.  Documents.
3.  Scan.
4.  Reminders.
5.  More.

## 19.3 More

Include:

-   Family.
-   Categories.
-   Tags.
-   Archive.
-   Trash.
-   Backup & Restore.
-   Storage.
-   Settings.
-   Help.

## 19.4 Empty States

Implement polished states for:

-   Empty vault.
-   No family members.
-   Empty category.
-   No favorites.
-   No reminders.
-   No archive.
-   Empty trash.
-   No search results.

## 19.5 Error States

Complete:

-   Unsupported file.
-   Corrupt document.
-   Storage low.
-   Save failure.
-   Backup failure.
-   Restore failure.
-   Notification denied.
-   Biometric unavailable.
-   Database migration failure.

## 19.6 Accessibility

Audit:

-   Touch targets.
-   Screen-reader labels.
-   Focus order.
-   Contrast.
-   Text scaling.
-   Dynamic type.
-   Bengali readability.
-   Icons with text labels.

## 19.7 Localization QA

Review every screen in:

-   English.
-   বাংলা.

Check:

-   Overflow.
-   Truncation.
-   Date formatting.
-   Mixed-language content.
-   Numerals.

------------------------------------------------------------------------

# 20. Sprint 15 --- Reliability, Performance and Production Hardening

## Objective

Stress the application under real-world failure conditions.

## 20.1 Performance Dataset

Generate test vaults:

-   100 documents.
-   1,000 documents.
-   10,000 metadata records.
-   Large PDFs.
-   High-resolution scans.

## 20.2 Performance Optimization

Measure:

-   Cold launch.
-   Unlock.
-   Search index build.
-   Library scroll.
-   Search.
-   PDF opening.
-   Thumbnail generation.
-   Backup.
-   Restore.

Optimize bottlenecks.

## 20.3 Memory

Test:

-   Multi-page scan.
-   Large photos.
-   100-page PDF.
-   Repeated viewer navigation.
-   Backup/restore.

Fix:

-   Retained image buffers.
-   Undisposed controllers.
-   Excessive decrypted copies.

## 20.4 Process Death

Android scenarios:

-   Import.
-   Save.
-   Backup.
-   Restore.
-   Viewer.
-   Background.

iOS:

-   Termination.
-   Memory pressure.
-   Background transition.

## 20.5 Storage Failure

Test:

-   Storage nearly full.
-   Storage becomes full mid-operation.
-   File unavailable.
-   Permission/provider cancellation.

## 20.6 Database Integrity

Test:

-   Migration failures.
-   Interrupted transaction.
-   Orphan records.
-   Orphan files.
-   Recovery journal.

## 20.7 Reminder Reliability

Test:

-   Restart.
-   Timezone.
-   Date change.
-   Permission changes.
-   OS scheduling restrictions.

------------------------------------------------------------------------

# 21. Sprint 16 --- Security Review, Release Readiness and Production Launch

## Objective

Complete security validation and prepare store release.

## 21.1 Security Audit

Review:

-   Key generation.
-   Key storage.
-   Key wrapping.
-   PIN KDF.
-   File encryption.
-   Database encryption.
-   Nonce management.
-   Backup encryption.
-   Temporary files.
-   Search cache.
-   Logs.
-   Screenshots.
-   App-switcher snapshots.
-   Clipboard.
-   Export.
-   Restore.

## 21.2 Static Security Review

Search codebase for:

-   Hardcoded secrets.
-   Debug keys.
-   Raw SQL containing sensitive logging.
-   Unsafe random number generation.
-   Plaintext temporary files.
-   Debug print statements.

## 21.3 Dependency Audit

Review:

-   Direct dependencies.
-   Native dependencies.
-   Known vulnerabilities.
-   Licences.
-   Unmaintained packages.

## 21.4 Privacy Audit

Verify:

-   No unexpected network calls.
-   No analytics SDK.
-   No crash uploader.
-   No document upload.
-   No advertising SDK.
-   Permissions match functionality.

## 21.5 Network Test

Run application through traffic inspection.

Expected MVP behavior:

-   Core vault features require no network traffic.

Any network dependency must be understood and documented.

## 21.6 Release Builds

Android:

-   Production signing.
-   Release obfuscation where appropriate.
-   Play Store configuration.
-   Permission declarations.
-   Backup rules reviewed.

iOS:

-   Production signing.
-   App Store configuration.
-   Privacy manifest/required declarations.
-   Keychain behavior tested.

## 21.7 Store Assets

Prepare:

-   App icon.
-   Screenshots.
-   Bengali/English descriptions.
-   Privacy policy.
-   Support information.
-   Security explanation.

## 21.8 Final Regression

Run complete test matrix:

-   Fresh install.
-   Upgrade.
-   Vault setup.
-   PIN.
-   Biometrics.
-   Add/import.
-   Browse.
-   Search.
-   Reminder.
-   Archive/trash.
-   Backup.
-   Restore.
-   Language switch.
-   Dark mode.
-   Low storage.
-   Process death.

## 21.9 Release Gate

Do not release if any critical issue exists involving:

-   Data loss.
-   Backup corruption.
-   Restore failure.
-   Encryption bypass.
-   Plaintext sensitive storage.
-   Key exposure.
-   Authentication bypass.
-   Database corruption.
-   Silent document deletion.

------------------------------------------------------------------------

# 22. Post-MVP Sprint 17 --- Local OCR

## Objective

Add privacy-preserving on-device text recognition.

Tasks:

-   Select OCR engine.
-   Implement OCR abstraction.
-   Process image locally.
-   Extract text.
-   Encrypt accepted OCR metadata.
-   Add OCR progress.
-   Add OCR failure state.
-   Update secure search.
-   Add Bengali/English OCR testing.
-   Ensure temporary OCR artifacts are cleaned.

Do not send documents to remote OCR by default.

------------------------------------------------------------------------

# 23. Post-MVP Sprint 18 --- Smart Metadata and Duplicate Detection

Tasks:

-   Suggest document category.
-   Suggest title.
-   Suggest document number.
-   Suggest issue date.
-   Suggest expiry date.
-   Confidence score.
-   User confirmation.
-   Exact hash duplicate detection.
-   Metadata duplicate detection.
-   Optional perceptual-image duplicate prototype.

Never automatically overwrite user data.

------------------------------------------------------------------------

# 24. Post-MVP Sprint 19 --- Secure Sharing, Watermark and Redaction

Tasks:

-   Selected-page export.
-   Watermark.
-   Export preview.
-   Permanent image redaction.
-   PDF redaction research.
-   Flatten redaction.
-   Remove recoverable hidden data where applicable.
-   Secure temp cleanup.
-   Share audit event.

Security review is mandatory before release.

------------------------------------------------------------------------

# 25. Post-MVP Sprint 20 --- Optional Cloud Backup

## Objective

Add user-controlled cloud storage while preserving local-first
architecture.

Implement provider abstraction:

``` text
BackupProvider
```

Potential integrations:

-   Google Drive.
-   OneDrive.
-   Dropbox.

Tasks:

-   Provider authentication.
-   Upload already encrypted backup.
-   List backup versions.
-   Download.
-   Restore.
-   Provider disconnect.
-   Token secure storage.
-   Failure/retry.
-   Network state.
-   Backup version retention.

Important:

**Cloud provider never becomes the source of truth.**

------------------------------------------------------------------------

# 26. Post-MVP Sprint 21 --- Emergency Pack and Advanced Document Lifecycle

Tasks:

-   Emergency collection.
-   Explicit item selection.
-   Emergency export.
-   Encryption option.
-   Version history.
-   Renewal workflow.
-   Superseded documents.
-   Linked documents.
-   Household document relationships.

------------------------------------------------------------------------

# 27. Cross-Sprint QA Workstream

QA should not wait for Sprint 15.

Every sprint:

-   Update regression suite.
-   Test Android.
-   Test iOS.
-   Test English.
-   Test বাংলা.
-   Test light/dark.
-   Test offline.
-   Test lock/unlock.
-   Test process restart for affected features.
-   Verify no sensitive logging.

Maintain test devices representing:

-   Low/mid-range Android.
-   Current Android.
-   Current iPhone.
-   Older supported iPhone where practical.

------------------------------------------------------------------------

# 28. Cross-Sprint Security Workstream

Every PR touching sensitive areas should answer:

1.  Does this introduce plaintext sensitive storage?
2.  Does this increase decrypted-data lifetime?
3.  Does this write sensitive values to logs?
4.  Does this introduce a new temporary file?
5.  Does this expose data through notifications?
6.  Does this expose data through screenshots?
7.  Does this affect backup compatibility?
8.  Does this require a key/encryption migration?
9.  Does this affect restore?
10. What happens if the app dies midway?

------------------------------------------------------------------------

# 29. Cross-Sprint Database Workstream

For every schema change:

-   Increment schema version.
-   Write migration.
-   Add migration test.
-   Test old → new.
-   Test populated database.
-   Test rollback/recovery strategy.
-   Update backup compatibility documentation.

Never modify a production schema without migration coverage.

------------------------------------------------------------------------

# 30. Cross-Sprint Localization Workstream

Every user-facing string must:

-   Use localization keys.
-   Have English text.
-   Have Bengali text.
-   Avoid hardcoded UI strings.

Review terminology consistently.

Examples:

``` text
Documents → ডকুমেন্ট
Family → পরিবার
Backup → ব্যাকআপ
Restore → পুনরুদ্ধার
Expiring Soon → শিগগির মেয়াদ শেষ হবে
```

Use natural Bangla rather than forced literal translation.

------------------------------------------------------------------------

# 31. Cross-Sprint Accessibility Workstream

Every screen should include:

-   Semantic labels.
-   Logical focus.
-   Sufficient touch target.
-   Text scaling.
-   Contrast.
-   Error descriptions.
-   Labels not dependent on color alone.

------------------------------------------------------------------------

# 32. Cross-Sprint Documentation

Maintain:

``` text
/docs
├── architecture/
├── adr/
├── security/
├── database/
├── backup/
├── testing/
├── release/
└── troubleshooting/
```

Important documents:

-   Architecture overview.
-   Encryption design.
-   Key hierarchy.
-   Database schema.
-   Migration guide.
-   Backup specification.
-   Restore specification.
-   Security checklist.
-   Release checklist.

------------------------------------------------------------------------

# 33. Suggested Epic Breakdown

## Epic A --- Foundation

-   App shell.
-   CI. 
-   Navigation.
-   Localization.
-   Themes.

## Epic B --- Security

-   Vault.
-   PIN.
-   Biometrics.
-   Encryption.
-   Lock lifecycle.

## Epic C --- Persistence

-   Database.
-   Repositories.
-   Secure file storage.
-   Migrations.

## Epic D --- Organization

-   Family.
-   Categories.
-   Tags.
-   Locations.

## Epic E --- Document Ingestion

-   Camera.
-   Gallery.
-   Files.
-   Multi-page.

## Epic F --- Document Management

-   Metadata.
-   Library.
-   Viewer.
-   Search.

## Epic G --- Lifecycle

-   Expiry.
-   Reminders.
-   Favorites.
-   Archive.
-   Trash.

## Epic H --- Resilience

-   Backup.
-   Restore.
-   Migration.
-   Recovery.

## Epic I --- Settings and UX

-   Dashboard.
-   Settings.
-   Storage.
-   Accessibility.

## Epic J --- Release

-   Hardening.
-   Security.
-   Performance.
-   Store release.

------------------------------------------------------------------------

# 34. MVP Milestones

## Milestone 1 --- Secure Skeleton

After Sprint 3:

-   Vault can be created.
-   User can authenticate.
-   Encrypted DB/files work.
-   App can safely lock.

## Milestone 2 --- Usable Document Vault

After Sprint 7:

-   Family profiles.
-   Categories.
-   Capture/import.
-   Metadata.
-   Browse/view.

## Milestone 3 --- Daily-Use Product

After Sprint 10:

-   Search.
-   Expiry.
-   Reminders.
-   Favorites.
-   Archive.
-   Trash.

## Milestone 4 --- Recoverable Product

After Sprint 12:

-   Encrypted backup.
-   Verified restore.
-   Device migration path.

## Milestone 5 --- MVP Feature Complete

After Sprint 14:

-   Settings.
-   Dashboard.
-   Localization.
-   Accessibility.
-   Complete UI states.

## Milestone 6 --- Production Ready

After Sprint 16:

-   Security reviewed.
-   Performance validated.
-   Reliability validated.
-   Store release ready.

------------------------------------------------------------------------

# 35. High-Risk Areas

Treat the following as **red-risk work items**:

1.  Encryption-key lifecycle.
2.  PIN recovery design.
3.  Database encryption.
4.  Large encrypted file handling.
5.  Backup format.
6.  Restore atomicity.
7.  Database migration.
8.  Encryption migration.
9.  Secure search.
10. Temporary decrypted files.
11. Android process death.
12. iOS key accessibility behavior.
13. Notification scheduling reliability.
14. PDF parsing.
15. Redaction.

Do not estimate these as ordinary CRUD tasks.

------------------------------------------------------------------------

# 36. MVP Deferred Features

To control scope, defer:

-   Cloud backup SDK integration.
-   OCR.
-   AI classification.
-   Automatic metadata extraction.
-   Advanced duplicate detection.
-   Watermark.
-   Redaction.
-   Multiple independent vaults.
-   Decoy vault.
-   Direct device-to-device transfer.
-   Remote sync.
-   Web application.
-   Desktop application.

Design interfaces so these can be added later without changing the local
source-of-truth model.

------------------------------------------------------------------------

# 37. Suggested Release Testing Matrix

## Android

Test at minimum:

-   Supported minimum Android version.
-   Mid-range device.
-   Current Android.
-   Biometric and non-biometric device.
-   Low storage.
-   Process death.
-   Device restart.

## iOS

Test:

-   Minimum supported iOS.
-   Current iOS.
-   Face ID.
-   Touch ID where supported.
-   App termination.
-   Low storage.
-   Device restart.

## Vault Sizes

Test:

-   Empty.
-   10 documents.
-   100. 
-   1,000.
-   Large stress dataset.

## Files

Test:

-   JPG.
-   PNG.
-   PDF.
-   Multi-page.
-   Very large image.
-   Large PDF.
-   Corrupted image.
-   Corrupted PDF.
-   Unsupported type.

------------------------------------------------------------------------

# 38. Production Acceptance Criteria

The MVP is ready for production only when:

-   Core features work entirely offline.
-   No application backend is required.
-   Documents are encrypted at rest.
-   Sensitive metadata is protected.
-   Key material is platform-protected.
-   PIN cannot trivially reveal the vault key.
-   Biometric fallback works.
-   Vault auto-lock works.
-   App-switcher privacy works.
-   Search does not leave plaintext persistent indexes.
-   Local reminders work.
-   Backup is encrypted.
-   Every successful backup is verified.
-   Restore has passed destructive/failure testing.
-   Database migrations are tested.
-   Process-death scenarios recover.
-   No critical data-loss bugs remain.
-   No sensitive logging remains.
-   Bengali and English are complete.
-   Accessibility review passes.
-   Performance is acceptable on target mid-range devices.
-   Android and iOS release builds pass regression.
-   Privacy policy accurately describes application behavior.

------------------------------------------------------------------------

# 39. Recommended Execution Priority

If schedule pressure occurs, preserve this order:

``` text
Security
  ↓
Data integrity
  ↓
Backup/restore
  ↓
Core document workflows
  ↓
Search/reminders
  ↓
UX polish
  ↓
Advanced convenience
```

Do **not** reduce delivery time by weakening:

-   Encryption.
-   Backup verification.
-   Restore safety.
-   Migration testing.
-   Authentication.
-   File integrity.
-   Data-loss testing.

Instead, defer advanced features.

------------------------------------------------------------------------

# 40. Final Roadmap Summary

``` text
Sprint 0
Architecture + Security Spikes

Sprint 1
Flutter Foundation

Sprint 2
Vault + PIN + Biometrics

Sprint 3
Database + Encrypted File Storage

Sprint 4
Family + Categories + Tags

Sprint 5
Camera + Secure Import

Sprint 6
Document Metadata + Creation

Sprint 7
Library + Details + Viewer

Sprint 8
Secure Search + Filters

Sprint 9
Expiry + Reminders

Sprint 10
Favorites + Archive + Trash + Lifecycle

Sprint 11
Encrypted Backup

Sprint 12
Restore + Device Migration

Sprint 13
Settings + Storage + Privacy

Sprint 14
Dashboard + UX + Accessibility + Localization

Sprint 15
Reliability + Performance Hardening

Sprint 16
Security + Release Readiness

Post-MVP 17
Local OCR

Post-MVP 18
Smart Metadata + Duplicate Detection

Post-MVP 19
Watermark + Redaction + Secure Sharing

Post-MVP 20
Optional Encrypted Cloud Backup

Post-MVP 21
Emergency Pack + Advanced Lifecycle
```

------------------------------------------------------------------------

# 41. Recommended MVP Delivery Strategy

The most important implementation decision is to treat **security,
recoverability, and data integrity as product functionality rather than
infrastructure work hidden behind the UI**.

The first meaningful technical milestone should therefore prove:

> **A user can create a vault, securely store an encrypted document,
> close the app, unlock it again, retrieve the document correctly,
> create an encrypted backup, and restore that backup into a clean
> installation without any server.**

Once that vertical slice is reliable, the team can safely expand the
experience into family organization, scanning, search, reminders,
lifecycle management, and polished Bengali/English UX.

This approach significantly reduces the risk of discovering late in
development that the chosen storage, encryption, search, or backup
architecture cannot safely support the product.
