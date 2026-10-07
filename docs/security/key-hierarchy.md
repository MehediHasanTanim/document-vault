# Key hierarchy

This document describes the implemented key boundaries; it never contains key
material, test secrets, or recovery passwords.

```text
User PIN + fresh salt ─PBKDF2-HMAC-SHA256→ PIN-derived wrapping key
                                                  ↓ AES-256-GCM + vault ID AAD
                                           wrapped 256-bit vault master key
                                                  ↓
                                encrypted document-file containers (DVF1)

Backup password + independent salt ─PBKDF2-HMAC-SHA256→ backup key
                                                  ↓
                                      encrypted portable backup (DVBK)
```

- The vault master key is generated randomly. It is wrapped, not derived
  directly from the six-digit PIN, and is retained only while unlocked.
- The wrapped security record is stored through platform secure storage. PINs,
  passwords, and raw keys are not stored in SQLite or logs.
- Locking destroys the in-memory master-key object and dependent in-memory
  state. Biometric unlock is an access mechanism, not an encryption algorithm.
- Backups use an independent password-derived key, salt, and explicit KDF
  version; a backup password cannot be recovered by the app.

Changing any KDF, wrapping, envelope, or key-protection contract requires an
ADR, versioned migration, verified safety backup where applicable, old-format
read coverage, and rollback/recovery tests.

