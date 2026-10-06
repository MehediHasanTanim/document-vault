# Document Vault BD --- Technical Design Document

**Product:** Document Vault BD\
**Document type:** Technical Design\
**Target platforms:** Android and iOS\
**Architecture:** Offline-first, local-only core\
**Backend:** None\
**Remote application database:** None\
**Primary implementation recommendation:** Flutter\
**Target market:** Bangladesh\
**Languages:** বাংলা and English

------------------------------------------------------------------------

# 1. Purpose

This document defines the technical architecture for **Document Vault
BD**, a privacy-focused mobile application for securely storing and
organizing important personal and family documents on the user's device.

The application must provide its complete core experience without a
backend server, application account, or remote database.

The system stores:

-   Document metadata.
-   Family-member profiles.
-   Images.
-   PDFs.
-   Document pages.
-   Tags.
-   Expiry information.
-   Reminders.
-   Local search indexes.
-   Settings.
-   Backup metadata.

All core information is stored locally and protected using
platform-supported cryptography.

Optional future integrations such as Google Drive, Microsoft OneDrive,
or Dropbox must operate as **user-controlled encrypted backup
destinations**, not as the application's primary database.

------------------------------------------------------------------------

# 2. Architectural Goals

The architecture must optimize for:

1.  **Privacy**
2.  **Offline operation**
3.  **Strong local security**
4.  **Reliable document storage**
5.  **Data integrity**
6.  **Simple backup and recovery**
7.  **Maintainability**
8.  **Testability**
9.  **Performance with thousands of documents**
10. **Future extensibility without requiring architectural replacement**

------------------------------------------------------------------------

# 3. Core Architectural Principles

## 3.1 Local-First

The local device is the source of truth.

Core application functionality must not depend on:

-   Internet connectivity.
-   Remote APIs.
-   Authentication servers.
-   Cloud databases.
-   Application-owned storage servers.

------------------------------------------------------------------------

## 3.2 Privacy by Architecture

Sensitive content should remain on the user's device unless the user
explicitly exports, shares, or backs it up.

The system must never silently upload:

-   Document images.
-   PDFs.
-   OCR text.
-   Document numbers.
-   Family-member information.
-   Notes.
-   Encryption keys.

------------------------------------------------------------------------

## 3.3 Encryption by Default

Sensitive database fields and document files must be encrypted at rest.

Security must use mature operating-system cryptography and reviewed
libraries rather than custom cryptographic algorithms.

------------------------------------------------------------------------

## 3.4 Separation of Metadata and Binary Files

Large document binaries should not normally be stored directly inside
database rows.

Recommended model:

-   SQLite database → structured metadata.
-   Encrypted application files → document images/PDFs.
-   Database → encrypted file references and integrity metadata.

This keeps database operations efficient and simplifies file streaming.

------------------------------------------------------------------------

## 3.5 Clean Architecture

Recommended dependency direction:

``` text
Presentation
    ↓
Application / Use Cases
    ↓
Domain
    ↑
Infrastructure / Data
```

The domain layer must not depend directly on Flutter widgets, SQLite,
filesystem APIs, or cloud-provider SDKs.

------------------------------------------------------------------------

# 4. Recommended Technology Stack

## 4.1 Application Framework

**Flutter + Dart**

Reasons:

-   One codebase for Android and iOS.
-   Mature local-storage ecosystem.
-   Good camera and document-scanning integration.
-   Strong localization support.
-   Native platform integration through plugins/platform channels.
-   Suitable for offline-first architecture.

------------------------------------------------------------------------

## 4.2 State Management

Recommended:

**Riverpod**

Use:

-   `Provider`
-   `Notifier`
-   `AsyncNotifier`
-   Family/parameterized providers where useful.

Avoid placing business logic directly inside UI widgets.

------------------------------------------------------------------------

## 4.3 Local Database

Recommended:

**Drift + SQLite**

Why Drift:

-   Typed queries.
-   Schema migrations.
-   Transactions.
-   Streams/reactive queries.
-   Good testing support.
-   Mature SQLite foundation.

Alternative:

-   SQLite through another maintained abstraction.

For this security-sensitive application, choose database encryption
strategy only after verifying current library/platform support.

------------------------------------------------------------------------

## 4.4 Secure Key Storage

Android:

-   Android Keystore.

iOS:

-   Keychain.
-   Secure Enclave-backed capabilities where appropriate.

Flutter integration should use a maintained secure-storage plugin or
native platform implementation.

------------------------------------------------------------------------

## 4.5 File Storage

Use the application's private sandbox.

Never store vault documents in a public media directory by default.

Logical structure:

``` text
vault/
├── documents/
│   ├── <document_uuid>/
│   │   ├── original/
│   │   ├── pages/
│   │   └── thumbnails/
├── temp/
├── exports/
├── backups/
└── internal/
```

Physical filenames should use generated identifiers rather than
sensitive titles.

Example:

``` text
documents/550e8400-e29b-41d4-a716-446655440000/pages/p_001.enc
```

Not:

``` text
documents/Tanim_NID_1234567890.jpg
```

------------------------------------------------------------------------

## 4.6 Localization

Recommended:

-   Flutter `intl`.
-   ARB localization files.

Example:

``` text
lib/l10n/app_en.arb
lib/l10n/app_bn.arb
```

Support runtime switching between:

-   English.
-   বাংলা.

------------------------------------------------------------------------

## 4.7 Local Notifications

Use platform local-notification scheduling.

Possible Flutter integration:

-   `flutter_local_notifications`.

Requirements:

