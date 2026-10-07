## Summary

Describe the user-visible change and the vault data it can read, write, export,
or delete. Never paste real document content, document numbers, filenames,
paths, secrets, PINs, passwords, tokens, device logs, or screenshots showing
private data.

## Security workstream review

Complete this section for every pull request that touches vault data,
encryption, files, search, sharing, backups, restore, notifications, platform
code, logging, or settings. Select one answer for every question and link the
test, ADR, or code path that supports it. A `Yes` requires a mitigation and
security-reviewer sign-off; a `No impact` still requires a short rationale.

- [ ] **1. Plaintext sensitive storage:** Does this introduce plaintext
  sensitive storage? Answer: `No impact` / `Yes — mitigation:`
- [ ] **2. Decrypted-data lifetime:** Does this increase decrypted-data
  lifetime? Answer: `No impact` / `Yes — bounded lifetime and cleanup:`
- [ ] **3. Sensitive logs:** Does this write sensitive values to logs?
  Answer: `No impact` / `Yes — redaction and reason:`
- [ ] **4. Temporary files:** Does this introduce a new temporary file?
  Answer: `No impact` / `Yes — private location, opaque name, cleanup, and
  restart recovery:`
- [ ] **5. Notification exposure:** Does this expose data through
  notifications? Answer: `No impact` / `Yes — safe title/body/payload:`
- [ ] **6. Screenshot exposure:** Does this expose data through screenshots or
  the app switcher? Answer: `No impact` / `Yes — platform mitigation:`
- [ ] **7. Backup compatibility:** Does this affect backup compatibility?
  Answer: `No impact` / `Yes — format/version/read-compatibility plan:`
- [ ] **8. Key or encryption migration:** Does this require a key or
  encryption migration? Answer: `No impact` / `Yes — version, migration, and
  rollback plan:`
- [ ] **9. Restore:** Does this affect restore? Answer: `No impact` / `Yes —
  staging, validation, and rollback coverage:`
- [ ] **10. App death midway:** What happens if the app dies midway? Answer:
  `No impact` / `Journal/reconciliation/atomicity evidence:`

## Required evidence

- [ ] Tests added or updated, including the relevant failure/interruption path.
- [ ] `flutter analyze` and the affected test suite pass.
- [ ] Manual Android and iOS checks are recorded when platform, camera, file,
  notification, app-switcher, biometric, or document-provider behavior changes.
- [ ] Backup/restore compatibility and migration fixtures are updated when a
  versioned format or schema changes.
- [ ] A security reviewer has approved any `Yes` answer above before merge.

