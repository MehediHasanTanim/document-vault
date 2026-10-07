-- Immutable, synthetic version 1 fixture used by forward migration tests.
CREATE TABLE physical_locations (
  id TEXT NOT NULL PRIMARY KEY,
  name_encrypted TEXT NOT NULL,
  description_encrypted TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
INSERT INTO physical_locations (
  id, name_encrypted, description_encrypted, created_at, updated_at
) VALUES ('fixture-location-1', 'encrypted-location', 'encrypted-note', 1, 1);

CREATE TABLE backup_records (
  id TEXT NOT NULL PRIMARY KEY,
  relative_path TEXT NULL,
  created_at INTEGER NOT NULL,
  size_bytes INTEGER NOT NULL,
  verified INTEGER NOT NULL
);
INSERT INTO backup_records (
  id, relative_path, created_at, size_bytes, verified
) VALUES ('fixture-backup-1', NULL, 1, 512, 1);

PRAGMA user_version = 1;
