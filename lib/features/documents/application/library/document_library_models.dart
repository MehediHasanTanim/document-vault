import '../../../../core/database/vault_database.dart';
import '../../../../core/files/file_reference.dart';

enum DocumentLibraryScope {
  all,
  recent,
  favorites,
  category,
  person,
  archived,
  trash,
}

enum DocumentSort {
  recentlyAdded,
  recentlyUpdated,
  title,
  issueDate,
  expiryDate,
  category,
  owner,
}

enum ExpiryFilter { any, expired, expiringSoon, valid, noExpiry }

enum ArchiveFilter { active, archived, all }

enum DocumentFileType { any, image, pdf, other }

class DocumentLibraryFilter {
  const DocumentLibraryFilter({
    this.ownerId,
    this.categoryId,
    this.tagId,
    this.expiry = ExpiryFilter.any,
    this.favoriteOnly = false,
    this.archive = ArchiveFilter.active,
    this.fileType = DocumentFileType.any,
    this.searchTerm = '',
  });

  final String? ownerId;
  final String? categoryId;
  final String? tagId;
  final ExpiryFilter expiry;
  final bool favoriteOnly;
  final ArchiveFilter archive;
  final DocumentFileType fileType;
  final String searchTerm;

  DocumentLibraryFilter copyWith({
    String? ownerId,
    String? categoryId,
    String? tagId,
    ExpiryFilter? expiry,
    bool? favoriteOnly,
    ArchiveFilter? archive,
    DocumentFileType? fileType,
    String? searchTerm,
    bool clearOwner = false,
    bool clearCategory = false,
    bool clearTag = false,
  }) => DocumentLibraryFilter(
    ownerId: clearOwner ? null : ownerId ?? this.ownerId,
    categoryId: clearCategory ? null : categoryId ?? this.categoryId,
    tagId: clearTag ? null : tagId ?? this.tagId,
    expiry: expiry ?? this.expiry,
    favoriteOnly: favoriteOnly ?? this.favoriteOnly,
    archive: archive ?? this.archive,
    fileType: fileType ?? this.fileType,
    searchTerm: searchTerm ?? this.searchTerm,
  );
}

class DocumentLibraryQuery {
  const DocumentLibraryQuery({
    this.scope = DocumentLibraryScope.all,
    this.sort = DocumentSort.recentlyUpdated,
    this.filter = const DocumentLibraryFilter(),
    this.categoryId,
    this.personId,
  });

  final DocumentLibraryScope scope;
  final DocumentSort sort;
  final DocumentLibraryFilter filter;
  final String? categoryId;
  final String? personId;

  DocumentLibraryQuery copyWith({
    DocumentLibraryScope? scope,
    DocumentSort? sort,
    DocumentLibraryFilter? filter,
    String? categoryId,
    String? personId,
  }) => DocumentLibraryQuery(
    scope: scope ?? this.scope,
    sort: sort ?? this.sort,
    filter: filter ?? this.filter,
    categoryId: categoryId ?? this.categoryId,
    personId: personId ?? this.personId,
  );
}

enum DocumentExpiryState { none, valid, soon, expired }

class DocumentCardData {
  const DocumentCardData({
    required this.id,
    required this.title,
    required this.ownerNames,
    required this.category,
    required this.expiryState,
    required this.issueDate,
    required this.expiryDate,
    required this.isFavorite,
    required this.isArchived,
    required this.isTrashed,
    required this.updatedAt,
    required this.createdAt,
    required this.fileTypes,
    this.preview,
  });

  final String id;
  final String title;
  final List<String> ownerNames;
  final String category;
  final DocumentExpiryState expiryState;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final bool isFavorite;
  final bool isArchived;
  final bool isTrashed;
  final DateTime updatedAt;
  final DateTime createdAt;
  final Set<DocumentFileType> fileTypes;
  final SecureFileReference? preview;

  String get ownerLabel =>
      ownerNames.isEmpty ? 'Household / পরিবার' : ownerNames.join(', ');
}

class DocumentFieldDetail {
  const DocumentFieldDetail({
    required this.key,
    required this.label,
    required this.value,
    required this.valueType,
  });
  final String key;
  final String? label;
  final String value;
  final String valueType;
}

class ReminderSummary {
  const ReminderSummary({
    required this.enabled,
    this.nextScheduledAt,
    this.count = 0,
  });
  final bool enabled;
  final DateTime? nextScheduledAt;
  final int count;
}

class DocumentDetailsData {
  const DocumentDetailsData({
    required this.card,
    required this.documentNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.issuingAuthority,
    required this.description,
    required this.notes,
    required this.tags,
    required this.physicalLocation,
    required this.fields,
    required this.reminder,
    required this.files,
    required this.pageCount,
  });

  final DocumentCardData card;
  final String? documentNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issuingAuthority;
  final String? description;
  final String? notes;
  final List<String> tags;
  final String? physicalLocation;
  final List<DocumentFieldDetail> fields;
  final ReminderSummary reminder;
  final List<SecureFileReference> files;
  final int pageCount;
}

/// Raw records never leave the infrastructure/data boundary without being
/// decrypted by the unlocked application service.
class DocumentLibrarySnapshot {
  const DocumentLibrarySnapshot({
    required this.documents,
    required this.categories,
    required this.members,
    required this.owners,
    required this.tags,
    required this.tagLinks,
    required this.locations,
    required this.files,
    required this.pages,
    required this.fields,
    required this.reminders,
  });
  final List<Document> documents;
  final List<DocumentCategory> categories;
  final List<FamilyMember> members;
  final List<DocumentOwner> owners;
  final List<Tag> tags;
  final List<DocumentTag> tagLinks;
  final List<PhysicalLocation> locations;
  final List<DocumentFile> files;
  final List<DocumentPage> pages;
  final List<DocumentFieldValue> fields;
  final List<Reminder> reminders;
}
