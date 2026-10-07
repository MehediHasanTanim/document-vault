import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('documentation map contains every required operational area', () {
    const requiredDocuments = [
      'docs/README.md',
      'docs/architecture/overview.md',
      'docs/adr/README.md',
      'docs/security/encryption-design.md',
      'docs/security/key-hierarchy.md',
      'docs/security/security-checklist.md',
      'docs/database/schema.md',
      'docs/database/migration-guide.md',
      'docs/backup/backup-specification.md',
      'docs/backup/restore-specification.md',
      'docs/release/release-checklist.md',
      'docs/troubleshooting/README.md',
    ];
    for (final path in requiredDocuments) {
      expect(File(path).existsSync(), isTrue, reason: 'Missing $path');
    }
  });

  test(
    'documentation index and PR template retain maintenance contracts',
    () async {
      final index = await File('docs/README.md').readAsString();
      final template = await File('.github/PULL_REQUEST_TEMPLATE.md')
          .readAsString();
      expect(index, contains('Architecture overview'));
      expect(index, contains('Backup specification'));
      expect(index, contains('Release checklist'));
      expect(template, contains('Documentation review'));
      expect(template, contains('no secret, private vault data'));
    },
  );
}
