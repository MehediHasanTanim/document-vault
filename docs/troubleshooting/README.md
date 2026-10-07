# Troubleshooting

Use synthetic data in reports. Never request or attach a PIN, backup password,
raw key, decrypted document, document number, filename, private path, or
unredacted device log.

| Symptom | Safe first action | Escalation reference |
| --- | --- | --- |
| Backup cannot be opened | Confirm the selected file and password; do not retry with copied passwords in logs. | [Backup specification](../backup/backup-specification.md) |
| Restore fails | Keep the current vault; check free private storage and supported versions. | [Restore specification](../backup/restore-specification.md) |
| Document integrity error | Do not overwrite/delete the original; run integrity/recovery flow. | [Encryption design](../security/encryption-design.md) |
| Startup after interruption | Unlock and allow maintenance to reconcile journal, temporary, backup, and restore state. | [Security workstream](../testing/Cross_Sprint_Security_Workstream.md) |
| Migration failure | Preserve the database, record only a safe error identifier, and use the tested restore path. | [Migration guide](../database/migration-guide.md) |

If the issue may expose data or weaken encryption, stop the rollout and follow
the [security checklist](../security/security-checklist.md).