-   No remote push service for core reminders.
-   Rebuild scheduled notifications after restore where necessary.
-   Reconcile notifications after app upgrade or device restart where
    platform behavior requires it.

------------------------------------------------------------------------

## 4.8 Biometrics

Use platform biometric authentication.

Possible Flutter integration:

-   `local_auth`.

Biometrics should unlock access to an already securely provisioned vault
key.

Do not use biometric results as the encryption algorithm itself.

------------------------------------------------------------------------

# 5. High-Level Architecture

``` text
┌──────────────────────────────────────────────┐
│                  Flutter UI                  │
│                                              │
│ Home | Documents | Scan | Reminders | More │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│             Application Layer                │
│                                              │
│ Use Cases / Commands / Queries               │
│                                              │
│ AddDocument                                  │
│ SearchDocuments                              │
│ UpdateDocument                               │
│ ScheduleReminder                             │
│ CreateBackup                                 │
│ RestoreBackup                                │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                 Domain Layer                 │
│                                              │
│ Entities                                     │
│ Value Objects                                │
│ Repository Interfaces                        │
│ Domain Services                              │
│ Business Rules                               │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│             Infrastructure Layer             │
│                                              │
│ Drift / SQLite                               │
│ Encrypted File Storage                       │
│ Keystore / Keychain                          │
│ Camera / File Picker                         │
│ Notifications                                │
│ Backup Engine                                │
│ OCR Engine (future)                          │
│ Cloud Backup Adapters (future)               │
└──────────────────────────────────────────────┘
```

------------------------------------------------------------------------

# 6. Suggested Project Structure

``` text
lib/
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   ├── router/
│   ├── theme/
│   └── localization/
│
├── core/
│   ├── crypto/
│   ├── database/
│   ├── errors/
│   ├── files/
│   ├── logging/
│   ├── notifications/
│   ├── permissions/
│   ├── security/
│   ├── storage/
│   ├── utils/
│   └── validation/
│
├── features/
│   ├── authentication/
│   ├── vault/
│   ├── home/
│   ├── documents/
│   ├── scanner/
│   ├── family/
│   ├── categories/
│   ├── tags/
│   ├── reminders/
│   ├── search/
│   ├── favorites/
│   ├── archive/
│   ├── trash/
│   ├── backup/
│   ├── restore/
│   ├── export/
│   ├── storage_management/
│   └── settings/
│
└── main.dart
```

Each feature can follow:

``` text
feature/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── value_objects/
├── application/
│   ├── providers/
│   ├── services/
│   └── use_cases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── screens/
    ├── widgets/
    └── controllers/
```

------------------------------------------------------------------------

# 7. Core Domain Model

Primary entities:

-   Vault
-   FamilyMember
-   Document
-   DocumentFile
-   DocumentPage
-   DocumentCategory
-   Tag
-   DocumentTag
-   Reminder
-   DocumentVersion
-   PhysicalStorageLocation
-   BackupRecord
-   ActivityRecord
-   AppSetting

All persistent entities should use locally generated UUIDs.

------------------------------------------------------------------------

# 8. Database Design

## 8.1 `vault`

Fields:

``` text
id
schema_version
created_at
updated_at
security_version
```

Do not store raw encryption keys.

------------------------------------------------------------------------

## 8.2 `family_members`

``` text
id UUID PK
display_name TEXT
nickname TEXT NULL
relationship TEXT
date_of_birth DATE NULL
blood_group TEXT NULL
avatar_file_id UUID NULL
notes_encrypted BLOB/TEXT NULL
is_owner BOOLEAN
is_archived BOOLEAN
created_at DATETIME
updated_at DATETIME
```

------------------------------------------------------------------------

## 8.3 `document_categories`

``` text
id UUID PK
code TEXT UNIQUE
parent_id UUID NULL
name_key TEXT NULL
custom_name TEXT NULL
is_system BOOLEAN
sort_order INTEGER
icon_key TEXT
created_at DATETIME
updated_at DATETIME
```

System categories use localization keys.

Custom categories use user-provided names.

------------------------------------------------------------------------

## 8.4 `documents`

``` text
id UUID PK
title_encrypted BLOB/TEXT
category_id UUID
primary_owner_id UUID NULL
ownership_type TEXT
document_number_encrypted BLOB/TEXT NULL
issue_date DATE NULL
expiry_date DATE NULL
issuing_authority_encrypted BLOB/TEXT NULL
description_encrypted BLOB/TEXT NULL
notes_encrypted BLOB/TEXT NULL
physical_location_id UUID NULL
status TEXT
is_favorite BOOLEAN
is_archived BOOLEAN
current_version_id UUID NULL
created_at DATETIME
updated_at DATETIME
deleted_at DATETIME NULL
```

Possible status:

``` text
active
expired
renewal_in_progress
superseded
archived
trashed
```

Expiry status can also be derived dynamically instead of persisted.

------------------------------------------------------------------------

# 9. Multi-Owner Documents

Some records may belong to multiple people.

Use:

``` text
document_owners
---------------
document_id
family_member_id
role
```

Examples:

-   Marriage certificate → spouse A + spouse B.
-   Property deed → multiple family owners.
-   Insurance policy → holder + beneficiary where needed.

------------------------------------------------------------------------

# 10. Document Files

## 10.1 `document_files`

``` text
id UUID PK
document_id UUID
file_type TEXT
mime_type TEXT
encrypted_relative_path TEXT
original_filename_encrypted TEXT NULL
file_size INTEGER
sha256_hash TEXT
encryption_version INTEGER
created_at DATETIME
```

