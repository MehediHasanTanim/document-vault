# Branch strategy

- `main` is always releasable and protected by pull-request review plus the quality workflow.
- Short-lived branches use `feature/<scope>`, `fix/<scope>`, `chore/<scope>`, or `security/<scope>`.
- Security, storage, migration, backup, and restore changes require explicit security review before merge.
- Release candidates are cut as `release/<version>` only when a production build and the full regression matrix pass.
