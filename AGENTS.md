# Document Vault BD — Development Baseline

This repository currently contains the product specifications. Treat the
documents in `docs/` as the source of truth; do not reinterpret or replace
their product, privacy, security, or UX decisions without an explicit request.

## Authoritative UX

- Follow `docs/UX/Document_Vault_BD_Detailed_UI_Specification.md` exactly for
  screen behaviour, navigation, copy intent, states, accessibility, privacy
  display rules, and Android/iOS adaptations.
- Match the visual direction in every reference image in `docs/UX/`:
  blue-forward light surfaces, dark navy typography, soft pale-blue
  backgrounds, rounded white cards, bright blue primary CTAs, colorful
  semantic status states, friendly illustrations, and English/Bangla paired
  UI labels. It should feel like a private family document organizer—not a
  generic file manager.
- Use safe-area-aware layouts, 16–20 px page padding, an 8 px spacing grid,
  large touch targets (48 dp Android / 44 pt iOS), visible form labels, and
  semantic labels. Support text scaling, TalkBack, VoiceOver, reduced motion,
  light/dark/system themes, English, and বাংলা.
- Keep the five-item navigation: Home, Documents, prominent Scan, Reminders,
  More. Hide it in onboarding, lock, camera, full-screen viewer, and critical
  backup/restore flows.
- Include the specified loading, empty, permission, save/error, destructive,
  backup/restore, migration, and recovery states whenever a feature needs
  them. Do not rely on color alone for status.

## Privacy and Product Non-Negotiables

- The product is offline-first and local-only: no app account, backend,
  remote application database, remote analytics, or silent uploads.
- The device vault is the source of truth. Any future cloud integration is a
  user-controlled destination for already encrypted backups only.
- Never expose full document numbers by default; mask details, show no
  sensitive lock-screen notifications, obscure app-switcher content, avoid
  sensitive filenames, and warn clearly before export/share.
- Use explicit, well-explained confirmation for archive, trash, permanent
  delete, restore replacement, and other destructive operations.
- Support Bangladesh-first categories and familiar terminology (NID, TIN,
  Khatian/খতিয়ান, Mutation/নামজারি, etc.), family members, household ownership,
  physical-original locations, expiry/reminder workflows, and bilingual copy.

## Architecture and Delivery

- Target Flutter + Dart, Riverpod, feature-oriented Clean Architecture,
  Drift/SQLite, private app storage, UUIDs, typed failures, and explicit
  migrations, as defined in `docs/design/Document_Vault_BD_Technical_Design.md`.
- Encrypt sensitive data at rest; use reviewed cryptography and platform key
  protection (Android Keystore/iOS Keychain). Do not hardcode keys or log PINs,
  keys, document content, full numbers, sensitive filenames, or OCR output.
- Encrypt document files in private storage; retain no long-lived plaintext
  copies. Secure search is in-memory after unlock and cleared on lock.
- Backup must be encrypted, verified before success, and restore through a
  staged, validated, atomic replacement with rollback protection.
- Follow the sprint order and definition of done in
  `docs/plan/Document_Vault_BD_Sprintwise_Technical_Implementation_Plan.md`.
  Every implementation includes appropriate tests, bilingual strings,
  accessibility, error states, privacy review, and Android/iOS consideration.