`sha256_hash` can be used for:

-   Integrity checks.
-   Duplicate detection.
-   Backup verification.

If threat modeling determines that plaintext hashes leak meaningful
information, use keyed hashing/HMAC or another appropriate design.

------------------------------------------------------------------------

# 11. Document Pages

``` text
document_pages
--------------
id UUID PK
document_id UUID
document_file_id UUID
page_number INTEGER
encrypted_path TEXT
thumbnail_path TEXT NULL
rotation INTEGER
width INTEGER NULL
height INTEGER NULL
created_at DATETIME
```

Unique constraint:

``` text
(document_id, page_number)
```

------------------------------------------------------------------------

# 12. Custom Document Fields

Use a flexible schema.

``` text
document_field_values
---------------------
id UUID PK
document_id UUID
field_key TEXT
label_encrypted TEXT NULL
value_encrypted TEXT
value_type TEXT
sort_order INTEGER
created_at DATETIME
updated_at DATETIME
```

Types:

``` text
text
number
date
boolean
phone
email
reference
```

Avoid putting passwords/secrets into generic custom fields.

------------------------------------------------------------------------

# 13. Tags

``` text
tags
----
id UUID PK
name TEXT
normalized_name TEXT
created_at DATETIME
```

``` text
document_tags
-------------
document_id UUID
tag_id UUID
```

Unique:

``` text
(document_id, tag_id)
```

------------------------------------------------------------------------

# 14. Physical Storage Locations

``` text
physical_locations
------------------
id UUID PK
name_encrypted TEXT
description_encrypted TEXT NULL
created_at DATETIME
updated_at DATETIME
```

Examples:

-   Bedroom locker.
-   Bank locker.
-   Office cabinet.

Treat these values as sensitive.

------------------------------------------------------------------------

# 15. Reminders

``` text
reminders
---------
id UUID PK
document_id UUID
reminder_type TEXT
target_date DATE
offset_days INTEGER NULL
scheduled_at DATETIME
notification_id INTEGER NULL
status TEXT
snoozed_until DATETIME NULL
created_at DATETIME
updated_at DATETIME
```

Status:

``` text
scheduled
triggered
snoozed
completed
cancelled
```

------------------------------------------------------------------------

# 16. Document Versions

``` text
document_versions
-----------------
id UUID PK
document_id UUID
version_number INTEGER
version_label TEXT NULL
issue_date DATE NULL
expiry_date DATE NULL
created_at DATETIME
superseded_at DATETIME NULL
```

Files/pages should reference the appropriate version where version
history is enabled.

------------------------------------------------------------------------

# 17. Trash

Prefer soft deletion first:

``` text
deleted_at
```

Trash cleanup service can permanently remove:

1.  Database relationships.
2.  Encrypted document files.
3.  Thumbnails.
4.  Search index records.
5.  Reminder schedules.

Deletion must be transactionally coordinated as much as
filesystem/database boundaries allow.

------------------------------------------------------------------------

# 18. Database Indexes

Recommended indexes:

``` text
documents(category_id)
documents(primary_owner_id)
documents(expiry_date)
documents(created_at)
documents(updated_at)
documents(is_favorite)
documents(is_archived)
documents(deleted_at)

reminders(scheduled_at)
reminders(status)

document_tags(tag_id)
document_owners(family_member_id)
```

Search strategy must account for encrypted fields.

------------------------------------------------------------------------

# 19. Search Architecture

Encrypted fields cannot safely be queried using ordinary SQLite `LIKE`
without exposing plaintext.

Therefore search requires an explicit design.

## 19.1 MVP Option

After vault unlock:

1.  Load permitted searchable metadata.
2.  Decrypt in memory.
3.  Build an ephemeral in-memory normalized search index.
4.  Search the in-memory index.
5.  Destroy index when vault locks.

Suitable for moderate document counts.

------------------------------------------------------------------------

## 19.2 Advanced Option

Use a secure searchable index design after security review.

Do not store plaintext normalized document numbers or titles merely to
make search easier.

------------------------------------------------------------------------

# 20. Encryption Architecture

## 20.1 Key Hierarchy

Recommended conceptual hierarchy:

``` text
User Authentication
        ↓
Platform Protected Key Material
        ↓
Vault Master Key
        ↓
 ┌───────────────┬────────────────┐
 ↓               ↓                ↓
Database Key   File Key      Backup Key Context
```

Actual derivation should use reviewed KDF/key-separation techniques.

------------------------------------------------------------------------

## 20.2 Vault Master Key

Generate a cryptographically secure random vault master key.

Do not derive the primary encryption key directly from a short PIN.

The PIN protects access to key material through an appropriate
key-wrapping/authentication design.

------------------------------------------------------------------------

## 20.3 User PIN

The PIN should:

-   Authenticate local vault access.
-   Be processed using a slow password KDF where PIN-derived material is
    required.
-   Never be stored in plaintext.
-   Never be logged.

Possible KDF families:

-   Argon2id.
-   scrypt.
-   PBKDF2 only where platform/library constraints justify it with
    appropriate parameters.

Final parameters require benchmarking and security review.

------------------------------------------------------------------------

# 21. File Encryption

Recommended authenticated encryption:

-   AES-256-GCM, or
-   another platform-supported reviewed AEAD construction.

Each encrypted file must use:

-   Unique nonce/IV according to algorithm requirements.
-   Authentication tag.
-   Encryption format version.
-   Appropriate associated metadata if used.

Never reuse a nonce with the same key.

------------------------------------------------------------------------

# 22. Encryption Envelope

