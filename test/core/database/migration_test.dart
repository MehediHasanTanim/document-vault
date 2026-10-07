import 'package:documentvault/core/database/vault_database.dart';
import 'package:drift/drift.dart' show Variable;
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
      final auditTable = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'share_audit_events'",
          )
          .getSingleOrNull();
      expect(auditTable, isNotNull);
      final versionColumns = await database
          .customSelect("PRAGMA table_info('document_versions')")
          .get();
      expect(
        versionColumns.map((row) => row.data['name']),
        containsAll([
          'version_number',
          'version_label_encrypted',
          'superseded_at',
        ]),
      );
      for (final table in ['emergency_collection_items', 'document_links']) {
        expect(
          await database
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
                variables: [Variable.withString(table)],
              )
              .getSingleOrNull(),
          isNotNull,
        );
      }
      expect(database.schemaVersion, 6);
    },
  );

  test(
    'v5 version rows gain additive history fields and relationship tables',
    () async {
      final database = VaultDatabase(
        NativeDatabase.memory(
          setup: (sqlite) {
            sqlite.execute('''
            CREATE TABLE document_versions (
              id TEXT NOT NULL PRIMARY KEY,
              document_id TEXT NOT NULL,
              previous_version_id TEXT NULL,
              is_current INTEGER NOT NULL DEFAULT 1,
              created_at INTEGER NOT NULL
            );
          ''');
            sqlite.execute('PRAGMA user_version = 5;');
          },
        ),
      );
      addTearDown(database.close);

      final columns = await database
          .customSelect("PRAGMA table_info('document_versions')")
          .get();
      expect(
        columns.map((row) => row.data['name']),
        containsAll([
          'version_number',
          'version_label_encrypted',
          'superseded_at',
        ]),
      );
      expect(
        await database
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'document_links'",
            )
            .getSingleOrNull(),
        isNotNull,
      );
    },
  );
}
