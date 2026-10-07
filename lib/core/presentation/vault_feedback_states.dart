import 'package:flutter/material.dart';

/// Reusable, bilingual and screen-reader-friendly empty state. Screens supply
/// actions explicitly so the state never suggests a destructive operation.
class VaultEmptyState extends StatelessWidget {
  const VaultEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Semantics(
        container: true,
        label: '$title. $message',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    ),
  );
}

enum VaultEmptyKind {
  vault,
  family,
  category,
  favorites,
  reminders,
  archive,
  trash,
  search,
}

/// Canonical empty-state copy so all list scopes remain coherent in English
/// and বাংলা, including when no sensitive document data may be shown.
class VaultNamedEmptyState extends StatelessWidget {
  const VaultNamedEmptyState({required this.kind, this.action, super.key});
  final VaultEmptyKind kind;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final copy = switch (kind) {
      VaultEmptyKind.vault => (
        Icons.inventory_2_outlined,
        'Your vault is empty / আপনার ভল্ট খালি',
        'Scan or import your first important document. / প্রথম গুরুত্বপূর্ণ নথিটি স্ক্যান বা ইমপোর্ট করুন।',
      ),
      VaultEmptyKind.family => (
        Icons.groups_outlined,
        'No family members / পরিবারের কোনো সদস্য নেই',
        'Add people to organise documents by owner. / মালিক অনুযায়ী নথি গুছাতে সদস্য যোগ করুন।',
      ),
      VaultEmptyKind.category => (
        Icons.category_outlined,
        'No documents in this category / এই বিভাগে কোনো নথি নেই',
        'Add a document or choose another category. / নথি যোগ করুন বা অন্য বিভাগ বেছে নিন।',
      ),
      VaultEmptyKind.favorites => (
        Icons.star_outline,
        'No favorites / কোনো পছন্দের নথি নেই',
        'Mark important documents as favorites for quick access. / দ্রুত ব্যবহারের জন্য গুরুত্বপূর্ণ নথি পছন্দের তালিকায় রাখুন।',
      ),
      VaultEmptyKind.reminders => (
        Icons.notifications_none,
        'No upcoming reminders / কোনো আসন্ন রিমাইন্ডার নেই',
        'Add an expiry date and reminder to a document. / নথিতে মেয়াদের তারিখ ও রিমাইন্ডার যোগ করুন।',
      ),
      VaultEmptyKind.archive => (
        Icons.archive_outlined,
        'No archived documents / কোনো আর্কাইভ করা নথি নেই',
        'Archived documents stay safely in your vault. / আর্কাইভ করা নথি আপনার ভল্টেই নিরাপদে থাকে।',
      ),
      VaultEmptyKind.trash => (
        Icons.delete_outline,
        'Trash is empty / ট্র্যাশ খালি',
        'Deleted documents stay here until you restore or permanently remove them. / পুনরুদ্ধার বা স্থায়ীভাবে মুছার আগে নথি এখানে থাকে।',
      ),
      VaultEmptyKind.search => (
        Icons.search_off,
        'No results / কোনো ফল পাওয়া যায়নি',
        'Try a different word or remove a filter. / অন্য শব্দ দিন বা ফিল্টার সরান।',
      ),
    };
    return VaultEmptyState(
      icon: copy.$1,
      title: copy.$2,
      message: copy.$3,
      action: action,
    );
  }
}

enum VaultErrorKind {
  unsupportedFile,
  corruptDocument,
  storageLow,
  saveFailed,
  backupFailed,
  restoreFailed,
  notificationDenied,
  biometricUnavailable,
  migrationFailed,
}

class VaultErrorState extends StatelessWidget {
  const VaultErrorState({
    required this.kind,
    this.onRetry,
    this.onOpenSettings,
    super.key,
  });
  final VaultErrorKind kind;
  final VoidCallback? onRetry;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final copy = _copy(kind);
    final action =
        kind == VaultErrorKind.notificationDenied && onOpenSettings != null
        ? OutlinedButton.icon(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Open Settings / সেটিংস খুলুন'),
          )
        : onRetry == null
        ? null
        : FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again / আবার চেষ্টা করুন'),
          );
    return VaultEmptyState(
      icon: copy.$1,
      title: copy.$2,
      message: copy.$3,
      action: action,
    );
  }

  (IconData, String, String) _copy(VaultErrorKind value) => switch (value) {
    VaultErrorKind.unsupportedFile => (
      Icons.insert_drive_file_outlined,
      'Unsupported file / অসমর্থিত ফাইল',
      'Choose a supported image, PDF, or document file. / সমর্থিত ছবি, PDF বা নথি বেছে নিন.',
    ),
    VaultErrorKind.corruptDocument => (
      Icons.broken_image_outlined,
      'Document cannot be opened / নথি খোলা যাচ্ছে না',
      'Its encrypted data did not pass an integrity check. / এনক্রিপ্ট করা ডেটার অখণ্ডতা যাচাই হয়নি.',
    ),
    VaultErrorKind.storageLow => (
      Icons.storage_outlined,
      'Storage is low / স্টোরেজ কম',
      'Free some device space, then try again. / ডিভাইসে জায়গা খালি করে আবার চেষ্টা করুন.',
    ),
    VaultErrorKind.saveFailed => (
      Icons.save_outlined,
      'Could not save / সংরক্ষণ করা যায়নি',
      'Your original document was kept safe. / আপনার আসল নথি নিরাপদে রাখা হয়েছে.',
    ),
    VaultErrorKind.backupFailed => (
      Icons.backup_outlined,
      'Backup failed / ব্যাকআপ ব্যর্থ হয়েছে',
      'The current vault was not changed. / বর্তমান ভল্টে কোনো পরিবর্তন হয়নি.',
    ),
    VaultErrorKind.restoreFailed => (
      Icons.restore_outlined,
      'Restore failed / পুনরুদ্ধার ব্যর্থ হয়েছে',
      'Your previous vault was kept. / আগের ভল্টটি রাখা হয়েছে.',
    ),
    VaultErrorKind.notificationDenied => (
      Icons.notifications_off_outlined,
      'Notifications are off / নোটিফিকেশন বন্ধ',
      'Enable them in device settings for expiry reminders. / মেয়াদের রিমাইন্ডারের জন্য ডিভাইস সেটিংসে চালু করুন.',
    ),
    VaultErrorKind.biometricUnavailable => (
      Icons.fingerprint_outlined,
      'Biometrics unavailable / বায়োমেট্রিক পাওয়া যাচ্ছে না',
      'Use your PIN, or enroll biometrics in device settings. / PIN ব্যবহার করুন অথবা ডিভাইস সেটিংসে বায়োমেট্রিক যোগ করুন.',
    ),
    VaultErrorKind.migrationFailed => (
      Icons.system_update_alt_outlined,
      'Vault update needs attention / ভল্ট আপডেটে সহায়তা প্রয়োজন',
      'The vault was not changed. Try again after freeing storage. / ভল্টে পরিবর্তন হয়নি। জায়গা খালি করে আবার চেষ্টা করুন.',
    ),
  };
}
