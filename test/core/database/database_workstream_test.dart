import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'schema-change pull requests require migration and backup evidence',
    () async {
      final template = await File('.github/PULL_REQUEST_TEMPLATE.md')
          .readAsString();
      for (final requirement in [
        'Database workstream review',
        'currentSchemaVersion',
        'VaultDatabase._upgrade',
        'populated immutable fixture',
        'rollback/recovery behavior',
        'backup-compatibility.md',
      ]) {
        expect(template, contains(requirement));
      }
    },
  );

  test(
    'database policy records the current version and forward-only contract',
    () async {
      final policy = await File('docs/database/migration-policy.md')
          .readAsString();
      final backupCompatibility = await File(
        'docs/database/backup-compatibility.md',
      ).readAsString();

      expect(policy, contains('**version 6**'));
      expect(policy, contains('forward-only'));
      expect(policy, contains('failed transactional migration'));
      expect(backupCompatibility, contains('SQLite/Drift vault schema | 6'));
      expect(backupCompatibility, contains('newer than it'));
    },
  );
}
