# Encryption design

Sensitive metadata is encrypted before persistence, and document bytes remain
inside private app storage in versioned authenticated containers. Raw vault
keys never enter the Drift database, logs, backups outside protected payloads,
or user-facing diagnostics.

## Document-file envelope

`EncryptedFileStore` writes `DVF1` containers with bounded 64 KiB chunks.
Each chunk is AES-256-GCM encrypted and authenticated with a fresh nonce. A
footer records plaintext length and SHA-256 integrity hash; reads verify the
header/version, each AEAD tag, footer, expected size, and expected hash before
accepting the stream. Writes use a hidden pending file followed by atomic
rename; failures delete the pending file.

Plaintext streaming is preferred. When a platform API needs a file, it is
materialized only in a private temporary workspace and deleted in `finally`;
startup maintenance also clears surviving workspaces.

## Boundaries and versioning

Database schema, encrypted-file envelope, backup package, backup encryption,
and KDF versions are separate contracts. Any change needs explicit
read-compatibility, migration, interruption, cleanup, and restore coverage.
See [key hierarchy](key-hierarchy.md), [security checklist](security-checklist.md),
and the [technical design](../design/Document_Vault_BD_Technical_Design.md).

