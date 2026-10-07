import 'dart:io';

import 'package:documentvault/core/database/vault_database.dart';
import 'package:drift/native.dart';

/// Creates an isolated SQLite database for repository/constraint/migration
/// tests. Future released-schema fixtures should be opened before this class.
VaultDatabase openTestDatabase() => VaultDatabase(NativeDatabase.memory());

/// Opens a released SQL fixture in memory. Fixtures are immutable and contain
/// only synthetic data, allowing migration tests to exercise both schema and
/// preservation behavior without accessing a user vault.
VaultDatabase openFixtureDatabase(String fixturePath) {
  final sql = File(fixturePath).readAsStringSync();
  return VaultDatabase(
    NativeDatabase.memory(
      setup: (sqlite) {
        sqlite.execute(sql);
      },
    ),
  );
}
