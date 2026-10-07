# Security checklist

Before merging a sensitive change, complete the ten questions in the
[security PR template](../../.github/PULL_REQUEST_TEMPLATE.md) and consult the
[security workstream](../testing/Cross_Sprint_Security_Workstream.md).

Confirm: no persistent plaintext; bounded decrypted lifetime; sanitized logs;
private temporary workspaces; generic notification content; app-switcher and
screenshot protection where supported; versioned backup/key changes; staged
restore; and an interruption/reconciliation path.

Release evidence must use synthetic data only. A failed check is release
blocking until a reviewed mitigation is implemented and tested.