A versioned file envelope can conceptually contain:

``` text
magic
format_version
algorithm
key_version
nonce
ciphertext
authentication_tag
```

This enables future cryptographic migration.

------------------------------------------------------------------------

# 23. Database Encryption

Two strategies are possible:

## Strategy A --- Encrypted SQLite Database

Use a maintained encrypted SQLite implementation.

Advantages:

-   Broad database protection.

Challenges:

-   Flutter/platform integration.
-   Key management.
-   Migration compatibility.

## Strategy B --- Field-Level Encryption

Encrypt sensitive fields before writing to SQLite.

Advantages:

-   Explicit security boundaries.
-   Easier to selectively index non-sensitive fields.

Challenges:

-   More application complexity.
-   Search complexity.

A hybrid approach may be appropriate.

Final selection should be made during security prototyping.

------------------------------------------------------------------------

# 24. Secure Storage

Secure storage should contain only small sensitive key
material/configuration.

Do not store document binaries in Keychain/Keystore.

Possible stored items:

``` text
wrapped_vault_key
key_version
biometric_key_reference
security_configuration
```

------------------------------------------------------------------------

# 25. Biometric Unlock Flow

Conceptual flow:

``` text
User opens app
      ↓
Vault locked
      ↓
Biometric authentication
      ↓
Platform authorizes access to wrapped key
      ↓
Vault key becomes available in memory
      ↓
Open database/decrypt metadata
      ↓
Build temporary search state
      ↓
Display vault
```

On lock:

-   Clear sensitive in-memory caches.
-   Clear temporary decrypted files.
-   Clear search index.
-   Release key references where possible.

------------------------------------------------------------------------

# 26. PIN Unlock Flow

``` text
Enter PIN
   ↓
Rate-limit validation attempts
   ↓
Validate PIN-derived verifier/key wrapper
   ↓
Recover/access vault key
   ↓
Open vault
```

Repeated failures should trigger increasing delays.

Do not automatically destroy user data in the MVP.

------------------------------------------------------------------------

# 27. App Lifecycle Security

Lock the vault when:

-   Configured inactivity timeout expires.
-   App moves to background long enough.
-   User manually locks.
-   Device security state requires re-authentication.

Sensitive UI should be obscured in:

-   Android recent apps.
-   iOS app switcher.

------------------------------------------------------------------------

# 28. Document Import Pipeline

``` text
Camera / Gallery / File Picker
              ↓
Temporary private file
              ↓
Validate file type
              ↓
Validate size
              ↓
Generate UUID
              ↓
Optional image normalization
              ↓
Calculate integrity fingerprint
              ↓
Encrypt
              ↓
Write encrypted final file
              ↓
Create DB transaction
              ↓
Generate thumbnail
              ↓
Commit metadata
              ↓
Securely clean temporary artifacts
```

Failure must not leave incomplete visible documents.

------------------------------------------------------------------------

# 29. File Validation

Validate:

-   MIME type.
-   File signature where possible.
-   File size.
-   Image decoding.
-   PDF readability.
-   Page count limits where needed.

Do not trust file extensions alone.

------------------------------------------------------------------------

# 30. Thumbnail Architecture

Thumbnails should also be considered sensitive.

Options:

-   Encrypt persistent thumbnails.
-   Generate decrypted thumbnails temporarily after unlock.
-   Maintain protected cache only while vault is open.

Do not allow thumbnails to appear in public photo galleries.

------------------------------------------------------------------------

# 31. Camera and Scanner Architecture

Scanner service interface:

``` text
DocumentScanner
├── capturePage()
├── cropPage()
├── rotatePage()
├── reorderPages()
└── finalizeScan()
```

Keep scanner implementation behind an abstraction so native scanner SDKs
can be changed later.

------------------------------------------------------------------------

# 32. PDF Handling

PDF service responsibilities:

-   Validate PDF.
-   Determine page count.
-   Render preview pages.
-   Generate thumbnails.
-   Extract pages for viewing if needed.
-   Create PDFs from captured pages in advanced releases.

Avoid permanently decrypting complete PDFs into public/temp directories.

------------------------------------------------------------------------

# 33. Reminder Engine

Domain service:

``` text
ReminderScheduler
├── schedule()
├── cancel()
├── reschedule()
├── snooze()
└── reconcile()
```

------------------------------------------------------------------------

# 34. Reminder Reconciliation

Run reconciliation:

-   After app startup.
-   After restore.
-   After relevant permission changes.
-   After document expiry changes.
-   After app upgrade.
-   After timezone/date changes where relevant.

Compare:

``` text
Database reminder state
vs
Platform scheduled notification state
```

Repair discrepancies where platform APIs permit.

------------------------------------------------------------------------

# 35. Notification Privacy

Notification payload should contain minimal information.

Good:

``` text
Passport renewal reminder
Expires in 30 days
```

Avoid:

``` text
Passport AB1234567 for Mehedi Hasan expires...
```

unless the user explicitly enables detailed notifications.

------------------------------------------------------------------------

# 36. Backup Architecture

Backup is a core subsystem.

Logical backup:

``` text
DVBD Backup
├── manifest
├── database
├── documents/
├── thumbnails/   optional/rebuildable
└── integrity/
```

The entire portable backup must be encrypted.

------------------------------------------------------------------------

# 37. Backup Manifest

Example conceptual structure:

``` json
{
  "format": "dvbd",
  "backupVersion": 1,
  "schemaVersion": 5,
  "createdAt": "2026-10-06T08:00:00+06:00",
  "documentCount": 124,
  "fileCount": 289,
  "encryptionVersion": 1
}
```

