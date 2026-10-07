# Sprint 15 — Production Hardening Sign-off

## Automated release checks

Run before each release candidate:

```sh
flutter analyze
flutter test
```

The automated suite uses deterministic, in-memory synthetic vault datasets of
100, 1,000, and 10,000 metadata records. The data never uses real document
content or creates plaintext fixture files. It verifies secure search, bounded
thumbnail caching, encrypted-file streaming, import/backup/restore recovery,
database integrity, reminder reconciliation, and storage cleanup.

`VaultPerformanceMonitor` is an opt-in, in-memory recorder. It stores only
operation type, duration, and success/failure—never document identifiers,
queries, paths, filenames, or file sizes. It must be cleared on vault lock and
must not be persisted or sent off-device.

## Device sign-off matrix

These cases need physical Android and iOS devices because unit tests cannot
faithfully terminate a production process, apply memory pressure, or impose
OS/provider scheduling policy.

| Area | Scenario | Required result |
| --- | --- | --- |
| Android import | Force-stop during private copy, encryption, and DB commit | On next unlock the journal removes incomplete files; valid committed files remain. |
| Android backup/restore | Force-stop during package write, destination copy, staging, and activation | No successful history record for incomplete backup; restore returns the prior vault or completes recovery. |
| Android viewer | Background/kill while displaying a large PDF or scan | The vault locks by policy; decrypted viewer workspaces are removed after recovery. |
| iOS lifecycle | Background transition, termination, and memory warning during import/viewer/restore | No plaintext workspace survives; staging/rollback leaves a valid active vault. |
| Storage/provider | Begin with low storage, fill storage mid-operation, cancel the system provider | Privacy-safe failure is shown; partial staging/output is removed; originals remain. |
| Notifications | Change timezone/date, revoke/regrant permission, reboot where supported, exceed OS limits | Rows remain private and reconcile after unlock; notification content never includes document numbers. |

## Performance release baselines

Measure on the oldest supported production device, with a release build and a
warm-up run discarded. Record aggregate values outside the app only with tester
approval.

| Operation | Dataset / input | Target |
| --- | --- | --- |
| Cold launch | Locked vault | <= 3 s to lock screen |
| Unlock | 1,000-document vault | <= 2 s to usable home |
| Search-index build | 10,000 metadata records | <= 2 s |
| Library browse | 1,000 documents | <= 2 s to initial list |
| Search | 10,000 metadata records | <= 1 s |
| Thumbnail | High-resolution scan | <= 2 s or a safe size failure |
| PDF open | 100-page PDF | <= 3 s to first page or a safe size failure |
| Backup / restore | Representative vault, including 500 MB+ stress run | Complete without unbounded memory growth; validate recovery after interruption |

Performance telemetry is diagnostic only. It must never contain vault content
and must not be persisted, logged remotely, or used for analytics.
