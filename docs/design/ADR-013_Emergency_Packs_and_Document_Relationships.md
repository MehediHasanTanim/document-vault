# ADR-013: Emergency packs and advanced document lifecycle

## Decision

The emergency collection is one local, opt-in list of document IDs. It has no
rule-based membership: every included document is selected explicitly. Removing
or permanently deleting a document removes its collection entry through a
database cascade.

An emergency export always starts with the secure-export pipeline. It exports
only selected, flattened pages with opaque temporary filenames; originals,
document numbers, titles, filenames, metadata and vault keys never enter the
handoff.

Users explicitly choose either:

- unencrypted flattened-image handoff, after explicit acknowledgement that it
  can be read outside the vault; or
- a password-protected `DVEP` emergency package.

`DVEP` is a distinct streamed AES-256-GCM / PBKDF2-HMAC-SHA-256 envelope. It
is not a vault backup and cannot be restored into or replace a vault. The
public header contains only format and KDF parameters. The package contains
opaque flattened image entries, and is re-open authenticated before sharing.
Temporary export and package workspaces are deleted after completion and are
eligible for startup cleanup.

Document relationships are symmetric canonical pairs and use foreign keys with
cascade deletion. Household links are accepted only when both documents are
already marked household-owned. Renewal records preserve the predecessor,
mark it superseded, retain an ordered version history, and make the replacement
current; replacement never overwrites the original document.
