-- Version 1 fixture used by the v1 → v2 additive migration test.
CREATE TABLE physical_locations (
  id TEXT NOT NULL PRIMARY KEY,
  name_encrypted TEXT NOT NULL,
  description_encrypted TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
PRAGMA user_version = 1;