Do not expose sensitive document names in an unencrypted manifest.

------------------------------------------------------------------------

# 38. Backup Encryption

A backup should use a key derived from a user backup passphrase or
another explicit secure mechanism.

Conceptual:

``` text
Backup Password
      ↓
Strong KDF + random salt
      ↓
Backup Encryption Key
      ↓
AEAD-encrypted backup package
```

The backup key should be independent from ordinary app unlock where
practical.

------------------------------------------------------------------------

# 39. Backup Creation Flow

``` text
Request Backup
      ↓
Authenticate User
      ↓
Choose/Create Backup Password
      ↓
Snapshot Database
      ↓
Collect Encrypted Vault Files
      ↓
Create Backup Package
      ↓
Encrypt/Protect Package
      ↓
Calculate Integrity Data
      ↓
Verify Package
      ↓
Move to User-Selected Destination
      ↓
Record Backup Metadata
```

Never mark a backup successful until verification completes.

------------------------------------------------------------------------

# 40. Backup Consistency

Use a consistent database snapshot.

Prevent or serialize conflicting mutations while backup snapshot
creation is underway.

Possible approach:

-   Acquire application-level backup lock.
-   Complete active write transactions.
-   Snapshot database.
-   Copy required files.
-   Release lock.

Long file packaging may continue from immutable snapshot references.

------------------------------------------------------------------------

# 41. Restore Architecture

Restore is intentionally conservative.

MVP strategy:

**Replace current vault.**

Flow:

``` text
Select Backup
     ↓
Read header
     ↓
Enter Backup Password
     ↓
Authenticate/decrypt
     ↓
Verify integrity
     ↓
Check format/schema compatibility
     ↓
Display summary
     ↓
User confirms
     ↓
Create safety snapshot of current vault
     ↓
Restore into staging directory
     ↓
Run migrations if required
     ↓
Validate restored vault
     ↓
Atomic switch
     ↓
Recreate notification schedules
     ↓
Delete old vault only after success
```

------------------------------------------------------------------------

# 42. Restore Safety

Never overwrite the active vault before the restored copy has passed
validation.

Use:

``` text
active/
staging_restore/
previous/
```

Perform final directory/database switch as atomically as platform
capabilities allow.

------------------------------------------------------------------------

# 43. Optional Cloud Backup Architecture

Future provider interface:

``` text
abstract interface BackupProvider {
  uploadBackup(...)
  listBackups(...)
  downloadBackup(...)
  deleteBackup(...)
}
```

Implementations:

``` text
GoogleDriveBackupProvider
OneDriveBackupProvider
DropboxBackupProvider
SystemFileProvider
```

Cloud providers only receive the encrypted backup artifact.

------------------------------------------------------------------------

# 44. No Cloud Database

Do not implement:

-   Firebase Firestore as primary storage.
-   Supabase database.
-   Custom REST backend.
-   Remote user-account database.

unless product requirements fundamentally change.

Cloud storage integration must not alter the local source-of-truth
model.

------------------------------------------------------------------------

# 45. Export Architecture

Export pipeline:

``` text
User selects document
       ↓
Authenticate if required
       ↓
Choose pages/options
       ↓
Decrypt into controlled temporary workspace
       ↓
Optional watermark/redaction
       ↓
Create export
       ↓
Invoke OS share/save flow
       ↓
Clean temporary export
```

------------------------------------------------------------------------

# 46. Redaction --- Future

True redaction must modify the exported raster/PDF content.

Do not implement redaction as a removable overlay layer.

For images:

1.  Decode.
2.  Apply permanent redaction.
3.  Re-encode.

For PDFs:

-   Flatten redactions into exported content.
-   Remove recoverable hidden text/objects as appropriate.

Security testing is required.

------------------------------------------------------------------------

# 47. OCR Architecture --- Future

Interface:

``` text
abstract interface OcrService {
  recognizeImage(...)
  recognizeDocument(...)
}
```

Preferred implementation:

-   On-device OCR.

Pipeline:

``` text
Encrypted document
      ↓
Temporary in-memory/private decrypted representation
      ↓
OCR
      ↓
Extracted candidate fields
      ↓
User review
      ↓
Encrypt accepted metadata
      ↓
Discard temporary OCR artifacts
```

Do not automatically upload documents to external OCR APIs.

------------------------------------------------------------------------

# 48. Smart Classification --- Future

Interface:

``` text
DocumentClassifier
```

Input:

-   Local OCR result.
-   Image features if appropriate.

Output:

``` text
categorySuggestion
confidence
fieldSuggestions
```

All suggestions require user confirmation.

------------------------------------------------------------------------

# 49. Duplicate Detection

MVP:

-   Exact file hash.
-   Same document number where available.
-   Same owner/category/important dates.

Future:

-   Perceptual image hashing.
-   OCR similarity.

Never automatically delete duplicates.

------------------------------------------------------------------------

# 50. Repository Interfaces

Example:

``` text
DocumentRepository
├── getById()
├── watchAll()
├── search()
├── insert()
├── update()
├── archive()
├── moveToTrash()
└── deletePermanently()

FamilyRepository
CategoryRepository
TagRepository
ReminderRepository
BackupRepository
SettingsRepository
```

Repositories hide persistence details from domain/application layers.

------------------------------------------------------------------------

# 51. Use Cases

Examples:

