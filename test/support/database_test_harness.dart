import 'package:documentvault/core/database/vault_database.dart';
import 'package:drift/native.dart';

/// Creates an isolated SQLite database for repository/constraint/migration
/// tests. Future released-schema fixtures should be opened before this class.
VaultDatabase openTestDatabase() => VaultDatabase(NativeDatabase.memory());
