import '../../../../core/crypto/vault_data_protector.dart';
import '../../../../core/database/repositories.dart';
import '../../../../core/errors/app_failure.dart';

/// Search helpers operate on already-decrypted presentation labels, so the
/// database never has to index or leak searchable family/category text.
class OwnerSearchEntry {
  const OwnerSearchEntry({
    required this.id,
    required this.name,
    required this.relationship,
  });
  final String id;
  final String name;
  final String relationship;
}

List<OwnerSearchEntry> searchOwners(
  Iterable<OwnerSearchEntry> owners,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return List.unmodifiable(owners);
  return owners
      .where(
        (owner) => '${owner.name} ${owner.relationship}'.toLowerCase().contains(
          normalized,
        ),
      )
      .toList(growable: false);
}

class CategorySearchEntry {
  const CategorySearchEntry({
    required this.id,
    required this.code,
    required this.label,
    this.parentId,
  });
  final String id;
  final String code;
  final String label;
  final String? parentId;
}

List<CategorySearchEntry> searchCategories(
  Iterable<CategorySearchEntry> categories,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return List.unmodifiable(categories);
  return categories
      .where(
        (category) => '${category.label} ${category.code}'
            .toLowerCase()
            .contains(normalized),
      )
      .toList(growable: false);
}

/// Persists only category UUIDs, encrypted as ordinary app metadata. This is
/// intentionally bounded and has no analytics side channel.
class RecentCategoryService {
  RecentCategoryService(
    this._settings,
    this._protector, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const _settingKey = 'document.recent_category_ids.v1';
  final SettingsRepository _settings;
  final VaultDataProtector _protector;
  final DateTime Function() _clock;

  Future<List<String>> read() async {
    final encrypted = await _settings.read(_settingKey);
    if (encrypted == null) return const [];
    try {
      final value = await _protector.decrypt(encrypted, context: _settingKey);
      return value
          .split(',')
          .where((id) => id.isNotEmpty)
          .take(5)
          .toList(growable: false);
    } on Object {
      throw const StorageFailure('Recent categories could not be read safely.');
    }
  }

  Future<void> record(String categoryId) async {
    final previous = await read();
    final ids = <String>[
      categoryId,
      ...previous.where((id) => id != categoryId),
    ].take(5);
    final encrypted = await _protector.encrypt(
      ids.join(','),
      context: _settingKey,
    );
    await _settings.write(_settingKey, encrypted, _clock().toUtc());
  }
}
