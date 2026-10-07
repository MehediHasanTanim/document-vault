import 'dart:io';

import 'package:documentvault/core/database/vault_database.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../../support/database_test_harness.dart';

void main() {
  test(
    'populated v1 fixture migrates forward and preserves existing rows',
    () async {
      final database = openFixtureDatabase('test/fixtures/v1_schema.sql');
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
      final location = await database
          .customSelect(
            "SELECT name_encrypted FROM physical_locations WHERE id = 'fixture-location-1'",
          )
          .getSingle();
      expect(location.data['name_encrypted'], 'encrypted-location');
      final backup = await database
          .customSelect(
            "SELECT size_bytes, destination_type, vault_changes_since_backup FROM backup_records WHERE id = 'fixture-backup-1'",
          )
          .getSingle();
      expect(backup.data['size_bytes'], 512);
      expect(backup.data['destination_type'], isNull);
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

  test(
    'failed migration rolls back schema and user version for recovery',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'vault-migration-',
      );
      final databaseFile = File('${directory.path}/vault.sqlite');
      addTearDown(() => directory.delete(recursive: true));

      final raw = sqlite.sqlite3.open(databaseFile.path);
      raw.execute('''
      CREATE TABLE physical_locations (
        id TEXT NOT NULL PRIMARY KEY,
        name_encrypted TEXT NOT NULL,
        description_encrypted TEXT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
      PRAGMA user_version = 1;
    ''');
      raw.close();

      final database = VaultDatabase(NativeDatabase(databaseFile));
      await expectLater(
        database.customSelect("PRAGMA table_info('physical_locations')").get(),
        throwsA(isA<Object>()),
      );
      await database.close();

      final afterFailure = sqlite.sqlite3.open(databaseFile.path);
      addTearDown(afterFailure.close);
      expect(
        afterFailure.select('PRAGMA user_version').single['user_version'],
        1,
      );
      final columns = afterFailure
          .select("PRAGMA table_info('physical_locations')")
          .map((row) => row['name']);
      expect(columns, isNot(contains('is_archived')));
    },
  );
}