``` text
CreateVault
UnlockVault
LockVault
AddFamilyMember
UpdateFamilyMember

CaptureDocument
ImportDocument
CreateDocument
UpdateDocument
GetDocument
SearchDocuments
FavoriteDocument
ArchiveDocument
TrashDocument
RestoreTrashedDocument
DeleteDocumentPermanently

CreateReminder
SnoozeReminder
CancelReminder

CreateBackup
VerifyBackup
RestoreBackup

ExportDocument
ShareDocument

UpdateSecuritySettings
ChangePin
EnableBiometrics
```

------------------------------------------------------------------------

# 52. Error Model

Use typed domain/application failures.

Examples:

``` text
VaultLockedFailure
AuthenticationFailure
InvalidPinFailure
RateLimitedFailure

DocumentNotFoundFailure
UnsupportedFileFailure
CorruptFileFailure
InsufficientStorageFailure

EncryptionFailure
DecryptionFailure
IntegrityFailure

BackupFailure
BackupVerificationFailure
InvalidBackupPasswordFailure
IncompatibleBackupFailure

NotificationPermissionFailure
ReminderSchedulingFailure
```

UI converts technical failures into understandable bilingual messages.

------------------------------------------------------------------------

# 53. Transaction Strategy

Use SQLite transactions for related metadata operations.

Example document creation:

``` text
BEGIN
  insert document
  insert file metadata
  insert pages
  insert tags
  insert owners
  insert reminders
COMMIT
```

Filesystem writes require compensating cleanup because filesystem
operations cannot participate directly in SQLite transactions.

------------------------------------------------------------------------

# 54. File Operation Journal

For robust recovery, maintain an operation journal for critical
multi-step filesystem/database tasks.

Example:

``` text
pending_operations
------------------
id
operation_type
entity_id
state
payload
created_at
updated_at
```

States:

``` text
started
files_written
database_committed
completed
failed
```

On startup, recovery logic can reconcile interrupted operations.

------------------------------------------------------------------------

# 55. Storage Quotas and Limits

Do not impose arbitrary small limits.

However, protect the app from pathological input.

Configurable technical limits may include:

-   Maximum single import size.
-   Maximum pages per capture session.
-   Thumbnail dimensions.
-   Temporary workspace limits.

Before large operations, check available device storage.

------------------------------------------------------------------------

# 56. Low Storage Handling

If storage is low:

-   Warn before capture/import.
-   Block operations that risk corruption.
-   Offer storage-management screen.
-   Never automatically delete original documents.
-   Temporary caches may be safely cleaned.

------------------------------------------------------------------------

# 57. App Startup

Startup sequence:

``` text
Flutter initialization
      ↓
Initialize secure services
      ↓
Check database/storage existence
      ↓
Check schema version
      ↓
Run safe pre-unlock migrations if possible
      ↓
Display lock screen
      ↓
Authenticate
      ↓
Open vault
      ↓
Run post-unlock reconciliation
      ↓
Build search cache
      ↓
Schedule/reconcile reminders
```

------------------------------------------------------------------------

# 58. Database Migration

Every schema change requires an explicit migration.

Example:

``` text
v1 → v2
v2 → v3
v3 → v4
```

Migration requirements:

-   Tested with realistic old databases.
-   Transactional where possible.
-   Never silently discard unknown data.
-   Backup/safety snapshot before risky migration.
-   Record migration status.

------------------------------------------------------------------------

# 59. Encryption Migration

Encryption formats must be versioned independently of database schema.

Example:

``` text
encryption_version = 1
```

When cryptography changes:

-   Read old format.
-   Decrypt securely.
-   Re-encrypt using new format.
-   Verify.
-   Replace old encrypted artifact only after successful verification.

------------------------------------------------------------------------

# 60. Background Processing

Potential background work:

-   Thumbnail generation.
-   Backup packaging.
-   Backup verification.
-   Trash cleanup.
-   Reminder reconciliation.
-   OCR.
-   Integrity checks.

Platform restrictions differ between Android and iOS.

Do not assume indefinite background execution.

Design operations to:

-   Pause.
-   Resume.
-   Recover after termination.
-   Report progress.

------------------------------------------------------------------------

# 61. Android Considerations

Use:

-   Android Keystore.
-   Private application storage.
-   BiometricPrompt through maintained abstraction.
-   WorkManager where suitable.
-   Notification channels.
-   `FLAG_SECURE` or appropriate privacy mechanisms for protected
    screens where product requirements allow.

Test:

-   Process death.
-   Device reboot.
-   Low-memory termination.
-   Permission changes.
-   Backup/restore behavior.
-   OEM-specific notification restrictions.

------------------------------------------------------------------------

# 62. iOS Considerations

Use:

-   Keychain.
-   LocalAuthentication.
-   Application sandbox.
-   UserNotifications.
-   Background APIs only for supported use cases.

Protect sensitive app-switcher snapshots by obscuring UI when entering
background.

Test:

-   App termination.
-   Device restart.
-   Face ID/Touch ID changes.
-   Keychain accessibility behavior.
-   Notification authorization changes.

------------------------------------------------------------------------

# 63. Rooted/Jailbroken Devices

The app may detect indicators of compromised environments, but such
detection cannot guarantee security.

Recommended behavior:

-   Display a security warning.
-   Avoid claiming absolute protection.
-   Do not necessarily block all access unless security policy
    explicitly requires it.

------------------------------------------------------------------------

# 64. Logging

Use structured local diagnostic logging with strict redaction.

Never log:

-   PIN.
-   Vault keys.
-   Backup password.
-   Document number.
-   Document title if sensitive.
-   OCR output.
-   Full filesystem path containing sensitive names.
-   Document contents.

Example safe log:

``` text
document_import_failed
reason=unsupported_format
```

