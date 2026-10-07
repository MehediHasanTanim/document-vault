# ADR-012: Optional cloud backup as encrypted portability only

## Status

Accepted architecture; provider OAuth registrations and production transport
implementations require independent provider security review.

## Decision

Cloud providers implement `BackupProvider` and receive only an already-created,
locally verified `.dvbak` encrypted package. They cannot access vault keys,
PINs, document files, metadata, search indexes, OCR, or document CRUD.

OAuth access/refresh tokens are stored only in platform secure storage. They
are never put in Drift, app settings, backups, logs, analytics, or diagnostics.
Disconnect deletes local tokens only. It does not delete cloud versions or
modify the local vault.

Downloads enter a private short-lived workspace and must go through the normal
authenticated staged restore validator. The cloud service never activates or
merges a remote vault directly.

## Provider registration gate

Google Drive, OneDrive and Dropbox client IDs, redirect URIs, PKCE browser
broker, token exchange, and transport adapters are supplied by the release
environment. They are intentionally not hardcoded. A provider cannot be
enabled until its registration, scopes, redirect handling, token rotation,
rate-limit behavior, and privacy terms have been reviewed.

The supplied OAuth descriptors request the least provider storage area
available (Google Drive app data / OneDrive app folder / Dropbox app folder)
and offline refresh capability. They do not request profile, contacts, photo,
or general-file access.

## Retention and retry

Retention removes only remote versions older than the configured last-N limit
after a new upload succeeds. A retention deletion failure never invalidates the
new cloud backup. Retries are bounded to the current encrypted staging file;
no password, token, plaintext, or durable upload queue is retained.

## Consequence

The device vault remains the source of truth. Cloud backup is optional and
offline core functionality continues to work without it.
