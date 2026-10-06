import 'package:documentvault/core/database/vault_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'v1 physical locations, versions, and backup history migrate additively',
    () async {
      final database = VaultDatabase(
        NativeDatabase.memory(
          setup: (sqlite) {
            sqlite.execute('''
        CREATE TABLE physical_locations (
          id TEXT NOT NULL PRIMARY KEY,
          name_encrypted TEXT NOT NULL,
          description_encrypted TEXT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');
            sqlite.execute('''
        CREATE TABLE backup_records (
          id TEXT NOT NULL PRIMARY KEY,
          relative_path TEXT NULL,
          created_at INTEGER NOT NULL,
          size_bytes INTEGER NOT NULL,
          verified INTEGER NOT NULL
        );
      ''');
            sqlite.execute('PRAGMA user_version = 1;');
          },
        ),
      );
      addTearDown(database.close);

      final columns = await database
          .customSelect("PRAGMA table_info('physical_locations')")
          .get();
      expect(columns.map((row) => row.data['name']), contains('is_archived'));
      final versionTable = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'document_versions'",
          )
          .getSingleOrNull();
      expect(versionTable, isNotNull);
      final backupColumns = await database
          .customSelect("PRAGMA table_info('backup_records')")
          .get();
      expect(
        backupColumns.map((row) => row.data['name']),
        containsAll(['destination_type', 'vault_changes_since_backup']),
      );
      expect(database.schemaVersion, 4);
    },
  );
}
