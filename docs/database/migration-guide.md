# Migration guide

Follow the [migration policy](migration-policy.md) for every production schema
change. In short: increment the version, add an explicit forward-only upgrade
branch, use a populated immutable fixture, test old → new preservation, test
transactional failure/recovery, and update backup compatibility.

Schema migration is forward-only. A backup whose schema is newer than the app
is rejected before activation. Risky rewrites involving encrypted metadata or
files additionally require a verified safety snapshot, operation/recovery
strategy, and staged restore coverage.

