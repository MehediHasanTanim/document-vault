import 'package:documentvault/core/database/vault_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'v1 physical locations and v3 document versions migrate additively',
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
      expect(database.schemaVersion, 3);
    },
  );
}