------------------------------------------------------------------------

# 65. Crash Reporting

For the strict local-only MVP:

-   Avoid remote crash reporting if preserving zero-network behavior is
    a core promise.

Alternative:

-   Maintain sanitized local diagnostic logs users can explicitly
    export.

If remote crash reporting is later added:

-   Explicitly document it.
-   Strip sensitive context.
-   Never attach vault files or OCR data.

------------------------------------------------------------------------

# 66. Analytics

MVP recommendation:

**No remote analytics SDK.**

If product analytics are later required, ensure:

-   No document content.
-   No document identifiers.
-   No family-member data.
-   No filenames.
-   No OCR.
-   Explicit privacy documentation.

------------------------------------------------------------------------

# 67. Testing Strategy

## Unit Tests

Test:

-   Domain rules.
-   Expiry calculations.
-   Reminder calculations.
-   Validation.
-   Search normalization.
-   Backup manifest logic.
-   Encryption wrappers.
-   Repository behavior.

## Database Tests

Test:

-   CRUD.
-   Transactions.
-   Migrations.
-   Constraints.
-   Soft deletion.
-   Cascades.
-   Interrupted operations.

## File Storage Tests

Test:

-   Encryption/decryption.
-   Partial writes.
-   Corruption.
-   Duplicate files.
-   Cleanup.
-   Low-storage failures.

## Integration Tests

Test:

-   Add document end-to-end.
-   Camera/import.
-   Backup/restore.
-   Unlock/lock.
-   Reminder scheduling.
-   Archive/trash.
-   Device migration simulation.

## Security Tests

Test:

-   No plaintext sensitive files.
-   No sensitive logs.
-   Screenshot/app-switcher protection.
-   PIN rate limiting.
-   Tampered ciphertext.
-   Modified backup.
-   Wrong backup password.
-   Temporary-file cleanup.

------------------------------------------------------------------------

# 68. Security Threat Model

Important threats:

## T1 --- Stolen unlocked/locked phone

Mitigation:

-   PIN.
-   Biometrics.
-   Auto-lock.
-   Encryption.
-   App-switcher privacy.

## T2 --- Filesystem extraction

Mitigation:

-   Encrypted files.
-   Protected keys.

## T3 --- Database extraction

Mitigation:

-   Database/field encryption.
-   No raw keys in DB.

## T4 --- Backup theft

Mitigation:

-   Independent backup encryption.
-   Strong KDF.
-   Integrity authentication.

## T5 --- Malicious imported file

Mitigation:

-   Validate formats.
-   Use safe parsers.
-   Limit resources.

## T6 --- Sensitive export leakage

Mitigation:

-   Explicit confirmation.
-   Controlled temp files.
-   Cleanup.
-   Watermark/redaction options.

## T7 --- Sensitive notification leakage

Mitigation:

-   Minimal notification content.

## T8 --- Debug/log leakage

Mitigation:

-   Redaction.
-   Production logging restrictions.

## T9 --- App process memory inspection

Mitigation:

-   Minimize plaintext lifetime.
-   Clear caches on lock.
-   Avoid unnecessary copies.

No mobile application can guarantee protection on a fully compromised
device; communicate security accurately.

------------------------------------------------------------------------

# 69. Performance Targets

Indicative goals:

-   Lock screen displayed quickly on cold launch.
-   Common metadata lists load without perceptible delay.
-   Search returns rapidly for normal household vault sizes.
-   Large images use thumbnails in lists.
-   Full-size images load only in viewer.
-   Long cryptographic/file operations show progress.
-   UI remains responsive during backup, encryption, OCR, and thumbnail
    generation.

Avoid rigid performance promises until measured on low/mid-range Android
hardware common in Bangladesh.

------------------------------------------------------------------------

# 70. Memory Management

Large document images can cause memory pressure.

Rules:

-   Decode images at required resolution.
-   Use thumbnails for lists.
-   Stream large files.
-   Avoid retaining multiple full-resolution pages.
-   Dispose controllers/resources.
-   Process multi-page scans incrementally.

------------------------------------------------------------------------

# 71. Dependency Policy

Security-sensitive application dependencies must be carefully
controlled.

For every dependency:

-   Verify active maintenance.
-   Review licence.
-   Pin compatible versions.
-   Track security advisories.
-   Avoid unnecessary SDKs.
-   Prefer smaller trusted packages.
-   Review native code where security-critical.

Generate a dependency inventory for releases.

------------------------------------------------------------------------

# 72. Build Configuration

Separate:

``` text
development
staging/test
production
```

Even without a backend, flavors help control:

-   Debug logging.
-   Test data.
-   Security diagnostics.
-   Experimental features.

Production must disable debug-only tools.

------------------------------------------------------------------------

# 73. Code Obfuscation

Use release obfuscation where appropriate.

Obfuscation is not encryption and must not be treated as a primary
security control.

------------------------------------------------------------------------

# 74. Release Security Checklist

Before release verify:

-   No debug logs.
-   No hardcoded secrets.
-   No test encryption keys.
-   No sample user data.
-   Database encryption enabled as designed.
-   File encryption enabled.
-   Backup encryption verified.
-   Screenshot/privacy controls tested.
-   Biometrics tested.
-   PIN rate limiting tested.
-   Restore tested.
-   Migration tested.
-   Temporary files cleaned.
-   App permissions minimized.
-   Dependency audit complete.

------------------------------------------------------------------------

# 75. MVP Module Breakdown

## Module 1 --- App Foundation

