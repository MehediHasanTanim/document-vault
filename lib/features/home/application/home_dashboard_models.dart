enum BackupHealth { protected, due, unavailable }

class DashboardDocument {
  const DashboardDocument({
    required this.id,
    required this.title,
    required this.subtitle,
    this.expiryLabel,
    this.favorite = false,
  });
  final String id;
  final String title;
  final String subtitle;
  final String? expiryLabel;
  final bool favorite;
}

class DashboardFamilyMember {
  const DashboardFamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.documentCount,
  });
  final String id;
  final String name;
  final String relationship;
  final int documentCount;
}

class HomeDashboardData {
  const HomeDashboardData({
    this.greeting = 'Good morning / শুভ সকাল',
    this.vaultName = 'My Vault / আমার ভল্ট',
    this.favorites = const [],
    this.expiringSoon = const [],
    this.family = const [],
    this.recent = const [],
    this.backupHealth = BackupHealth.due,
  });
  final String greeting;
  final String vaultName;
  final List<DashboardDocument> favorites;
  final List<DashboardDocument> expiringSoon;
  final List<DashboardFamilyMember> family;
  final List<DashboardDocument> recent;
  final BackupHealth backupHealth;
  bool get isEmpty =>
      favorites.isEmpty &&
      expiringSoon.isEmpty &&
      family.isEmpty &&
      recent.isEmpty;
}