-   Flutter bootstrap.
-   Riverpod.
-   Routing.
-   Theme.
-   Localization.
-   Error handling.
-   Logging abstraction.

## Module 2 --- Vault Security

-   Vault creation.
-   PIN setup.
-   Secure key management.
-   Biometrics.
-   Lock/unlock.
-   Auto-lock.

## Module 3 --- Local Persistence

-   Drift database.
-   Schema.
-   Repositories.
-   Migrations.
-   Transaction utilities.

## Module 4 --- Secure File Storage

-   File encryption.
-   File decryption.
-   Thumbnail handling.
-   Integrity validation.
-   Temporary-file management.

## Module 5 --- Family Profiles

-   Create/edit/archive.
-   Profile assignment.

## Module 6 --- Categories and Tags

-   System categories.
-   Custom tags.
-   Category browsing.

## Module 7 --- Document Capture/Import

-   Camera.
-   Gallery.
-   File picker.
-   Multi-page flow.
-   Validation.

## Module 8 --- Document Management

-   CRUD.
-   Details.
-   Viewer.
-   Favorites.
-   Archive.
-   Trash.

## Module 9 --- Search and Filters

-   In-memory secure search.
-   Sorting.
-   Filtering.

## Module 10 --- Expiry and Reminders

-   Expiry calculations.
-   Reminder rules.
-   Local notifications.
-   Snooze.
-   Reconciliation.

## Module 11 --- Backup and Restore

-   Backup package.
-   Backup encryption.
-   Verification.
-   Restore staging.
-   Recovery.

## Module 12 --- Settings and Storage

-   Security settings.
-   Notification settings.
-   Language.
-   Theme.
-   Storage usage.
-   Privacy.

------------------------------------------------------------------------

# 76. Future Module Boundaries

Keep interfaces ready for:

``` text
OcrService
DocumentClassifier
CloudBackupProvider
RedactionService
WatermarkService
DeviceTransferService
IntegrityScanner
```

Do not implement unnecessary abstractions deeply until the features are
scheduled, but ensure core storage/security APIs do not prevent them.

------------------------------------------------------------------------

# 77. Suggested Development Sequence

Recommended implementation order:

``` text
Foundation
   ↓
Security prototype
   ↓
Database + encrypted file prototype
   ↓
Vault lifecycle
   ↓
Family/category domain
   ↓
Document import
   ↓
Document library/viewer
   ↓
Search/filter
   ↓
Expiry/reminders
   ↓
Archive/trash
   ↓
Backup
   ↓
Restore
   ↓
Settings/storage
   ↓
Hardening
   ↓
Security testing
   ↓
Production release
```

The **security + backup prototype should happen early**, not after the
UI is finished.

------------------------------------------------------------------------

# 78. Critical Technical Decisions Requiring Prototype

Before full development, prototype and decide:

1.  SQLite encryption implementation.
2.  Vault key hierarchy.
3.  PIN-based recovery/wrapping strategy.
4.  Biometric key access.
5.  Large encrypted PDF streaming.
6.  Encrypted thumbnail strategy.
7.  Backup archive format.
8.  Backup KDF.
9.  Restore atomicity.
10. Search over encrypted metadata.
11. Android process-death recovery.
12. iOS background/app-switcher privacy behavior.

These are architectural decisions and should not be deferred to final
sprint hardening.

------------------------------------------------------------------------

# 79. Recommended Initial Architecture Decision Records

Create ADRs for:

``` text
ADR-001 Flutter as mobile framework
ADR-002 Drift/SQLite local persistence
ADR-003 Local-only source of truth
ADR-004 Database encryption strategy
ADR-005 Document file encryption format
ADR-006 Vault key hierarchy
ADR-007 Search architecture
ADR-008 Backup package format
ADR-009 Restore replacement strategy
ADR-010 Local notification architecture
ADR-011 No remote analytics in MVP
ADR-012 Optional cloud storage as encrypted backup only
```

------------------------------------------------------------------------

# 80. Definition of Technical Success

The architecture is successful when:

1.  The application remains fully usable in airplane mode.
2.  Sensitive document files are not stored as plaintext.
3.  Sensitive database content is protected according to the approved
    encryption design.
4.  Encryption keys are not stored alongside encrypted data in an
    immediately usable form.
5.  PIN and biometric unlock work reliably.
6.  Vault content disappears from normal UI after lock.
7.  Search works without creating persistent plaintext indexes.
8.  Expiry reminders work locally.
9.  Backup files can be verified before being considered successful.
10. A new installation can restore a valid backup without a server.
11. Interrupted import/backup/restore operations recover safely.
12. Database and encryption migrations preserve user data.
13. The app performs well on realistic mid-range Android devices.
14. Bengali and English are fully supported.
15. Optional future cloud backup can be added without replacing the
    local data architecture.

------------------------------------------------------------------------

# 81. Final Recommended Architecture

The recommended production architecture is:

``` text
Flutter
  +
Riverpod
  +
Clean feature-oriented architecture
  +
Drift / SQLite
  +
Encrypted sensitive database content
  +
AES-GCM encrypted private document files
  +
Android Keystore / iOS Keychain protected key hierarchy
  +
Local notifications
  +
Encrypted portable backup
  +
No backend
  +
No remote application database
```

The most important architectural rule is:

> **The device vault is the source of truth. External storage is only a
> user-controlled encrypted portability and backup mechanism.**

This design allows Document Vault BD to remain private, reliable,
offline-capable, and appropriate for sensitive Bangladeshi family
documents while still leaving clean extension points for OCR, smart
classification, encrypted cloud backup, secure sharing, and device
migration.
