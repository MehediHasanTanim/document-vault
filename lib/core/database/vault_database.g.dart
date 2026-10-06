// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_database.dart';

// ignore_for_file: type=lint
class $VaultsTable extends Vaults with TableInfo<$VaultsTable, Vault> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _securityVersionMeta = const VerificationMeta(
    'securityVersion',
  );
  @override
  late final GeneratedColumn<int> securityVersion = GeneratedColumn<int>(
    'security_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schemaVersion,
    securityVersion,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaults';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vault> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('security_version')) {
      context.handle(
        _securityVersionMeta,
        securityVersion.isAcceptableOrUnknown(
          data['security_version']!,
          _securityVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_securityVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vault map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vault(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      securityVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}security_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VaultsTable createAlias(String alias) {
    return $VaultsTable(attachedDatabase, alias);
  }
}

class Vault extends DataClass implements Insertable<Vault> {
  final String id;
  final int schemaVersion;
  final int securityVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Vault({
    required this.id,
    required this.schemaVersion,
    required this.securityVersion,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['security_version'] = Variable<int>(securityVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VaultsCompanion toCompanion(bool nullToAbsent) {
    return VaultsCompanion(
      id: Value(id),
      schemaVersion: Value(schemaVersion),
      securityVersion: Value(securityVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Vault.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vault(
      id: serializer.fromJson<String>(json['id']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      securityVersion: serializer.fromJson<int>(json['securityVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'securityVersion': serializer.toJson<int>(securityVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Vault copyWith({
    String? id,
    int? schemaVersion,
    int? securityVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Vault(
    id: id ?? this.id,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    securityVersion: securityVersion ?? this.securityVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Vault copyWithCompanion(VaultsCompanion data) {
    return Vault(
      id: data.id.present ? data.id.value : this.id,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      securityVersion: data.securityVersion.present
          ? data.securityVersion.value
          : this.securityVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vault(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('securityVersion: $securityVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, schemaVersion, securityVersion, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vault &&
          other.id == this.id &&
          other.schemaVersion == this.schemaVersion &&
          other.securityVersion == this.securityVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VaultsCompanion extends UpdateCompanion<Vault> {
  final Value<String> id;
  final Value<int> schemaVersion;
  final Value<int> securityVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VaultsCompanion({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.securityVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultsCompanion.insert({
    required String id,
    required int schemaVersion,
    required int securityVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schemaVersion = Value(schemaVersion),
       securityVersion = Value(securityVersion),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Vault> custom({
    Expression<String>? id,
    Expression<int>? schemaVersion,
    Expression<int>? securityVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (securityVersion != null) 'security_version': securityVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultsCompanion copyWith({
    Value<String>? id,
    Value<int>? schemaVersion,
    Value<int>? securityVersion,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VaultsCompanion(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      securityVersion: securityVersion ?? this.securityVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (securityVersion.present) {
      map['security_version'] = Variable<int>(securityVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultsCompanion(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('securityVersion: $securityVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyMembersTable extends FamilyMembers
    with TableInfo<$FamilyMembersTable, FamilyMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameEncryptedMeta =
      const VerificationMeta('displayNameEncrypted');
  @override
  late final GeneratedColumn<String> displayNameEncrypted =
      GeneratedColumn<String>(
        'display_name_encrypted',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _nicknameEncryptedMeta = const VerificationMeta(
    'nicknameEncrypted',
  );
  @override
  late final GeneratedColumn<String> nicknameEncrypted =
      GeneratedColumn<String>(
        'nickname_encrypted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _relationshipMeta = const VerificationMeta(
    'relationship',
  );
  @override
  late final GeneratedColumn<String> relationship = GeneratedColumn<String>(
    'relationship',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bloodGroupMeta = const VerificationMeta(
    'bloodGroup',
  );
  @override
  late final GeneratedColumn<String> bloodGroup = GeneratedColumn<String>(
    'blood_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarFileIdMeta = const VerificationMeta(
    'avatarFileId',
  );
  @override
  late final GeneratedColumn<String> avatarFileId = GeneratedColumn<String>(
    'avatar_file_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesEncryptedMeta = const VerificationMeta(
    'notesEncrypted',
  );
  @override
  late final GeneratedColumn<String> notesEncrypted = GeneratedColumn<String>(
    'notes_encrypted',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOwnerMeta = const VerificationMeta(
    'isOwner',
  );
  @override
  late final GeneratedColumn<bool> isOwner = GeneratedColumn<bool>(
    'is_owner',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_owner" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayNameEncrypted,
    nicknameEncrypted,
    relationship,
    dateOfBirth,
    bloodGroup,
    avatarFileId,
    notesEncrypted,
    isOwner,
    isArchived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name_encrypted')) {
      context.handle(
        _displayNameEncryptedMeta,
        displayNameEncrypted.isAcceptableOrUnknown(
          data['display_name_encrypted']!,
          _displayNameEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameEncryptedMeta);
    }
    if (data.containsKey('nickname_encrypted')) {
      context.handle(
        _nicknameEncryptedMeta,
        nicknameEncrypted.isAcceptableOrUnknown(
          data['nickname_encrypted']!,
          _nicknameEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('relationship')) {
      context.handle(
        _relationshipMeta,
        relationship.isAcceptableOrUnknown(
          data['relationship']!,
          _relationshipMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationshipMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('blood_group')) {
      context.handle(
        _bloodGroupMeta,
        bloodGroup.isAcceptableOrUnknown(data['blood_group']!, _bloodGroupMeta),
      );
    }
    if (data.containsKey('avatar_file_id')) {
      context.handle(
        _avatarFileIdMeta,
        avatarFileId.isAcceptableOrUnknown(
          data['avatar_file_id']!,
          _avatarFileIdMeta,
        ),
      );
    }
    if (data.containsKey('notes_encrypted')) {
      context.handle(
        _notesEncryptedMeta,
        notesEncrypted.isAcceptableOrUnknown(
          data['notes_encrypted']!,
          _notesEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('is_owner')) {
      context.handle(
        _isOwnerMeta,
        isOwner.isAcceptableOrUnknown(data['is_owner']!, _isOwnerMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayNameEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name_encrypted'],
      )!,
      nicknameEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname_encrypted'],
      ),
      relationship: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
      bloodGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_group'],
      ),
      avatarFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_file_id'],
      ),
      notesEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes_encrypted'],
      ),
      isOwner: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_owner'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FamilyMembersTable createAlias(String alias) {
    return $FamilyMembersTable(attachedDatabase, alias);
  }
}

class FamilyMember extends DataClass implements Insertable<FamilyMember> {
  final String id;
  final String displayNameEncrypted;
  final String? nicknameEncrypted;
  final String relationship;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final String? avatarFileId;
  final String? notesEncrypted;
  final bool isOwner;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FamilyMember({
    required this.id,
    required this.displayNameEncrypted,
    this.nicknameEncrypted,
    required this.relationship,
    this.dateOfBirth,
    this.bloodGroup,
    this.avatarFileId,
    this.notesEncrypted,
    required this.isOwner,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name_encrypted'] = Variable<String>(displayNameEncrypted);
    if (!nullToAbsent || nicknameEncrypted != null) {
      map['nickname_encrypted'] = Variable<String>(nicknameEncrypted);
    }
    map['relationship'] = Variable<String>(relationship);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || bloodGroup != null) {
      map['blood_group'] = Variable<String>(bloodGroup);
    }
    if (!nullToAbsent || avatarFileId != null) {
      map['avatar_file_id'] = Variable<String>(avatarFileId);
    }
    if (!nullToAbsent || notesEncrypted != null) {
      map['notes_encrypted'] = Variable<String>(notesEncrypted);
    }
    map['is_owner'] = Variable<bool>(isOwner);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FamilyMembersCompanion toCompanion(bool nullToAbsent) {
    return FamilyMembersCompanion(
      id: Value(id),
      displayNameEncrypted: Value(displayNameEncrypted),
      nicknameEncrypted: nicknameEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(nicknameEncrypted),
      relationship: Value(relationship),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      bloodGroup: bloodGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodGroup),
      avatarFileId: avatarFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarFileId),
      notesEncrypted: notesEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(notesEncrypted),
      isOwner: Value(isOwner),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FamilyMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyMember(
      id: serializer.fromJson<String>(json['id']),
      displayNameEncrypted: serializer.fromJson<String>(
        json['displayNameEncrypted'],
      ),
      nicknameEncrypted: serializer.fromJson<String?>(
        json['nicknameEncrypted'],
      ),
      relationship: serializer.fromJson<String>(json['relationship']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      bloodGroup: serializer.fromJson<String?>(json['bloodGroup']),
      avatarFileId: serializer.fromJson<String?>(json['avatarFileId']),
      notesEncrypted: serializer.fromJson<String?>(json['notesEncrypted']),
      isOwner: serializer.fromJson<bool>(json['isOwner']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayNameEncrypted': serializer.toJson<String>(displayNameEncrypted),
      'nicknameEncrypted': serializer.toJson<String?>(nicknameEncrypted),
      'relationship': serializer.toJson<String>(relationship),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'bloodGroup': serializer.toJson<String?>(bloodGroup),
      'avatarFileId': serializer.toJson<String?>(avatarFileId),
      'notesEncrypted': serializer.toJson<String?>(notesEncrypted),
      'isOwner': serializer.toJson<bool>(isOwner),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FamilyMember copyWith({
    String? id,
    String? displayNameEncrypted,
    Value<String?> nicknameEncrypted = const Value.absent(),
    String? relationship,
    Value<DateTime?> dateOfBirth = const Value.absent(),
    Value<String?> bloodGroup = const Value.absent(),
    Value<String?> avatarFileId = const Value.absent(),
    Value<String?> notesEncrypted = const Value.absent(),
    bool? isOwner,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FamilyMember(
    id: id ?? this.id,
    displayNameEncrypted: displayNameEncrypted ?? this.displayNameEncrypted,
    nicknameEncrypted: nicknameEncrypted.present
        ? nicknameEncrypted.value
        : this.nicknameEncrypted,
    relationship: relationship ?? this.relationship,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    bloodGroup: bloodGroup.present ? bloodGroup.value : this.bloodGroup,
    avatarFileId: avatarFileId.present ? avatarFileId.value : this.avatarFileId,
    notesEncrypted: notesEncrypted.present
        ? notesEncrypted.value
        : this.notesEncrypted,
    isOwner: isOwner ?? this.isOwner,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FamilyMember copyWithCompanion(FamilyMembersCompanion data) {
    return FamilyMember(
      id: data.id.present ? data.id.value : this.id,
      displayNameEncrypted: data.displayNameEncrypted.present
          ? data.displayNameEncrypted.value
          : this.displayNameEncrypted,
      nicknameEncrypted: data.nicknameEncrypted.present
          ? data.nicknameEncrypted.value
          : this.nicknameEncrypted,
      relationship: data.relationship.present
          ? data.relationship.value
          : this.relationship,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      bloodGroup: data.bloodGroup.present
          ? data.bloodGroup.value
          : this.bloodGroup,
      avatarFileId: data.avatarFileId.present
          ? data.avatarFileId.value
          : this.avatarFileId,
      notesEncrypted: data.notesEncrypted.present
          ? data.notesEncrypted.value
          : this.notesEncrypted,
      isOwner: data.isOwner.present ? data.isOwner.value : this.isOwner,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMember(')
          ..write('id: $id, ')
          ..write('displayNameEncrypted: $displayNameEncrypted, ')
          ..write('nicknameEncrypted: $nicknameEncrypted, ')
          ..write('relationship: $relationship, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('avatarFileId: $avatarFileId, ')
          ..write('notesEncrypted: $notesEncrypted, ')
          ..write('isOwner: $isOwner, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayNameEncrypted,
    nicknameEncrypted,
    relationship,
    dateOfBirth,
    bloodGroup,
    avatarFileId,
    notesEncrypted,
    isOwner,
    isArchived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyMember &&
          other.id == this.id &&
          other.displayNameEncrypted == this.displayNameEncrypted &&
          other.nicknameEncrypted == this.nicknameEncrypted &&
          other.relationship == this.relationship &&
          other.dateOfBirth == this.dateOfBirth &&
          other.bloodGroup == this.bloodGroup &&
          other.avatarFileId == this.avatarFileId &&
          other.notesEncrypted == this.notesEncrypted &&
          other.isOwner == this.isOwner &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FamilyMembersCompanion extends UpdateCompanion<FamilyMember> {
  final Value<String> id;
  final Value<String> displayNameEncrypted;
  final Value<String?> nicknameEncrypted;
  final Value<String> relationship;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> bloodGroup;
  final Value<String?> avatarFileId;
  final Value<String?> notesEncrypted;
  final Value<bool> isOwner;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FamilyMembersCompanion({
    this.id = const Value.absent(),
    this.displayNameEncrypted = const Value.absent(),
    this.nicknameEncrypted = const Value.absent(),
    this.relationship = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.avatarFileId = const Value.absent(),
    this.notesEncrypted = const Value.absent(),
    this.isOwner = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyMembersCompanion.insert({
    required String id,
    required String displayNameEncrypted,
    this.nicknameEncrypted = const Value.absent(),
    required String relationship,
    this.dateOfBirth = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.avatarFileId = const Value.absent(),
    this.notesEncrypted = const Value.absent(),
    this.isOwner = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayNameEncrypted = Value(displayNameEncrypted),
       relationship = Value(relationship),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FamilyMember> custom({
    Expression<String>? id,
    Expression<String>? displayNameEncrypted,
    Expression<String>? nicknameEncrypted,
    Expression<String>? relationship,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? bloodGroup,
    Expression<String>? avatarFileId,
    Expression<String>? notesEncrypted,
    Expression<bool>? isOwner,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayNameEncrypted != null)
        'display_name_encrypted': displayNameEncrypted,
      if (nicknameEncrypted != null) 'nickname_encrypted': nicknameEncrypted,
      if (relationship != null) 'relationship': relationship,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (avatarFileId != null) 'avatar_file_id': avatarFileId,
      if (notesEncrypted != null) 'notes_encrypted': notesEncrypted,
      if (isOwner != null) 'is_owner': isOwner,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? displayNameEncrypted,
    Value<String?>? nicknameEncrypted,
    Value<String>? relationship,
    Value<DateTime?>? dateOfBirth,
    Value<String?>? bloodGroup,
    Value<String?>? avatarFileId,
    Value<String?>? notesEncrypted,
    Value<bool>? isOwner,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FamilyMembersCompanion(
      id: id ?? this.id,
      displayNameEncrypted: displayNameEncrypted ?? this.displayNameEncrypted,
      nicknameEncrypted: nicknameEncrypted ?? this.nicknameEncrypted,
      relationship: relationship ?? this.relationship,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      avatarFileId: avatarFileId ?? this.avatarFileId,
      notesEncrypted: notesEncrypted ?? this.notesEncrypted,
      isOwner: isOwner ?? this.isOwner,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayNameEncrypted.present) {
      map['display_name_encrypted'] = Variable<String>(
        displayNameEncrypted.value,
      );
    }
    if (nicknameEncrypted.present) {
      map['nickname_encrypted'] = Variable<String>(nicknameEncrypted.value);
    }
    if (relationship.present) {
      map['relationship'] = Variable<String>(relationship.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (bloodGroup.present) {
      map['blood_group'] = Variable<String>(bloodGroup.value);
    }
    if (avatarFileId.present) {
      map['avatar_file_id'] = Variable<String>(avatarFileId.value);
    }
    if (notesEncrypted.present) {
      map['notes_encrypted'] = Variable<String>(notesEncrypted.value);
    }
    if (isOwner.present) {
      map['is_owner'] = Variable<bool>(isOwner.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMembersCompanion(')
          ..write('id: $id, ')
          ..write('displayNameEncrypted: $displayNameEncrypted, ')
          ..write('nicknameEncrypted: $nicknameEncrypted, ')
          ..write('relationship: $relationship, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('avatarFileId: $avatarFileId, ')
          ..write('notesEncrypted: $notesEncrypted, ')
          ..write('isOwner: $isOwner, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentCategoriesTable extends DocumentCategories
    with TableInfo<$DocumentCategoriesTable, DocumentCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameEncryptedMeta =
      const VerificationMeta('customNameEncrypted');
  @override
  late final GeneratedColumn<String> customNameEncrypted =
      GeneratedColumn<String>(
        'custom_name_encrypted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('document'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    parentId,
    nameKey,
    customNameEncrypted,
    isSystem,
    sortOrder,
    iconKey,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    }
    if (data.containsKey('custom_name_encrypted')) {
      context.handle(
        _customNameEncryptedMeta,
        customNameEncrypted.isAcceptableOrUnknown(
          data['custom_name_encrypted']!,
          _customNameEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      ),
      customNameEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name_encrypted'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DocumentCategoriesTable createAlias(String alias) {
    return $DocumentCategoriesTable(attachedDatabase, alias);
  }
}

class DocumentCategory extends DataClass
    implements Insertable<DocumentCategory> {
  final String id;
  final String code;
  final String? parentId;
  final String? nameKey;
  final String? customNameEncrypted;
  final bool isSystem;
  final int sortOrder;
  final String iconKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DocumentCategory({
    required this.id,
    required this.code,
    this.parentId,
    this.nameKey,
    this.customNameEncrypted,
    required this.isSystem,
    required this.sortOrder,
    required this.iconKey,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || nameKey != null) {
      map['name_key'] = Variable<String>(nameKey);
    }
    if (!nullToAbsent || customNameEncrypted != null) {
      map['custom_name_encrypted'] = Variable<String>(customNameEncrypted);
    }
    map['is_system'] = Variable<bool>(isSystem);
    map['sort_order'] = Variable<int>(sortOrder);
    map['icon_key'] = Variable<String>(iconKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DocumentCategoriesCompanion toCompanion(bool nullToAbsent) {
    return DocumentCategoriesCompanion(
      id: Value(id),
      code: Value(code),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      nameKey: nameKey == null && nullToAbsent
          ? const Value.absent()
          : Value(nameKey),
      customNameEncrypted: customNameEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(customNameEncrypted),
      isSystem: Value(isSystem),
      sortOrder: Value(sortOrder),
      iconKey: Value(iconKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DocumentCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentCategory(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      nameKey: serializer.fromJson<String?>(json['nameKey']),
      customNameEncrypted: serializer.fromJson<String?>(
        json['customNameEncrypted'],
      ),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'parentId': serializer.toJson<String?>(parentId),
      'nameKey': serializer.toJson<String?>(nameKey),
      'customNameEncrypted': serializer.toJson<String?>(customNameEncrypted),
      'isSystem': serializer.toJson<bool>(isSystem),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'iconKey': serializer.toJson<String>(iconKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DocumentCategory copyWith({
    String? id,
    String? code,
    Value<String?> parentId = const Value.absent(),
    Value<String?> nameKey = const Value.absent(),
    Value<String?> customNameEncrypted = const Value.absent(),
    bool? isSystem,
    int? sortOrder,
    String? iconKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DocumentCategory(
    id: id ?? this.id,
    code: code ?? this.code,
    parentId: parentId.present ? parentId.value : this.parentId,
    nameKey: nameKey.present ? nameKey.value : this.nameKey,
    customNameEncrypted: customNameEncrypted.present
        ? customNameEncrypted.value
        : this.customNameEncrypted,
    isSystem: isSystem ?? this.isSystem,
    sortOrder: sortOrder ?? this.sortOrder,
    iconKey: iconKey ?? this.iconKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DocumentCategory copyWithCompanion(DocumentCategoriesCompanion data) {
    return DocumentCategory(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      customNameEncrypted: data.customNameEncrypted.present
          ? data.customNameEncrypted.value
          : this.customNameEncrypted,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentCategory(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('parentId: $parentId, ')
          ..write('nameKey: $nameKey, ')
          ..write('customNameEncrypted: $customNameEncrypted, ')
          ..write('isSystem: $isSystem, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('iconKey: $iconKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    parentId,
    nameKey,
    customNameEncrypted,
    isSystem,
    sortOrder,
    iconKey,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentCategory &&
          other.id == this.id &&
          other.code == this.code &&
          other.parentId == this.parentId &&
          other.nameKey == this.nameKey &&
          other.customNameEncrypted == this.customNameEncrypted &&
          other.isSystem == this.isSystem &&
          other.sortOrder == this.sortOrder &&
          other.iconKey == this.iconKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DocumentCategoriesCompanion extends UpdateCompanion<DocumentCategory> {
  final Value<String> id;
  final Value<String> code;
  final Value<String?> parentId;
  final Value<String?> nameKey;
  final Value<String?> customNameEncrypted;
  final Value<bool> isSystem;
  final Value<int> sortOrder;
  final Value<String> iconKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DocumentCategoriesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.parentId = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.customNameEncrypted = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentCategoriesCompanion.insert({
    required String id,
    required String code,
    this.parentId = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.customNameEncrypted = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.iconKey = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DocumentCategory> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? parentId,
    Expression<String>? nameKey,
    Expression<String>? customNameEncrypted,
    Expression<bool>? isSystem,
    Expression<int>? sortOrder,
    Expression<String>? iconKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (parentId != null) 'parent_id': parentId,
      if (nameKey != null) 'name_key': nameKey,
      if (customNameEncrypted != null)
        'custom_name_encrypted': customNameEncrypted,
      if (isSystem != null) 'is_system': isSystem,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (iconKey != null) 'icon_key': iconKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String?>? parentId,
    Value<String?>? nameKey,
    Value<String?>? customNameEncrypted,
    Value<bool>? isSystem,
    Value<int>? sortOrder,
    Value<String>? iconKey,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DocumentCategoriesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      parentId: parentId ?? this.parentId,
      nameKey: nameKey ?? this.nameKey,
      customNameEncrypted: customNameEncrypted ?? this.customNameEncrypted,
      isSystem: isSystem ?? this.isSystem,
      sortOrder: sortOrder ?? this.sortOrder,
      iconKey: iconKey ?? this.iconKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (customNameEncrypted.present) {
      map['custom_name_encrypted'] = Variable<String>(
        customNameEncrypted.value,
      );
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('parentId: $parentId, ')
          ..write('nameKey: $nameKey, ')
          ..write('customNameEncrypted: $customNameEncrypted, ')
          ..write('isSystem: $isSystem, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('iconKey: $iconKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhysicalLocationsTable extends PhysicalLocations
    with TableInfo<$PhysicalLocationsTable, PhysicalLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhysicalLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEncryptedMeta = const VerificationMeta(
    'nameEncrypted',
  );
  @override
  late final GeneratedColumn<String> nameEncrypted = GeneratedColumn<String>(
    'name_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionEncryptedMeta =
      const VerificationMeta('descriptionEncrypted');
  @override
  late final GeneratedColumn<String> descriptionEncrypted =
      GeneratedColumn<String>(
        'description_encrypted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameEncrypted,
    descriptionEncrypted,
    isArchived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'physical_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhysicalLocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_encrypted')) {
      context.handle(
        _nameEncryptedMeta,
        nameEncrypted.isAcceptableOrUnknown(
          data['name_encrypted']!,
          _nameEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameEncryptedMeta);
    }
    if (data.containsKey('description_encrypted')) {
      context.handle(
        _descriptionEncryptedMeta,
        descriptionEncrypted.isAcceptableOrUnknown(
          data['description_encrypted']!,
          _descriptionEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhysicalLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhysicalLocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_encrypted'],
      )!,
      descriptionEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_encrypted'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PhysicalLocationsTable createAlias(String alias) {
    return $PhysicalLocationsTable(attachedDatabase, alias);
  }
}

class PhysicalLocation extends DataClass
    implements Insertable<PhysicalLocation> {
  final String id;
  final String nameEncrypted;
  final String? descriptionEncrypted;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PhysicalLocation({
    required this.id,
    required this.nameEncrypted,
    this.descriptionEncrypted,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_encrypted'] = Variable<String>(nameEncrypted);
    if (!nullToAbsent || descriptionEncrypted != null) {
      map['description_encrypted'] = Variable<String>(descriptionEncrypted);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PhysicalLocationsCompanion toCompanion(bool nullToAbsent) {
    return PhysicalLocationsCompanion(
      id: Value(id),
      nameEncrypted: Value(nameEncrypted),
      descriptionEncrypted: descriptionEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEncrypted),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PhysicalLocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhysicalLocation(
      id: serializer.fromJson<String>(json['id']),
      nameEncrypted: serializer.fromJson<String>(json['nameEncrypted']),
      descriptionEncrypted: serializer.fromJson<String?>(
        json['descriptionEncrypted'],
      ),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameEncrypted': serializer.toJson<String>(nameEncrypted),
      'descriptionEncrypted': serializer.toJson<String?>(descriptionEncrypted),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PhysicalLocation copyWith({
    String? id,
    String? nameEncrypted,
    Value<String?> descriptionEncrypted = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PhysicalLocation(
    id: id ?? this.id,
    nameEncrypted: nameEncrypted ?? this.nameEncrypted,
    descriptionEncrypted: descriptionEncrypted.present
        ? descriptionEncrypted.value
        : this.descriptionEncrypted,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PhysicalLocation copyWithCompanion(PhysicalLocationsCompanion data) {
    return PhysicalLocation(
      id: data.id.present ? data.id.value : this.id,
      nameEncrypted: data.nameEncrypted.present
          ? data.nameEncrypted.value
          : this.nameEncrypted,
      descriptionEncrypted: data.descriptionEncrypted.present
          ? data.descriptionEncrypted.value
          : this.descriptionEncrypted,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhysicalLocation(')
          ..write('id: $id, ')
          ..write('nameEncrypted: $nameEncrypted, ')
          ..write('descriptionEncrypted: $descriptionEncrypted, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nameEncrypted,
    descriptionEncrypted,
    isArchived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhysicalLocation &&
          other.id == this.id &&
          other.nameEncrypted == this.nameEncrypted &&
          other.descriptionEncrypted == this.descriptionEncrypted &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PhysicalLocationsCompanion extends UpdateCompanion<PhysicalLocation> {
  final Value<String> id;
  final Value<String> nameEncrypted;
  final Value<String?> descriptionEncrypted;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PhysicalLocationsCompanion({
    this.id = const Value.absent(),
    this.nameEncrypted = const Value.absent(),
    this.descriptionEncrypted = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhysicalLocationsCompanion.insert({
    required String id,
    required String nameEncrypted,
    this.descriptionEncrypted = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameEncrypted = Value(nameEncrypted),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PhysicalLocation> custom({
    Expression<String>? id,
    Expression<String>? nameEncrypted,
    Expression<String>? descriptionEncrypted,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameEncrypted != null) 'name_encrypted': nameEncrypted,
      if (descriptionEncrypted != null)
        'description_encrypted': descriptionEncrypted,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhysicalLocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? nameEncrypted,
    Value<String?>? descriptionEncrypted,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PhysicalLocationsCompanion(
      id: id ?? this.id,
      nameEncrypted: nameEncrypted ?? this.nameEncrypted,
      descriptionEncrypted: descriptionEncrypted ?? this.descriptionEncrypted,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameEncrypted.present) {
      map['name_encrypted'] = Variable<String>(nameEncrypted.value);
    }
    if (descriptionEncrypted.present) {
      map['description_encrypted'] = Variable<String>(
        descriptionEncrypted.value,
      );
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhysicalLocationsCompanion(')
          ..write('id: $id, ')
          ..write('nameEncrypted: $nameEncrypted, ')
          ..write('descriptionEncrypted: $descriptionEncrypted, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleEncryptedMeta = const VerificationMeta(
    'titleEncrypted',
  );
  @override
  late final GeneratedColumn<String> titleEncrypted = GeneratedColumn<String>(
    'title_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_categories (id)',
    ),
  );
  static const VerificationMeta _primaryOwnerIdMeta = const VerificationMeta(
    'primaryOwnerId',
  );
  @override
  late final GeneratedColumn<String> primaryOwnerId = GeneratedColumn<String>(
    'primary_owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES family_members (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _ownershipTypeMeta = const VerificationMeta(
    'ownershipType',
  );
  @override
  late final GeneratedColumn<String> ownershipType = GeneratedColumn<String>(
    'ownership_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('personal'),
  );
  static const VerificationMeta _documentNumberEncryptedMeta =
      const VerificationMeta('documentNumberEncrypted');
  @override
  late final GeneratedColumn<String> documentNumberEncrypted =
      GeneratedColumn<String>(
        'document_number_encrypted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _issueDateMeta = const VerificationMeta(
    'issueDate',
  );
  @override
  late final GeneratedColumn<DateTime> issueDate = GeneratedColumn<DateTime>(
    'issue_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issuingAuthorityEncryptedMeta =
      const VerificationMeta('issuingAuthorityEncrypted');
  @override
  late final GeneratedColumn<String> issuingAuthorityEncrypted =
      GeneratedColumn<String>(
        'issuing_authority_encrypted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _descriptionEncryptedMeta =
      const VerificationMeta('descriptionEncrypted');
  @override
  late final GeneratedColumn<String> descriptionEncrypted =
      GeneratedColumn<String>(
        'description_encrypted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesEncryptedMeta = const VerificationMeta(
    'notesEncrypted',
  );
  @override
  late final GeneratedColumn<String> notesEncrypted = GeneratedColumn<String>(
    'notes_encrypted',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _physicalLocationIdMeta =
      const VerificationMeta('physicalLocationId');
  @override
  late final GeneratedColumn<String> physicalLocationId =
      GeneratedColumn<String>(
        'physical_location_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES physical_locations (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currentVersionIdMeta = const VerificationMeta(
    'currentVersionId',
  );
  @override
  late final GeneratedColumn<String> currentVersionId = GeneratedColumn<String>(
    'current_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    titleEncrypted,
    categoryId,
    primaryOwnerId,
    ownershipType,
    documentNumberEncrypted,
    issueDate,
    expiryDate,
    issuingAuthorityEncrypted,
    descriptionEncrypted,
    notesEncrypted,
    physicalLocationId,
    status,
    isFavorite,
    isArchived,
    currentVersionId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Document> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title_encrypted')) {
      context.handle(
        _titleEncryptedMeta,
        titleEncrypted.isAcceptableOrUnknown(
          data['title_encrypted']!,
          _titleEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleEncryptedMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('primary_owner_id')) {
      context.handle(
        _primaryOwnerIdMeta,
        primaryOwnerId.isAcceptableOrUnknown(
          data['primary_owner_id']!,
          _primaryOwnerIdMeta,
        ),
      );
    }
    if (data.containsKey('ownership_type')) {
      context.handle(
        _ownershipTypeMeta,
        ownershipType.isAcceptableOrUnknown(
          data['ownership_type']!,
          _ownershipTypeMeta,
        ),
      );
    }
    if (data.containsKey('document_number_encrypted')) {
      context.handle(
        _documentNumberEncryptedMeta,
        documentNumberEncrypted.isAcceptableOrUnknown(
          data['document_number_encrypted']!,
          _documentNumberEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('issue_date')) {
      context.handle(
        _issueDateMeta,
        issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('issuing_authority_encrypted')) {
      context.handle(
        _issuingAuthorityEncryptedMeta,
        issuingAuthorityEncrypted.isAcceptableOrUnknown(
          data['issuing_authority_encrypted']!,
          _issuingAuthorityEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('description_encrypted')) {
      context.handle(
        _descriptionEncryptedMeta,
        descriptionEncrypted.isAcceptableOrUnknown(
          data['description_encrypted']!,
          _descriptionEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('notes_encrypted')) {
      context.handle(
        _notesEncryptedMeta,
        notesEncrypted.isAcceptableOrUnknown(
          data['notes_encrypted']!,
          _notesEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('physical_location_id')) {
      context.handle(
        _physicalLocationIdMeta,
        physicalLocationId.isAcceptableOrUnknown(
          data['physical_location_id']!,
          _physicalLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('current_version_id')) {
      context.handle(
        _currentVersionIdMeta,
        currentVersionId.isAcceptableOrUnknown(
          data['current_version_id']!,
          _currentVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      titleEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_encrypted'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      primaryOwnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_owner_id'],
      ),
      ownershipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ownership_type'],
      )!,
      documentNumberEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_number_encrypted'],
      ),
      issueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issue_date'],
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
      issuingAuthorityEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuing_authority_encrypted'],
      ),
      descriptionEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_encrypted'],
      ),
      notesEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes_encrypted'],
      ),
      physicalLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}physical_location_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      currentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_version_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final String titleEncrypted;
  final String categoryId;
  final String? primaryOwnerId;
  final String ownershipType;
  final String? documentNumberEncrypted;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issuingAuthorityEncrypted;
  final String? descriptionEncrypted;
  final String? notesEncrypted;
  final String? physicalLocationId;
  final String status;
  final bool isFavorite;
  final bool isArchived;
  final String? currentVersionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Document({
    required this.id,
    required this.titleEncrypted,
    required this.categoryId,
    this.primaryOwnerId,
    required this.ownershipType,
    this.documentNumberEncrypted,
    this.issueDate,
    this.expiryDate,
    this.issuingAuthorityEncrypted,
    this.descriptionEncrypted,
    this.notesEncrypted,
    this.physicalLocationId,
    required this.status,
    required this.isFavorite,
    required this.isArchived,
    this.currentVersionId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title_encrypted'] = Variable<String>(titleEncrypted);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || primaryOwnerId != null) {
      map['primary_owner_id'] = Variable<String>(primaryOwnerId);
    }
    map['ownership_type'] = Variable<String>(ownershipType);
    if (!nullToAbsent || documentNumberEncrypted != null) {
      map['document_number_encrypted'] = Variable<String>(
        documentNumberEncrypted,
      );
    }
    if (!nullToAbsent || issueDate != null) {
      map['issue_date'] = Variable<DateTime>(issueDate);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    if (!nullToAbsent || issuingAuthorityEncrypted != null) {
      map['issuing_authority_encrypted'] = Variable<String>(
        issuingAuthorityEncrypted,
      );
    }
    if (!nullToAbsent || descriptionEncrypted != null) {
      map['description_encrypted'] = Variable<String>(descriptionEncrypted);
    }
    if (!nullToAbsent || notesEncrypted != null) {
      map['notes_encrypted'] = Variable<String>(notesEncrypted);
    }
    if (!nullToAbsent || physicalLocationId != null) {
      map['physical_location_id'] = Variable<String>(physicalLocationId);
    }
    map['status'] = Variable<String>(status);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || currentVersionId != null) {
      map['current_version_id'] = Variable<String>(currentVersionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      titleEncrypted: Value(titleEncrypted),
      categoryId: Value(categoryId),
      primaryOwnerId: primaryOwnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryOwnerId),
      ownershipType: Value(ownershipType),
      documentNumberEncrypted: documentNumberEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(documentNumberEncrypted),
      issueDate: issueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(issueDate),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      issuingAuthorityEncrypted:
          issuingAuthorityEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(issuingAuthorityEncrypted),
      descriptionEncrypted: descriptionEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEncrypted),
      notesEncrypted: notesEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(notesEncrypted),
      physicalLocationId: physicalLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalLocationId),
      status: Value(status),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      currentVersionId: currentVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentVersionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Document.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      titleEncrypted: serializer.fromJson<String>(json['titleEncrypted']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      primaryOwnerId: serializer.fromJson<String?>(json['primaryOwnerId']),
      ownershipType: serializer.fromJson<String>(json['ownershipType']),
      documentNumberEncrypted: serializer.fromJson<String?>(
        json['documentNumberEncrypted'],
      ),
      issueDate: serializer.fromJson<DateTime?>(json['issueDate']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      issuingAuthorityEncrypted: serializer.fromJson<String?>(
        json['issuingAuthorityEncrypted'],
      ),
      descriptionEncrypted: serializer.fromJson<String?>(
        json['descriptionEncrypted'],
      ),
      notesEncrypted: serializer.fromJson<String?>(json['notesEncrypted']),
      physicalLocationId: serializer.fromJson<String?>(
        json['physicalLocationId'],
      ),
      status: serializer.fromJson<String>(json['status']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      currentVersionId: serializer.fromJson<String?>(json['currentVersionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'titleEncrypted': serializer.toJson<String>(titleEncrypted),
      'categoryId': serializer.toJson<String>(categoryId),
      'primaryOwnerId': serializer.toJson<String?>(primaryOwnerId),
      'ownershipType': serializer.toJson<String>(ownershipType),
      'documentNumberEncrypted': serializer.toJson<String?>(
        documentNumberEncrypted,
      ),
      'issueDate': serializer.toJson<DateTime?>(issueDate),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'issuingAuthorityEncrypted': serializer.toJson<String?>(
        issuingAuthorityEncrypted,
      ),
      'descriptionEncrypted': serializer.toJson<String?>(descriptionEncrypted),
      'notesEncrypted': serializer.toJson<String?>(notesEncrypted),
      'physicalLocationId': serializer.toJson<String?>(physicalLocationId),
      'status': serializer.toJson<String>(status),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'currentVersionId': serializer.toJson<String?>(currentVersionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Document copyWith({
    String? id,
    String? titleEncrypted,
    String? categoryId,
    Value<String?> primaryOwnerId = const Value.absent(),
    String? ownershipType,
    Value<String?> documentNumberEncrypted = const Value.absent(),
    Value<DateTime?> issueDate = const Value.absent(),
    Value<DateTime?> expiryDate = const Value.absent(),
    Value<String?> issuingAuthorityEncrypted = const Value.absent(),
    Value<String?> descriptionEncrypted = const Value.absent(),
    Value<String?> notesEncrypted = const Value.absent(),
    Value<String?> physicalLocationId = const Value.absent(),
    String? status,
    bool? isFavorite,
    bool? isArchived,
    Value<String?> currentVersionId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Document(
    id: id ?? this.id,
    titleEncrypted: titleEncrypted ?? this.titleEncrypted,
    categoryId: categoryId ?? this.categoryId,
    primaryOwnerId: primaryOwnerId.present
        ? primaryOwnerId.value
        : this.primaryOwnerId,
    ownershipType: ownershipType ?? this.ownershipType,
    documentNumberEncrypted: documentNumberEncrypted.present
        ? documentNumberEncrypted.value
        : this.documentNumberEncrypted,
    issueDate: issueDate.present ? issueDate.value : this.issueDate,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    issuingAuthorityEncrypted: issuingAuthorityEncrypted.present
        ? issuingAuthorityEncrypted.value
        : this.issuingAuthorityEncrypted,
    descriptionEncrypted: descriptionEncrypted.present
        ? descriptionEncrypted.value
        : this.descriptionEncrypted,
    notesEncrypted: notesEncrypted.present
        ? notesEncrypted.value
        : this.notesEncrypted,
    physicalLocationId: physicalLocationId.present
        ? physicalLocationId.value
        : this.physicalLocationId,
    status: status ?? this.status,
    isFavorite: isFavorite ?? this.isFavorite,
    isArchived: isArchived ?? this.isArchived,
    currentVersionId: currentVersionId.present
        ? currentVersionId.value
        : this.currentVersionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      titleEncrypted: data.titleEncrypted.present
          ? data.titleEncrypted.value
          : this.titleEncrypted,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      primaryOwnerId: data.primaryOwnerId.present
          ? data.primaryOwnerId.value
          : this.primaryOwnerId,
      ownershipType: data.ownershipType.present
          ? data.ownershipType.value
          : this.ownershipType,
      documentNumberEncrypted: data.documentNumberEncrypted.present
          ? data.documentNumberEncrypted.value
          : this.documentNumberEncrypted,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      issuingAuthorityEncrypted: data.issuingAuthorityEncrypted.present
          ? data.issuingAuthorityEncrypted.value
          : this.issuingAuthorityEncrypted,
      descriptionEncrypted: data.descriptionEncrypted.present
          ? data.descriptionEncrypted.value
          : this.descriptionEncrypted,
      notesEncrypted: data.notesEncrypted.present
          ? data.notesEncrypted.value
          : this.notesEncrypted,
      physicalLocationId: data.physicalLocationId.present
          ? data.physicalLocationId.value
          : this.physicalLocationId,
      status: data.status.present ? data.status.value : this.status,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      currentVersionId: data.currentVersionId.present
          ? data.currentVersionId.value
          : this.currentVersionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('titleEncrypted: $titleEncrypted, ')
          ..write('categoryId: $categoryId, ')
          ..write('primaryOwnerId: $primaryOwnerId, ')
          ..write('ownershipType: $ownershipType, ')
          ..write('documentNumberEncrypted: $documentNumberEncrypted, ')
          ..write('issueDate: $issueDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('issuingAuthorityEncrypted: $issuingAuthorityEncrypted, ')
          ..write('descriptionEncrypted: $descriptionEncrypted, ')
          ..write('notesEncrypted: $notesEncrypted, ')
          ..write('physicalLocationId: $physicalLocationId, ')
          ..write('status: $status, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('currentVersionId: $currentVersionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    titleEncrypted,
    categoryId,
    primaryOwnerId,
    ownershipType,
    documentNumberEncrypted,
    issueDate,
    expiryDate,
    issuingAuthorityEncrypted,
    descriptionEncrypted,
    notesEncrypted,
    physicalLocationId,
    status,
    isFavorite,
    isArchived,
    currentVersionId,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.titleEncrypted == this.titleEncrypted &&
          other.categoryId == this.categoryId &&
          other.primaryOwnerId == this.primaryOwnerId &&
          other.ownershipType == this.ownershipType &&
          other.documentNumberEncrypted == this.documentNumberEncrypted &&
          other.issueDate == this.issueDate &&
          other.expiryDate == this.expiryDate &&
          other.issuingAuthorityEncrypted == this.issuingAuthorityEncrypted &&
          other.descriptionEncrypted == this.descriptionEncrypted &&
          other.notesEncrypted == this.notesEncrypted &&
          other.physicalLocationId == this.physicalLocationId &&
          other.status == this.status &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.currentVersionId == this.currentVersionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<String> titleEncrypted;
  final Value<String> categoryId;
  final Value<String?> primaryOwnerId;
  final Value<String> ownershipType;
  final Value<String?> documentNumberEncrypted;
  final Value<DateTime?> issueDate;
  final Value<DateTime?> expiryDate;
  final Value<String?> issuingAuthorityEncrypted;
  final Value<String?> descriptionEncrypted;
  final Value<String?> notesEncrypted;
  final Value<String?> physicalLocationId;
  final Value<String> status;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<String?> currentVersionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.titleEncrypted = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.primaryOwnerId = const Value.absent(),
    this.ownershipType = const Value.absent(),
    this.documentNumberEncrypted = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.issuingAuthorityEncrypted = const Value.absent(),
    this.descriptionEncrypted = const Value.absent(),
    this.notesEncrypted = const Value.absent(),
    this.physicalLocationId = const Value.absent(),
    this.status = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.currentVersionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String titleEncrypted,
    required String categoryId,
    this.primaryOwnerId = const Value.absent(),
    this.ownershipType = const Value.absent(),
    this.documentNumberEncrypted = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.issuingAuthorityEncrypted = const Value.absent(),
    this.descriptionEncrypted = const Value.absent(),
    this.notesEncrypted = const Value.absent(),
    this.physicalLocationId = const Value.absent(),
    this.status = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.currentVersionId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       titleEncrypted = Value(titleEncrypted),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<String>? titleEncrypted,
    Expression<String>? categoryId,
    Expression<String>? primaryOwnerId,
    Expression<String>? ownershipType,
    Expression<String>? documentNumberEncrypted,
    Expression<DateTime>? issueDate,
    Expression<DateTime>? expiryDate,
    Expression<String>? issuingAuthorityEncrypted,
    Expression<String>? descriptionEncrypted,
    Expression<String>? notesEncrypted,
    Expression<String>? physicalLocationId,
    Expression<String>? status,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<String>? currentVersionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titleEncrypted != null) 'title_encrypted': titleEncrypted,
      if (categoryId != null) 'category_id': categoryId,
      if (primaryOwnerId != null) 'primary_owner_id': primaryOwnerId,
      if (ownershipType != null) 'ownership_type': ownershipType,
      if (documentNumberEncrypted != null)
        'document_number_encrypted': documentNumberEncrypted,
      if (issueDate != null) 'issue_date': issueDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (issuingAuthorityEncrypted != null)
        'issuing_authority_encrypted': issuingAuthorityEncrypted,
      if (descriptionEncrypted != null)
        'description_encrypted': descriptionEncrypted,
      if (notesEncrypted != null) 'notes_encrypted': notesEncrypted,
      if (physicalLocationId != null)
        'physical_location_id': physicalLocationId,
      if (status != null) 'status': status,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (currentVersionId != null) 'current_version_id': currentVersionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? titleEncrypted,
    Value<String>? categoryId,
    Value<String?>? primaryOwnerId,
    Value<String>? ownershipType,
    Value<String?>? documentNumberEncrypted,
    Value<DateTime?>? issueDate,
    Value<DateTime?>? expiryDate,
    Value<String?>? issuingAuthorityEncrypted,
    Value<String?>? descriptionEncrypted,
    Value<String?>? notesEncrypted,
    Value<String?>? physicalLocationId,
    Value<String>? status,
    Value<bool>? isFavorite,
    Value<bool>? isArchived,
    Value<String?>? currentVersionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      titleEncrypted: titleEncrypted ?? this.titleEncrypted,
      categoryId: categoryId ?? this.categoryId,
      primaryOwnerId: primaryOwnerId ?? this.primaryOwnerId,
      ownershipType: ownershipType ?? this.ownershipType,
      documentNumberEncrypted:
          documentNumberEncrypted ?? this.documentNumberEncrypted,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      issuingAuthorityEncrypted:
          issuingAuthorityEncrypted ?? this.issuingAuthorityEncrypted,
      descriptionEncrypted: descriptionEncrypted ?? this.descriptionEncrypted,
      notesEncrypted: notesEncrypted ?? this.notesEncrypted,
      physicalLocationId: physicalLocationId ?? this.physicalLocationId,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      currentVersionId: currentVersionId ?? this.currentVersionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (titleEncrypted.present) {
      map['title_encrypted'] = Variable<String>(titleEncrypted.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (primaryOwnerId.present) {
      map['primary_owner_id'] = Variable<String>(primaryOwnerId.value);
    }
    if (ownershipType.present) {
      map['ownership_type'] = Variable<String>(ownershipType.value);
    }
    if (documentNumberEncrypted.present) {
      map['document_number_encrypted'] = Variable<String>(
        documentNumberEncrypted.value,
      );
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<DateTime>(issueDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (issuingAuthorityEncrypted.present) {
      map['issuing_authority_encrypted'] = Variable<String>(
        issuingAuthorityEncrypted.value,
      );
    }
    if (descriptionEncrypted.present) {
      map['description_encrypted'] = Variable<String>(
        descriptionEncrypted.value,
      );
    }
    if (notesEncrypted.present) {
      map['notes_encrypted'] = Variable<String>(notesEncrypted.value);
    }
    if (physicalLocationId.present) {
      map['physical_location_id'] = Variable<String>(physicalLocationId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (currentVersionId.present) {
      map['current_version_id'] = Variable<String>(currentVersionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('titleEncrypted: $titleEncrypted, ')
          ..write('categoryId: $categoryId, ')
          ..write('primaryOwnerId: $primaryOwnerId, ')
          ..write('ownershipType: $ownershipType, ')
          ..write('documentNumberEncrypted: $documentNumberEncrypted, ')
          ..write('issueDate: $issueDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('issuingAuthorityEncrypted: $issuingAuthorityEncrypted, ')
          ..write('descriptionEncrypted: $descriptionEncrypted, ')
          ..write('notesEncrypted: $notesEncrypted, ')
          ..write('physicalLocationId: $physicalLocationId, ')
          ..write('status: $status, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('currentVersionId: $currentVersionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentVersionsTable extends DocumentVersions
    with TableInfo<$DocumentVersionsTable, DocumentVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _previousVersionIdMeta = const VerificationMeta(
    'previousVersionId',
  );
  @override
  late final GeneratedColumn<String> previousVersionId =
      GeneratedColumn<String>(
        'previous_version_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isCurrentMeta = const VerificationMeta(
    'isCurrent',
  );
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    previousVersionId,
    isCurrent,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('previous_version_id')) {
      context.handle(
        _previousVersionIdMeta,
        previousVersionId.isAcceptableOrUnknown(
          data['previous_version_id']!,
          _previousVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('is_current')) {
      context.handle(
        _isCurrentMeta,
        isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentVersion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      previousVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_version_id'],
      ),
      isCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DocumentVersionsTable createAlias(String alias) {
    return $DocumentVersionsTable(attachedDatabase, alias);
  }
}

class DocumentVersion extends DataClass implements Insertable<DocumentVersion> {
  final String id;
  final String documentId;
  final String? previousVersionId;
  final bool isCurrent;
  final DateTime createdAt;
  const DocumentVersion({
    required this.id,
    required this.documentId,
    this.previousVersionId,
    required this.isCurrent,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    if (!nullToAbsent || previousVersionId != null) {
      map['previous_version_id'] = Variable<String>(previousVersionId);
    }
    map['is_current'] = Variable<bool>(isCurrent);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DocumentVersionsCompanion toCompanion(bool nullToAbsent) {
    return DocumentVersionsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      previousVersionId: previousVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousVersionId),
      isCurrent: Value(isCurrent),
      createdAt: Value(createdAt),
    );
  }

  factory DocumentVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentVersion(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      previousVersionId: serializer.fromJson<String?>(
        json['previousVersionId'],
      ),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'previousVersionId': serializer.toJson<String?>(previousVersionId),
      'isCurrent': serializer.toJson<bool>(isCurrent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DocumentVersion copyWith({
    String? id,
    String? documentId,
    Value<String?> previousVersionId = const Value.absent(),
    bool? isCurrent,
    DateTime? createdAt,
  }) => DocumentVersion(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    previousVersionId: previousVersionId.present
        ? previousVersionId.value
        : this.previousVersionId,
    isCurrent: isCurrent ?? this.isCurrent,
    createdAt: createdAt ?? this.createdAt,
  );
  DocumentVersion copyWithCompanion(DocumentVersionsCompanion data) {
    return DocumentVersion(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      previousVersionId: data.previousVersionId.present
          ? data.previousVersionId.value
          : this.previousVersionId,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentVersion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('previousVersionId: $previousVersionId, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, documentId, previousVersionId, isCurrent, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentVersion &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.previousVersionId == this.previousVersionId &&
          other.isCurrent == this.isCurrent &&
          other.createdAt == this.createdAt);
}

class DocumentVersionsCompanion extends UpdateCompanion<DocumentVersion> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String?> previousVersionId;
  final Value<bool> isCurrent;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DocumentVersionsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.previousVersionId = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentVersionsCompanion.insert({
    required String id,
    required String documentId,
    this.previousVersionId = const Value.absent(),
    this.isCurrent = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       createdAt = Value(createdAt);
  static Insertable<DocumentVersion> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? previousVersionId,
    Expression<bool>? isCurrent,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (previousVersionId != null) 'previous_version_id': previousVersionId,
      if (isCurrent != null) 'is_current': isCurrent,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentVersionsCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String?>? previousVersionId,
    Value<bool>? isCurrent,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DocumentVersionsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      previousVersionId: previousVersionId ?? this.previousVersionId,
      isCurrent: isCurrent ?? this.isCurrent,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (previousVersionId.present) {
      map['previous_version_id'] = Variable<String>(previousVersionId.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentVersionsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('previousVersionId: $previousVersionId, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentOwnersTable extends DocumentOwners
    with TableInfo<$DocumentOwnersTable, DocumentOwner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentOwnersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _familyMemberIdMeta = const VerificationMeta(
    'familyMemberId',
  );
  @override
  late final GeneratedColumn<String> familyMemberId = GeneratedColumn<String>(
    'family_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES family_members (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  @override
  List<GeneratedColumn> get $columns => [documentId, familyMemberId, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_owners';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentOwner> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('family_member_id')) {
      context.handle(
        _familyMemberIdMeta,
        familyMemberId.isAcceptableOrUnknown(
          data['family_member_id']!,
          _familyMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_familyMemberIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentId, familyMemberId};
  @override
  DocumentOwner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentOwner(
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      familyMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_member_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $DocumentOwnersTable createAlias(String alias) {
    return $DocumentOwnersTable(attachedDatabase, alias);
  }
}

class DocumentOwner extends DataClass implements Insertable<DocumentOwner> {
  final String documentId;
  final String familyMemberId;
  final String role;
  const DocumentOwner({
    required this.documentId,
    required this.familyMemberId,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['document_id'] = Variable<String>(documentId);
    map['family_member_id'] = Variable<String>(familyMemberId);
    map['role'] = Variable<String>(role);
    return map;
  }

  DocumentOwnersCompanion toCompanion(bool nullToAbsent) {
    return DocumentOwnersCompanion(
      documentId: Value(documentId),
      familyMemberId: Value(familyMemberId),
      role: Value(role),
    );
  }

  factory DocumentOwner.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentOwner(
      documentId: serializer.fromJson<String>(json['documentId']),
      familyMemberId: serializer.fromJson<String>(json['familyMemberId']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentId': serializer.toJson<String>(documentId),
      'familyMemberId': serializer.toJson<String>(familyMemberId),
      'role': serializer.toJson<String>(role),
    };
  }

  DocumentOwner copyWith({
    String? documentId,
    String? familyMemberId,
    String? role,
  }) => DocumentOwner(
    documentId: documentId ?? this.documentId,
    familyMemberId: familyMemberId ?? this.familyMemberId,
    role: role ?? this.role,
  );
  DocumentOwner copyWithCompanion(DocumentOwnersCompanion data) {
    return DocumentOwner(
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      familyMemberId: data.familyMemberId.present
          ? data.familyMemberId.value
          : this.familyMemberId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentOwner(')
          ..write('documentId: $documentId, ')
          ..write('familyMemberId: $familyMemberId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(documentId, familyMemberId, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentOwner &&
          other.documentId == this.documentId &&
          other.familyMemberId == this.familyMemberId &&
          other.role == this.role);
}

class DocumentOwnersCompanion extends UpdateCompanion<DocumentOwner> {
  final Value<String> documentId;
  final Value<String> familyMemberId;
  final Value<String> role;
  final Value<int> rowid;
  const DocumentOwnersCompanion({
    this.documentId = const Value.absent(),
    this.familyMemberId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentOwnersCompanion.insert({
    required String documentId,
    required String familyMemberId,
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : documentId = Value(documentId),
       familyMemberId = Value(familyMemberId);
  static Insertable<DocumentOwner> custom({
    Expression<String>? documentId,
    Expression<String>? familyMemberId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentId != null) 'document_id': documentId,
      if (familyMemberId != null) 'family_member_id': familyMemberId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentOwnersCompanion copyWith({
    Value<String>? documentId,
    Value<String>? familyMemberId,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return DocumentOwnersCompanion(
      documentId: documentId ?? this.documentId,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (familyMemberId.present) {
      map['family_member_id'] = Variable<String>(familyMemberId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentOwnersCompanion(')
          ..write('documentId: $documentId, ')
          ..write('familyMemberId: $familyMemberId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentFilesTable extends DocumentFiles
    with TableInfo<$DocumentFilesTable, DocumentFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('original'),
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedRelativePathMeta =
      const VerificationMeta('encryptedRelativePath');
  @override
  late final GeneratedColumn<String> encryptedRelativePath =
      GeneratedColumn<String>(
        'encrypted_relative_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      );
  static const VerificationMeta _originalFilenameEncryptedMeta =
      const VerificationMeta('originalFilenameEncrypted');
  @override
  late final GeneratedColumn<String> originalFilenameEncrypted =
      GeneratedColumn<String>(
        'original_filename_encrypted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _integrityHashMeta = const VerificationMeta(
    'integrityHash',
  );
  @override
  late final GeneratedColumn<String> integrityHash = GeneratedColumn<String>(
    'integrity_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptionVersionMeta = const VerificationMeta(
    'encryptionVersion',
  );
  @override
  late final GeneratedColumn<int> encryptionVersion = GeneratedColumn<int>(
    'encryption_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    fileType,
    mimeType,
    encryptedRelativePath,
    originalFilenameEncrypted,
    sizeBytes,
    integrityHash,
    encryptionVersion,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('encrypted_relative_path')) {
      context.handle(
        _encryptedRelativePathMeta,
        encryptedRelativePath.isAcceptableOrUnknown(
          data['encrypted_relative_path']!,
          _encryptedRelativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedRelativePathMeta);
    }
    if (data.containsKey('original_filename_encrypted')) {
      context.handle(
        _originalFilenameEncryptedMeta,
        originalFilenameEncrypted.isAcceptableOrUnknown(
          data['original_filename_encrypted']!,
          _originalFilenameEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('integrity_hash')) {
      context.handle(
        _integrityHashMeta,
        integrityHash.isAcceptableOrUnknown(
          data['integrity_hash']!,
          _integrityHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_integrityHashMeta);
    }
    if (data.containsKey('encryption_version')) {
      context.handle(
        _encryptionVersionMeta,
        encryptionVersion.isAcceptableOrUnknown(
          data['encryption_version']!,
          _encryptionVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptionVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_type'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      encryptedRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_relative_path'],
      )!,
      originalFilenameEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_filename_encrypted'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      integrityHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}integrity_hash'],
      )!,
      encryptionVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}encryption_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DocumentFilesTable createAlias(String alias) {
    return $DocumentFilesTable(attachedDatabase, alias);
  }
}

class DocumentFile extends DataClass implements Insertable<DocumentFile> {
  final String id;
  final String documentId;
  final String fileType;
  final String mimeType;
  final String encryptedRelativePath;
  final String? originalFilenameEncrypted;
  final int sizeBytes;
  final String integrityHash;
  final int encryptionVersion;
  final DateTime createdAt;
  const DocumentFile({
    required this.id,
    required this.documentId,
    required this.fileType,
    required this.mimeType,
    required this.encryptedRelativePath,
    this.originalFilenameEncrypted,
    required this.sizeBytes,
    required this.integrityHash,
    required this.encryptionVersion,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['file_type'] = Variable<String>(fileType);
    map['mime_type'] = Variable<String>(mimeType);
    map['encrypted_relative_path'] = Variable<String>(encryptedRelativePath);
    if (!nullToAbsent || originalFilenameEncrypted != null) {
      map['original_filename_encrypted'] = Variable<String>(
        originalFilenameEncrypted,
      );
    }
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['integrity_hash'] = Variable<String>(integrityHash);
    map['encryption_version'] = Variable<int>(encryptionVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DocumentFilesCompanion toCompanion(bool nullToAbsent) {
    return DocumentFilesCompanion(
      id: Value(id),
      documentId: Value(documentId),
      fileType: Value(fileType),
      mimeType: Value(mimeType),
      encryptedRelativePath: Value(encryptedRelativePath),
      originalFilenameEncrypted:
          originalFilenameEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(originalFilenameEncrypted),
      sizeBytes: Value(sizeBytes),
      integrityHash: Value(integrityHash),
      encryptionVersion: Value(encryptionVersion),
      createdAt: Value(createdAt),
    );
  }

  factory DocumentFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentFile(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      fileType: serializer.fromJson<String>(json['fileType']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      encryptedRelativePath: serializer.fromJson<String>(
        json['encryptedRelativePath'],
      ),
      originalFilenameEncrypted: serializer.fromJson<String?>(
        json['originalFilenameEncrypted'],
      ),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      integrityHash: serializer.fromJson<String>(json['integrityHash']),
      encryptionVersion: serializer.fromJson<int>(json['encryptionVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'fileType': serializer.toJson<String>(fileType),
      'mimeType': serializer.toJson<String>(mimeType),
      'encryptedRelativePath': serializer.toJson<String>(encryptedRelativePath),
      'originalFilenameEncrypted': serializer.toJson<String?>(
        originalFilenameEncrypted,
      ),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'integrityHash': serializer.toJson<String>(integrityHash),
      'encryptionVersion': serializer.toJson<int>(encryptionVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DocumentFile copyWith({
    String? id,
    String? documentId,
    String? fileType,
    String? mimeType,
    String? encryptedRelativePath,
    Value<String?> originalFilenameEncrypted = const Value.absent(),
    int? sizeBytes,
    String? integrityHash,
    int? encryptionVersion,
    DateTime? createdAt,
  }) => DocumentFile(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    fileType: fileType ?? this.fileType,
    mimeType: mimeType ?? this.mimeType,
    encryptedRelativePath: encryptedRelativePath ?? this.encryptedRelativePath,
    originalFilenameEncrypted: originalFilenameEncrypted.present
        ? originalFilenameEncrypted.value
        : this.originalFilenameEncrypted,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    integrityHash: integrityHash ?? this.integrityHash,
    encryptionVersion: encryptionVersion ?? this.encryptionVersion,
    createdAt: createdAt ?? this.createdAt,
  );
  DocumentFile copyWithCompanion(DocumentFilesCompanion data) {
    return DocumentFile(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      encryptedRelativePath: data.encryptedRelativePath.present
          ? data.encryptedRelativePath.value
          : this.encryptedRelativePath,
      originalFilenameEncrypted: data.originalFilenameEncrypted.present
          ? data.originalFilenameEncrypted.value
          : this.originalFilenameEncrypted,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      integrityHash: data.integrityHash.present
          ? data.integrityHash.value
          : this.integrityHash,
      encryptionVersion: data.encryptionVersion.present
          ? data.encryptionVersion.value
          : this.encryptionVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentFile(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('fileType: $fileType, ')
          ..write('mimeType: $mimeType, ')
          ..write('encryptedRelativePath: $encryptedRelativePath, ')
          ..write('originalFilenameEncrypted: $originalFilenameEncrypted, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('integrityHash: $integrityHash, ')
          ..write('encryptionVersion: $encryptionVersion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    fileType,
    mimeType,
    encryptedRelativePath,
    originalFilenameEncrypted,
    sizeBytes,
    integrityHash,
    encryptionVersion,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentFile &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.fileType == this.fileType &&
          other.mimeType == this.mimeType &&
          other.encryptedRelativePath == this.encryptedRelativePath &&
          other.originalFilenameEncrypted == this.originalFilenameEncrypted &&
          other.sizeBytes == this.sizeBytes &&
          other.integrityHash == this.integrityHash &&
          other.encryptionVersion == this.encryptionVersion &&
          other.createdAt == this.createdAt);
}

class DocumentFilesCompanion extends UpdateCompanion<DocumentFile> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> fileType;
  final Value<String> mimeType;
  final Value<String> encryptedRelativePath;
  final Value<String?> originalFilenameEncrypted;
  final Value<int> sizeBytes;
  final Value<String> integrityHash;
  final Value<int> encryptionVersion;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DocumentFilesCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.fileType = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.encryptedRelativePath = const Value.absent(),
    this.originalFilenameEncrypted = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.integrityHash = const Value.absent(),
    this.encryptionVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentFilesCompanion.insert({
    required String id,
    required String documentId,
    this.fileType = const Value.absent(),
    required String mimeType,
    required String encryptedRelativePath,
    this.originalFilenameEncrypted = const Value.absent(),
    required int sizeBytes,
    required String integrityHash,
    required int encryptionVersion,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       mimeType = Value(mimeType),
       encryptedRelativePath = Value(encryptedRelativePath),
       sizeBytes = Value(sizeBytes),
       integrityHash = Value(integrityHash),
       encryptionVersion = Value(encryptionVersion),
       createdAt = Value(createdAt);
  static Insertable<DocumentFile> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? fileType,
    Expression<String>? mimeType,
    Expression<String>? encryptedRelativePath,
    Expression<String>? originalFilenameEncrypted,
    Expression<int>? sizeBytes,
    Expression<String>? integrityHash,
    Expression<int>? encryptionVersion,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (fileType != null) 'file_type': fileType,
      if (mimeType != null) 'mime_type': mimeType,
      if (encryptedRelativePath != null)
        'encrypted_relative_path': encryptedRelativePath,
      if (originalFilenameEncrypted != null)
        'original_filename_encrypted': originalFilenameEncrypted,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (integrityHash != null) 'integrity_hash': integrityHash,
      if (encryptionVersion != null) 'encryption_version': encryptionVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? fileType,
    Value<String>? mimeType,
    Value<String>? encryptedRelativePath,
    Value<String?>? originalFilenameEncrypted,
    Value<int>? sizeBytes,
    Value<String>? integrityHash,
    Value<int>? encryptionVersion,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DocumentFilesCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      fileType: fileType ?? this.fileType,
      mimeType: mimeType ?? this.mimeType,
      encryptedRelativePath:
          encryptedRelativePath ?? this.encryptedRelativePath,
      originalFilenameEncrypted:
          originalFilenameEncrypted ?? this.originalFilenameEncrypted,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      integrityHash: integrityHash ?? this.integrityHash,
      encryptionVersion: encryptionVersion ?? this.encryptionVersion,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (encryptedRelativePath.present) {
      map['encrypted_relative_path'] = Variable<String>(
        encryptedRelativePath.value,
      );
    }
    if (originalFilenameEncrypted.present) {
      map['original_filename_encrypted'] = Variable<String>(
        originalFilenameEncrypted.value,
      );
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (integrityHash.present) {
      map['integrity_hash'] = Variable<String>(integrityHash.value);
    }
    if (encryptionVersion.present) {
      map['encryption_version'] = Variable<int>(encryptionVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentFilesCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('fileType: $fileType, ')
          ..write('mimeType: $mimeType, ')
          ..write('encryptedRelativePath: $encryptedRelativePath, ')
          ..write('originalFilenameEncrypted: $originalFilenameEncrypted, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('integrityHash: $integrityHash, ')
          ..write('encryptionVersion: $encryptionVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentPagesTable extends DocumentPages
    with TableInfo<$DocumentPagesTable, DocumentPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _documentFileIdMeta = const VerificationMeta(
    'documentFileId',
  );
  @override
  late final GeneratedColumn<String> documentFileId = GeneratedColumn<String>(
    'document_file_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_files (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPathMeta = const VerificationMeta(
    'encryptedPath',
  );
  @override
  late final GeneratedColumn<String> encryptedPath = GeneratedColumn<String>(
    'encrypted_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rotationMeta = const VerificationMeta(
    'rotation',
  );
  @override
  late final GeneratedColumn<int> rotation = GeneratedColumn<int>(
    'rotation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    documentFileId,
    pageNumber,
    encryptedPath,
    thumbnailPath,
    rotation,
    width,
    height,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentPage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('document_file_id')) {
      context.handle(
        _documentFileIdMeta,
        documentFileId.isAcceptableOrUnknown(
          data['document_file_id']!,
          _documentFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentFileIdMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('encrypted_path')) {
      context.handle(
        _encryptedPathMeta,
        encryptedPath.isAcceptableOrUnknown(
          data['encrypted_path']!,
          _encryptedPathMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('rotation')) {
      context.handle(
        _rotationMeta,
        rotation.isAcceptableOrUnknown(data['rotation']!, _rotationMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {documentId, pageNumber},
  ];
  @override
  DocumentPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentPage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      documentFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_file_id'],
      )!,
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      )!,
      encryptedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_path'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      rotation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rotation'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DocumentPagesTable createAlias(String alias) {
    return $DocumentPagesTable(attachedDatabase, alias);
  }
}

class DocumentPage extends DataClass implements Insertable<DocumentPage> {
  final String id;
  final String documentId;
  final String documentFileId;
  final int pageNumber;
  final String? encryptedPath;
  final String? thumbnailPath;
  final int rotation;
  final int? width;
  final int? height;
  final DateTime createdAt;
  const DocumentPage({
    required this.id,
    required this.documentId,
    required this.documentFileId,
    required this.pageNumber,
    this.encryptedPath,
    this.thumbnailPath,
    required this.rotation,
    this.width,
    this.height,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['document_file_id'] = Variable<String>(documentFileId);
    map['page_number'] = Variable<int>(pageNumber);
    if (!nullToAbsent || encryptedPath != null) {
      map['encrypted_path'] = Variable<String>(encryptedPath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['rotation'] = Variable<int>(rotation);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DocumentPagesCompanion toCompanion(bool nullToAbsent) {
    return DocumentPagesCompanion(
      id: Value(id),
      documentId: Value(documentId),
      documentFileId: Value(documentFileId),
      pageNumber: Value(pageNumber),
      encryptedPath: encryptedPath == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      rotation: Value(rotation),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      createdAt: Value(createdAt),
    );
  }

  factory DocumentPage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentPage(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      documentFileId: serializer.fromJson<String>(json['documentFileId']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      encryptedPath: serializer.fromJson<String?>(json['encryptedPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      rotation: serializer.fromJson<int>(json['rotation']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'documentFileId': serializer.toJson<String>(documentFileId),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'encryptedPath': serializer.toJson<String?>(encryptedPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'rotation': serializer.toJson<int>(rotation),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DocumentPage copyWith({
    String? id,
    String? documentId,
    String? documentFileId,
    int? pageNumber,
    Value<String?> encryptedPath = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    int? rotation,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    DateTime? createdAt,
  }) => DocumentPage(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    documentFileId: documentFileId ?? this.documentFileId,
    pageNumber: pageNumber ?? this.pageNumber,
    encryptedPath: encryptedPath.present
        ? encryptedPath.value
        : this.encryptedPath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    rotation: rotation ?? this.rotation,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    createdAt: createdAt ?? this.createdAt,
  );
  DocumentPage copyWithCompanion(DocumentPagesCompanion data) {
    return DocumentPage(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      documentFileId: data.documentFileId.present
          ? data.documentFileId.value
          : this.documentFileId,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      encryptedPath: data.encryptedPath.present
          ? data.encryptedPath.value
          : this.encryptedPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      rotation: data.rotation.present ? data.rotation.value : this.rotation,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentPage(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('documentFileId: $documentFileId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rotation: $rotation, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    documentFileId,
    pageNumber,
    encryptedPath,
    thumbnailPath,
    rotation,
    width,
    height,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentPage &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.documentFileId == this.documentFileId &&
          other.pageNumber == this.pageNumber &&
          other.encryptedPath == this.encryptedPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.rotation == this.rotation &&
          other.width == this.width &&
          other.height == this.height &&
          other.createdAt == this.createdAt);
}

class DocumentPagesCompanion extends UpdateCompanion<DocumentPage> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> documentFileId;
  final Value<int> pageNumber;
  final Value<String?> encryptedPath;
  final Value<String?> thumbnailPath;
  final Value<int> rotation;
  final Value<int?> width;
  final Value<int?> height;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DocumentPagesCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.documentFileId = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.encryptedPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rotation = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentPagesCompanion.insert({
    required String id,
    required String documentId,
    required String documentFileId,
    required int pageNumber,
    this.encryptedPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rotation = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       documentFileId = Value(documentFileId),
       pageNumber = Value(pageNumber),
       createdAt = Value(createdAt);
  static Insertable<DocumentPage> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? documentFileId,
    Expression<int>? pageNumber,
    Expression<String>? encryptedPath,
    Expression<String>? thumbnailPath,
    Expression<int>? rotation,
    Expression<int>? width,
    Expression<int>? height,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (documentFileId != null) 'document_file_id': documentFileId,
      if (pageNumber != null) 'page_number': pageNumber,
      if (encryptedPath != null) 'encrypted_path': encryptedPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (rotation != null) 'rotation': rotation,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentPagesCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? documentFileId,
    Value<int>? pageNumber,
    Value<String?>? encryptedPath,
    Value<String?>? thumbnailPath,
    Value<int>? rotation,
    Value<int?>? width,
    Value<int?>? height,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DocumentPagesCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentFileId: documentFileId ?? this.documentFileId,
      pageNumber: pageNumber ?? this.pageNumber,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      rotation: rotation ?? this.rotation,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (documentFileId.present) {
      map['document_file_id'] = Variable<String>(documentFileId.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (encryptedPath.present) {
      map['encrypted_path'] = Variable<String>(encryptedPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (rotation.present) {
      map['rotation'] = Variable<int>(rotation.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentPagesCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('documentFileId: $documentFileId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rotation: $rotation, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentFieldValuesTable extends DocumentFieldValues
    with TableInfo<$DocumentFieldValuesTable, DocumentFieldValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentFieldValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fieldKeyMeta = const VerificationMeta(
    'fieldKey',
  );
  @override
  late final GeneratedColumn<String> fieldKey = GeneratedColumn<String>(
    'field_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelEncryptedMeta = const VerificationMeta(
    'labelEncrypted',
  );
  @override
  late final GeneratedColumn<String> labelEncrypted = GeneratedColumn<String>(
    'label_encrypted',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueEncryptedMeta = const VerificationMeta(
    'valueEncrypted',
  );
  @override
  late final GeneratedColumn<String> valueEncrypted = GeneratedColumn<String>(
    'value_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  @override
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    fieldKey,
    labelEncrypted,
    valueEncrypted,
    valueType,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_field_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentFieldValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('field_key')) {
      context.handle(
        _fieldKeyMeta,
        fieldKey.isAcceptableOrUnknown(data['field_key']!, _fieldKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldKeyMeta);
    }
    if (data.containsKey('label_encrypted')) {
      context.handle(
        _labelEncryptedMeta,
        labelEncrypted.isAcceptableOrUnknown(
          data['label_encrypted']!,
          _labelEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('value_encrypted')) {
      context.handle(
        _valueEncryptedMeta,
        valueEncrypted.isAcceptableOrUnknown(
          data['value_encrypted']!,
          _valueEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valueEncryptedMeta);
    }
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {documentId, fieldKey},
  ];
  @override
  DocumentFieldValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentFieldValue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      fieldKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_key'],
      )!,
      labelEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_encrypted'],
      ),
      valueEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_encrypted'],
      )!,
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DocumentFieldValuesTable createAlias(String alias) {
    return $DocumentFieldValuesTable(attachedDatabase, alias);
  }
}

class DocumentFieldValue extends DataClass
    implements Insertable<DocumentFieldValue> {
  final String id;
  final String documentId;
  final String fieldKey;
  final String? labelEncrypted;
  final String valueEncrypted;
  final String valueType;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DocumentFieldValue({
    required this.id,
    required this.documentId,
    required this.fieldKey,
    this.labelEncrypted,
    required this.valueEncrypted,
    required this.valueType,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['field_key'] = Variable<String>(fieldKey);
    if (!nullToAbsent || labelEncrypted != null) {
      map['label_encrypted'] = Variable<String>(labelEncrypted);
    }
    map['value_encrypted'] = Variable<String>(valueEncrypted);
    map['value_type'] = Variable<String>(valueType);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DocumentFieldValuesCompanion toCompanion(bool nullToAbsent) {
    return DocumentFieldValuesCompanion(
      id: Value(id),
      documentId: Value(documentId),
      fieldKey: Value(fieldKey),
      labelEncrypted: labelEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(labelEncrypted),
      valueEncrypted: Value(valueEncrypted),
      valueType: Value(valueType),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DocumentFieldValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentFieldValue(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      fieldKey: serializer.fromJson<String>(json['fieldKey']),
      labelEncrypted: serializer.fromJson<String?>(json['labelEncrypted']),
      valueEncrypted: serializer.fromJson<String>(json['valueEncrypted']),
      valueType: serializer.fromJson<String>(json['valueType']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'fieldKey': serializer.toJson<String>(fieldKey),
      'labelEncrypted': serializer.toJson<String?>(labelEncrypted),
      'valueEncrypted': serializer.toJson<String>(valueEncrypted),
      'valueType': serializer.toJson<String>(valueType),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DocumentFieldValue copyWith({
    String? id,
    String? documentId,
    String? fieldKey,
    Value<String?> labelEncrypted = const Value.absent(),
    String? valueEncrypted,
    String? valueType,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DocumentFieldValue(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    fieldKey: fieldKey ?? this.fieldKey,
    labelEncrypted: labelEncrypted.present
        ? labelEncrypted.value
        : this.labelEncrypted,
    valueEncrypted: valueEncrypted ?? this.valueEncrypted,
    valueType: valueType ?? this.valueType,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DocumentFieldValue copyWithCompanion(DocumentFieldValuesCompanion data) {
    return DocumentFieldValue(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      fieldKey: data.fieldKey.present ? data.fieldKey.value : this.fieldKey,
      labelEncrypted: data.labelEncrypted.present
          ? data.labelEncrypted.value
          : this.labelEncrypted,
      valueEncrypted: data.valueEncrypted.present
          ? data.valueEncrypted.value
          : this.valueEncrypted,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentFieldValue(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('fieldKey: $fieldKey, ')
          ..write('labelEncrypted: $labelEncrypted, ')
          ..write('valueEncrypted: $valueEncrypted, ')
          ..write('valueType: $valueType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    fieldKey,
    labelEncrypted,
    valueEncrypted,
    valueType,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentFieldValue &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.fieldKey == this.fieldKey &&
          other.labelEncrypted == this.labelEncrypted &&
          other.valueEncrypted == this.valueEncrypted &&
          other.valueType == this.valueType &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DocumentFieldValuesCompanion extends UpdateCompanion<DocumentFieldValue> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> fieldKey;
  final Value<String?> labelEncrypted;
  final Value<String> valueEncrypted;
  final Value<String> valueType;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DocumentFieldValuesCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.fieldKey = const Value.absent(),
    this.labelEncrypted = const Value.absent(),
    this.valueEncrypted = const Value.absent(),
    this.valueType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentFieldValuesCompanion.insert({
    required String id,
    required String documentId,
    required String fieldKey,
    this.labelEncrypted = const Value.absent(),
    required String valueEncrypted,
    this.valueType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       fieldKey = Value(fieldKey),
       valueEncrypted = Value(valueEncrypted),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DocumentFieldValue> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? fieldKey,
    Expression<String>? labelEncrypted,
    Expression<String>? valueEncrypted,
    Expression<String>? valueType,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (fieldKey != null) 'field_key': fieldKey,
      if (labelEncrypted != null) 'label_encrypted': labelEncrypted,
      if (valueEncrypted != null) 'value_encrypted': valueEncrypted,
      if (valueType != null) 'value_type': valueType,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentFieldValuesCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? fieldKey,
    Value<String?>? labelEncrypted,
    Value<String>? valueEncrypted,
    Value<String>? valueType,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DocumentFieldValuesCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      fieldKey: fieldKey ?? this.fieldKey,
      labelEncrypted: labelEncrypted ?? this.labelEncrypted,
      valueEncrypted: valueEncrypted ?? this.valueEncrypted,
      valueType: valueType ?? this.valueType,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (fieldKey.present) {
      map['field_key'] = Variable<String>(fieldKey.value);
    }
    if (labelEncrypted.present) {
      map['label_encrypted'] = Variable<String>(labelEncrypted.value);
    }
    if (valueEncrypted.present) {
      map['value_encrypted'] = Variable<String>(valueEncrypted.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentFieldValuesCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('fieldKey: $fieldKey, ')
          ..write('labelEncrypted: $labelEncrypted, ')
          ..write('valueEncrypted: $valueEncrypted, ')
          ..write('valueType: $valueType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEncryptedMeta = const VerificationMeta(
    'nameEncrypted',
  );
  @override
  late final GeneratedColumn<String> nameEncrypted = GeneratedColumn<String>(
    'name_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameHashMeta =
      const VerificationMeta('normalizedNameHash');
  @override
  late final GeneratedColumn<String> normalizedNameHash =
      GeneratedColumn<String>(
        'normalized_name_hash',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameEncrypted,
    normalizedNameHash,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_encrypted')) {
      context.handle(
        _nameEncryptedMeta,
        nameEncrypted.isAcceptableOrUnknown(
          data['name_encrypted']!,
          _nameEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameEncryptedMeta);
    }
    if (data.containsKey('normalized_name_hash')) {
      context.handle(
        _normalizedNameHashMeta,
        normalizedNameHash.isAcceptableOrUnknown(
          data['normalized_name_hash']!,
          _normalizedNameHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameHashMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_encrypted'],
      )!,
      normalizedNameHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name_hash'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String nameEncrypted;
  final String normalizedNameHash;
  final DateTime createdAt;
  const Tag({
    required this.id,
    required this.nameEncrypted,
    required this.normalizedNameHash,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_encrypted'] = Variable<String>(nameEncrypted);
    map['normalized_name_hash'] = Variable<String>(normalizedNameHash);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      nameEncrypted: Value(nameEncrypted),
      normalizedNameHash: Value(normalizedNameHash),
      createdAt: Value(createdAt),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      nameEncrypted: serializer.fromJson<String>(json['nameEncrypted']),
      normalizedNameHash: serializer.fromJson<String>(
        json['normalizedNameHash'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameEncrypted': serializer.toJson<String>(nameEncrypted),
      'normalizedNameHash': serializer.toJson<String>(normalizedNameHash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tag copyWith({
    String? id,
    String? nameEncrypted,
    String? normalizedNameHash,
    DateTime? createdAt,
  }) => Tag(
    id: id ?? this.id,
    nameEncrypted: nameEncrypted ?? this.nameEncrypted,
    normalizedNameHash: normalizedNameHash ?? this.normalizedNameHash,
    createdAt: createdAt ?? this.createdAt,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      nameEncrypted: data.nameEncrypted.present
          ? data.nameEncrypted.value
          : this.nameEncrypted,
      normalizedNameHash: data.normalizedNameHash.present
          ? data.normalizedNameHash.value
          : this.normalizedNameHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('nameEncrypted: $nameEncrypted, ')
          ..write('normalizedNameHash: $normalizedNameHash, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nameEncrypted, normalizedNameHash, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.nameEncrypted == this.nameEncrypted &&
          other.normalizedNameHash == this.normalizedNameHash &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> nameEncrypted;
  final Value<String> normalizedNameHash;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.nameEncrypted = const Value.absent(),
    this.normalizedNameHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String nameEncrypted,
    required String normalizedNameHash,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameEncrypted = Value(nameEncrypted),
       normalizedNameHash = Value(normalizedNameHash),
       createdAt = Value(createdAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? nameEncrypted,
    Expression<String>? normalizedNameHash,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameEncrypted != null) 'name_encrypted': nameEncrypted,
      if (normalizedNameHash != null)
        'normalized_name_hash': normalizedNameHash,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? nameEncrypted,
    Value<String>? normalizedNameHash,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      nameEncrypted: nameEncrypted ?? this.nameEncrypted,
      normalizedNameHash: normalizedNameHash ?? this.normalizedNameHash,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameEncrypted.present) {
      map['name_encrypted'] = Variable<String>(nameEncrypted.value);
    }
    if (normalizedNameHash.present) {
      map['normalized_name_hash'] = Variable<String>(normalizedNameHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('nameEncrypted: $nameEncrypted, ')
          ..write('normalizedNameHash: $normalizedNameHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentTagsTable extends DocumentTags
    with TableInfo<$DocumentTagsTable, DocumentTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [documentId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentId, tagId};
  @override
  DocumentTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentTag(
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $DocumentTagsTable createAlias(String alias) {
    return $DocumentTagsTable(attachedDatabase, alias);
  }
}

class DocumentTag extends DataClass implements Insertable<DocumentTag> {
  final String documentId;
  final String tagId;
  const DocumentTag({required this.documentId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['document_id'] = Variable<String>(documentId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  DocumentTagsCompanion toCompanion(bool nullToAbsent) {
    return DocumentTagsCompanion(
      documentId: Value(documentId),
      tagId: Value(tagId),
    );
  }

  factory DocumentTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentTag(
      documentId: serializer.fromJson<String>(json['documentId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentId': serializer.toJson<String>(documentId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  DocumentTag copyWith({String? documentId, String? tagId}) => DocumentTag(
    documentId: documentId ?? this.documentId,
    tagId: tagId ?? this.tagId,
  );
  DocumentTag copyWithCompanion(DocumentTagsCompanion data) {
    return DocumentTag(
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentTag(')
          ..write('documentId: $documentId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(documentId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentTag &&
          other.documentId == this.documentId &&
          other.tagId == this.tagId);
}

class DocumentTagsCompanion extends UpdateCompanion<DocumentTag> {
  final Value<String> documentId;
  final Value<String> tagId;
  final Value<int> rowid;
  const DocumentTagsCompanion({
    this.documentId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentTagsCompanion.insert({
    required String documentId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : documentId = Value(documentId),
       tagId = Value(tagId);
  static Insertable<DocumentTag> custom({
    Expression<String>? documentId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentId != null) 'document_id': documentId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentTagsCompanion copyWith({
    Value<String>? documentId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return DocumentTagsCompanion(
      documentId: documentId ?? this.documentId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentTagsCompanion(')
          ..write('documentId: $documentId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _reminderTypeMeta = const VerificationMeta(
    'reminderType',
  );
  @override
  late final GeneratedColumn<String> reminderType = GeneratedColumn<String>(
    'reminder_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('expiry'),
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offsetDaysMeta = const VerificationMeta(
    'offsetDays',
  );
  @override
  late final GeneratedColumn<int> offsetDays = GeneratedColumn<int>(
    'offset_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scheduled'),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    reminderType,
    targetDate,
    offsetDays,
    scheduledAt,
    status,
    notificationId,
    snoozedUntil,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('reminder_type')) {
      context.handle(
        _reminderTypeMeta,
        reminderType.isAcceptableOrUnknown(
          data['reminder_type']!,
          _reminderTypeMeta,
        ),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('offset_days')) {
      context.handle(
        _offsetDaysMeta,
        offsetDays.isAcceptableOrUnknown(data['offset_days']!, _offsetDaysMeta),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      reminderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_type'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      )!,
      offsetDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_days'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String documentId;
  final String reminderType;
  final DateTime targetDate;
  final int? offsetDays;
  final DateTime scheduledAt;
  final String status;
  final int? notificationId;
  final DateTime? snoozedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Reminder({
    required this.id,
    required this.documentId,
    required this.reminderType,
    required this.targetDate,
    this.offsetDays,
    required this.scheduledAt,
    required this.status,
    this.notificationId,
    this.snoozedUntil,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['reminder_type'] = Variable<String>(reminderType);
    map['target_date'] = Variable<DateTime>(targetDate);
    if (!nullToAbsent || offsetDays != null) {
      map['offset_days'] = Variable<int>(offsetDays);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<int>(notificationId);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      documentId: Value(documentId),
      reminderType: Value(reminderType),
      targetDate: Value(targetDate),
      offsetDays: offsetDays == null && nullToAbsent
          ? const Value.absent()
          : Value(offsetDays),
      scheduledAt: Value(scheduledAt),
      status: Value(status),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      reminderType: serializer.fromJson<String>(json['reminderType']),
      targetDate: serializer.fromJson<DateTime>(json['targetDate']),
      offsetDays: serializer.fromJson<int?>(json['offsetDays']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      status: serializer.fromJson<String>(json['status']),
      notificationId: serializer.fromJson<int?>(json['notificationId']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'reminderType': serializer.toJson<String>(reminderType),
      'targetDate': serializer.toJson<DateTime>(targetDate),
      'offsetDays': serializer.toJson<int?>(offsetDays),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'status': serializer.toJson<String>(status),
      'notificationId': serializer.toJson<int?>(notificationId),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Reminder copyWith({
    String? id,
    String? documentId,
    String? reminderType,
    DateTime? targetDate,
    Value<int?> offsetDays = const Value.absent(),
    DateTime? scheduledAt,
    String? status,
    Value<int?> notificationId = const Value.absent(),
    Value<DateTime?> snoozedUntil = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Reminder(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    reminderType: reminderType ?? this.reminderType,
    targetDate: targetDate ?? this.targetDate,
    offsetDays: offsetDays.present ? offsetDays.value : this.offsetDays,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    status: status ?? this.status,
    notificationId: notificationId.present
        ? notificationId.value
        : this.notificationId,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      reminderType: data.reminderType.present
          ? data.reminderType.value
          : this.reminderType,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      offsetDays: data.offsetDays.present
          ? data.offsetDays.value
          : this.offsetDays,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      status: data.status.present ? data.status.value : this.status,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('reminderType: $reminderType, ')
          ..write('targetDate: $targetDate, ')
          ..write('offsetDays: $offsetDays, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('notificationId: $notificationId, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    reminderType,
    targetDate,
    offsetDays,
    scheduledAt,
    status,
    notificationId,
    snoozedUntil,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.reminderType == this.reminderType &&
          other.targetDate == this.targetDate &&
          other.offsetDays == this.offsetDays &&
          other.scheduledAt == this.scheduledAt &&
          other.status == this.status &&
          other.notificationId == this.notificationId &&
          other.snoozedUntil == this.snoozedUntil &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> reminderType;
  final Value<DateTime> targetDate;
  final Value<int?> offsetDays;
  final Value<DateTime> scheduledAt;
  final Value<String> status;
  final Value<int?> notificationId;
  final Value<DateTime?> snoozedUntil;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.reminderType = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.offsetDays = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String documentId,
    this.reminderType = const Value.absent(),
    required DateTime targetDate,
    this.offsetDays = const Value.absent(),
    required DateTime scheduledAt,
    this.status = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       targetDate = Value(targetDate),
       scheduledAt = Value(scheduledAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? reminderType,
    Expression<DateTime>? targetDate,
    Expression<int>? offsetDays,
    Expression<DateTime>? scheduledAt,
    Expression<String>? status,
    Expression<int>? notificationId,
    Expression<DateTime>? snoozedUntil,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (reminderType != null) 'reminder_type': reminderType,
      if (targetDate != null) 'target_date': targetDate,
      if (offsetDays != null) 'offset_days': offsetDays,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (status != null) 'status': status,
      if (notificationId != null) 'notification_id': notificationId,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? reminderType,
    Value<DateTime>? targetDate,
    Value<int?>? offsetDays,
    Value<DateTime>? scheduledAt,
    Value<String>? status,
    Value<int?>? notificationId,
    Value<DateTime?>? snoozedUntil,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      reminderType: reminderType ?? this.reminderType,
      targetDate: targetDate ?? this.targetDate,
      offsetDays: offsetDays ?? this.offsetDays,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      notificationId: notificationId ?? this.notificationId,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (reminderType.present) {
      map['reminder_type'] = Variable<String>(reminderType.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (offsetDays.present) {
      map['offset_days'] = Variable<int>(offsetDays.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('reminderType: $reminderType, ')
          ..write('targetDate: $targetDate, ')
          ..write('offsetDays: $offsetDays, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('notificationId: $notificationId, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupRecordsTable extends BackupRecords
    with TableInfo<$BackupRecordsTable, BackupRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verifiedMeta = const VerificationMeta(
    'verified',
  );
  @override
  late final GeneratedColumn<bool> verified = GeneratedColumn<bool>(
    'verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("verified" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    relativePath,
    createdAt,
    sizeBytes,
    verified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('verified')) {
      context.handle(
        _verifiedMeta,
        verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta),
      );
    } else if (isInserting) {
      context.missing(_verifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      verified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}verified'],
      )!,
    );
  }

  @override
  $BackupRecordsTable createAlias(String alias) {
    return $BackupRecordsTable(attachedDatabase, alias);
  }
}

class BackupRecord extends DataClass implements Insertable<BackupRecord> {
  final String id;
  final String? relativePath;
  final DateTime createdAt;
  final int sizeBytes;
  final bool verified;
  const BackupRecord({
    required this.id,
    this.relativePath,
    required this.createdAt,
    required this.sizeBytes,
    required this.verified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || relativePath != null) {
      map['relative_path'] = Variable<String>(relativePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['verified'] = Variable<bool>(verified);
    return map;
  }

  BackupRecordsCompanion toCompanion(bool nullToAbsent) {
    return BackupRecordsCompanion(
      id: Value(id),
      relativePath: relativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(relativePath),
      createdAt: Value(createdAt),
      sizeBytes: Value(sizeBytes),
      verified: Value(verified),
    );
  }

  factory BackupRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupRecord(
      id: serializer.fromJson<String>(json['id']),
      relativePath: serializer.fromJson<String?>(json['relativePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      verified: serializer.fromJson<bool>(json['verified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'relativePath': serializer.toJson<String?>(relativePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'verified': serializer.toJson<bool>(verified),
    };
  }

  BackupRecord copyWith({
    String? id,
    Value<String?> relativePath = const Value.absent(),
    DateTime? createdAt,
    int? sizeBytes,
    bool? verified,
  }) => BackupRecord(
    id: id ?? this.id,
    relativePath: relativePath.present ? relativePath.value : this.relativePath,
    createdAt: createdAt ?? this.createdAt,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    verified: verified ?? this.verified,
  );
  BackupRecord copyWithCompanion(BackupRecordsCompanion data) {
    return BackupRecord(
      id: data.id.present ? data.id.value : this.id,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      verified: data.verified.present ? data.verified.value : this.verified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecord(')
          ..write('id: $id, ')
          ..write('relativePath: $relativePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('verified: $verified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, relativePath, createdAt, sizeBytes, verified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRecord &&
          other.id == this.id &&
          other.relativePath == this.relativePath &&
          other.createdAt == this.createdAt &&
          other.sizeBytes == this.sizeBytes &&
          other.verified == this.verified);
}

class BackupRecordsCompanion extends UpdateCompanion<BackupRecord> {
  final Value<String> id;
  final Value<String?> relativePath;
  final Value<DateTime> createdAt;
  final Value<int> sizeBytes;
  final Value<bool> verified;
  final Value<int> rowid;
  const BackupRecordsCompanion({
    this.id = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.verified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupRecordsCompanion.insert({
    required String id,
    this.relativePath = const Value.absent(),
    required DateTime createdAt,
    required int sizeBytes,
    required bool verified,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       sizeBytes = Value(sizeBytes),
       verified = Value(verified);
  static Insertable<BackupRecord> custom({
    Expression<String>? id,
    Expression<String>? relativePath,
    Expression<DateTime>? createdAt,
    Expression<int>? sizeBytes,
    Expression<bool>? verified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (relativePath != null) 'relative_path': relativePath,
      if (createdAt != null) 'created_at': createdAt,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (verified != null) 'verified': verified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupRecordsCompanion copyWith({
    Value<String>? id,
    Value<String?>? relativePath,
    Value<DateTime>? createdAt,
    Value<int>? sizeBytes,
    Value<bool>? verified,
    Value<int>? rowid,
  }) {
    return BackupRecordsCompanion(
      id: id ?? this.id,
      relativePath: relativePath ?? this.relativePath,
      createdAt: createdAt ?? this.createdAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      verified: verified ?? this.verified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (verified.present) {
      map['verified'] = Variable<bool>(verified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecordsCompanion(')
          ..write('id: $id, ')
          ..write('relativePath: $relativePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('verified: $verified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueEncryptedMeta = const VerificationMeta(
    'valueEncrypted',
  );
  @override
  late final GeneratedColumn<String> valueEncrypted = GeneratedColumn<String>(
    'value_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueEncrypted, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_encrypted')) {
      context.handle(
        _valueEncryptedMeta,
        valueEncrypted.isAcceptableOrUnknown(
          data['value_encrypted']!,
          _valueEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valueEncryptedMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_encrypted'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String valueEncrypted;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.valueEncrypted,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_encrypted'] = Variable<String>(valueEncrypted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      valueEncrypted: Value(valueEncrypted),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      valueEncrypted: serializer.fromJson<String>(json['valueEncrypted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueEncrypted': serializer.toJson<String>(valueEncrypted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({
    String? key,
    String? valueEncrypted,
    DateTime? updatedAt,
  }) => AppSetting(
    key: key ?? this.key,
    valueEncrypted: valueEncrypted ?? this.valueEncrypted,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      valueEncrypted: data.valueEncrypted.present
          ? data.valueEncrypted.value
          : this.valueEncrypted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('valueEncrypted: $valueEncrypted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueEncrypted, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.valueEncrypted == this.valueEncrypted &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> valueEncrypted;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.valueEncrypted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String valueEncrypted,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueEncrypted = Value(valueEncrypted),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? valueEncrypted,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueEncrypted != null) 'value_encrypted': valueEncrypted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueEncrypted,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      valueEncrypted: valueEncrypted ?? this.valueEncrypted,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueEncrypted.present) {
      map['value_encrypted'] = Variable<String>(valueEncrypted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueEncrypted: $valueEncrypted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOperationsTable extends PendingOperations
    with TableInfo<$PendingOperationsTable, PendingOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadEncryptedMeta = const VerificationMeta(
    'payloadEncrypted',
  );
  @override
  late final GeneratedColumn<String> payloadEncrypted = GeneratedColumn<String>(
    'payload_encrypted',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationType,
    entityId,
    state,
    payloadEncrypted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('payload_encrypted')) {
      context.handle(
        _payloadEncryptedMeta,
        payloadEncrypted.isAcceptableOrUnknown(
          data['payload_encrypted']!,
          _payloadEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      payloadEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_encrypted'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PendingOperationsTable createAlias(String alias) {
    return $PendingOperationsTable(attachedDatabase, alias);
  }
}

class PendingOperation extends DataClass
    implements Insertable<PendingOperation> {
  final String id;
  final String operationType;
  final String entityId;
  final String state;
  final String? payloadEncrypted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PendingOperation({
    required this.id,
    required this.operationType,
    required this.entityId,
    required this.state,
    this.payloadEncrypted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation_type'] = Variable<String>(operationType);
    map['entity_id'] = Variable<String>(entityId);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || payloadEncrypted != null) {
      map['payload_encrypted'] = Variable<String>(payloadEncrypted);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PendingOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingOperationsCompanion(
      id: Value(id),
      operationType: Value(operationType),
      entityId: Value(entityId),
      state: Value(state),
      payloadEncrypted: payloadEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadEncrypted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PendingOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOperation(
      id: serializer.fromJson<String>(json['id']),
      operationType: serializer.fromJson<String>(json['operationType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      state: serializer.fromJson<String>(json['state']),
      payloadEncrypted: serializer.fromJson<String?>(json['payloadEncrypted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operationType': serializer.toJson<String>(operationType),
      'entityId': serializer.toJson<String>(entityId),
      'state': serializer.toJson<String>(state),
      'payloadEncrypted': serializer.toJson<String?>(payloadEncrypted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PendingOperation copyWith({
    String? id,
    String? operationType,
    String? entityId,
    String? state,
    Value<String?> payloadEncrypted = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PendingOperation(
    id: id ?? this.id,
    operationType: operationType ?? this.operationType,
    entityId: entityId ?? this.entityId,
    state: state ?? this.state,
    payloadEncrypted: payloadEncrypted.present
        ? payloadEncrypted.value
        : this.payloadEncrypted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PendingOperation copyWithCompanion(PendingOperationsCompanion data) {
    return PendingOperation(
      id: data.id.present ? data.id.value : this.id,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      state: data.state.present ? data.state.value : this.state,
      payloadEncrypted: data.payloadEncrypted.present
          ? data.payloadEncrypted.value
          : this.payloadEncrypted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperation(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('entityId: $entityId, ')
          ..write('state: $state, ')
          ..write('payloadEncrypted: $payloadEncrypted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationType,
    entityId,
    state,
    payloadEncrypted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOperation &&
          other.id == this.id &&
          other.operationType == this.operationType &&
          other.entityId == this.entityId &&
          other.state == this.state &&
          other.payloadEncrypted == this.payloadEncrypted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PendingOperationsCompanion extends UpdateCompanion<PendingOperation> {
  final Value<String> id;
  final Value<String> operationType;
  final Value<String> entityId;
  final Value<String> state;
  final Value<String?> payloadEncrypted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PendingOperationsCompanion({
    this.id = const Value.absent(),
    this.operationType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.state = const Value.absent(),
    this.payloadEncrypted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingOperationsCompanion.insert({
    required String id,
    required String operationType,
    required String entityId,
    required String state,
    this.payloadEncrypted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operationType = Value(operationType),
       entityId = Value(entityId),
       state = Value(state),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PendingOperation> custom({
    Expression<String>? id,
    Expression<String>? operationType,
    Expression<String>? entityId,
    Expression<String>? state,
    Expression<String>? payloadEncrypted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationType != null) 'operation_type': operationType,
      if (entityId != null) 'entity_id': entityId,
      if (state != null) 'state': state,
      if (payloadEncrypted != null) 'payload_encrypted': payloadEncrypted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingOperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? operationType,
    Value<String>? entityId,
    Value<String>? state,
    Value<String?>? payloadEncrypted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PendingOperationsCompanion(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      entityId: entityId ?? this.entityId,
      state: state ?? this.state,
      payloadEncrypted: payloadEncrypted ?? this.payloadEncrypted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (payloadEncrypted.present) {
      map['payload_encrypted'] = Variable<String>(payloadEncrypted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationsCompanion(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('entityId: $entityId, ')
          ..write('state: $state, ')
          ..write('payloadEncrypted: $payloadEncrypted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VaultDatabase extends GeneratedDatabase {
  _$VaultDatabase(QueryExecutor e) : super(e);
  $VaultDatabaseManager get managers => $VaultDatabaseManager(this);
  late final $VaultsTable vaults = $VaultsTable(this);
  late final $FamilyMembersTable familyMembers = $FamilyMembersTable(this);
  late final $DocumentCategoriesTable documentCategories =
      $DocumentCategoriesTable(this);
  late final $PhysicalLocationsTable physicalLocations =
      $PhysicalLocationsTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $DocumentVersionsTable documentVersions = $DocumentVersionsTable(
    this,
  );
  late final $DocumentOwnersTable documentOwners = $DocumentOwnersTable(this);
  late final $DocumentFilesTable documentFiles = $DocumentFilesTable(this);
  late final $DocumentPagesTable documentPages = $DocumentPagesTable(this);
  late final $DocumentFieldValuesTable documentFieldValues =
      $DocumentFieldValuesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $DocumentTagsTable documentTags = $DocumentTagsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $BackupRecordsTable backupRecords = $BackupRecordsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $PendingOperationsTable pendingOperations =
      $PendingOperationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vaults,
    familyMembers,
    documentCategories,
    physicalLocations,
    documents,
    documentVersions,
    documentOwners,
    documentFiles,
    documentPages,
    documentFieldValues,
    tags,
    documentTags,
    reminders,
    backupRecords,
    appSettings,
    pendingOperations,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_categories', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'family_members',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('documents', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'physical_locations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('documents', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_versions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_owners', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_pages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_files',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_pages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_field_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VaultsTableCreateCompanionBuilder = VaultsCompanion Function({
  required String id,
  required int schemaVersion,
  required int securityVersion,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$VaultsTableUpdateCompanionBuilder = VaultsCompanion Function({
  Value<String> id,
  Value<int> schemaVersion,
  Value<int> securityVersion,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$VaultsTableFilterComposer
    extends Composer<_$VaultDatabase, $VaultsTable> {
  $$VaultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get securityVersion => $composableBuilder(
    column: $table.securityVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaultsTableOrderingComposer
    extends Composer<_$VaultDatabase, $VaultsTable> {
  $$VaultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get securityVersion => $composableBuilder(
    column: $table.securityVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $VaultsTable> {
  $$VaultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get securityVersion => $composableBuilder(
    column: $table.securityVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VaultsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $VaultsTable,
          Vault,
          $$VaultsTableFilterComposer,
          $$VaultsTableOrderingComposer,
          $$VaultsTableAnnotationComposer,
          $$VaultsTableCreateCompanionBuilder,
          $$VaultsTableUpdateCompanionBuilder,
          (Vault, BaseReferences<_$VaultDatabase, $VaultsTable, Vault>),
          Vault,
          PrefetchHooks Function()
        > {
  $$VaultsTableTableManager(_$VaultDatabase db, $VaultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> securityVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultsCompanion(
                id: id,
                schemaVersion: schemaVersion,
                securityVersion: securityVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int schemaVersion,
                required int securityVersion,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VaultsCompanion.insert(
                id: id,
                schemaVersion: schemaVersion,
                securityVersion: securityVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VaultsTable, Vault>(table),
                  BaseReferences<_$VaultDatabase, $VaultsTable, Vault>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaultsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $VaultsTable,
      Vault,
      $$VaultsTableFilterComposer,
      $$VaultsTableOrderingComposer,
      $$VaultsTableAnnotationComposer,
      $$VaultsTableCreateCompanionBuilder,
      $$VaultsTableUpdateCompanionBuilder,
      (Vault, BaseReferences<_$VaultDatabase, $VaultsTable, Vault>),
      Vault,
      PrefetchHooks Function()
    >;
typedef $$FamilyMembersTableCreateCompanionBuilder =
    FamilyMembersCompanion Function({
      required String id,
      required String displayNameEncrypted,
      Value<String?> nicknameEncrypted,
      required String relationship,
      Value<DateTime?> dateOfBirth,
      Value<String?> bloodGroup,
      Value<String?> avatarFileId,
      Value<String?> notesEncrypted,
      Value<bool> isOwner,
      Value<bool> isArchived,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FamilyMembersTableUpdateCompanionBuilder =
    FamilyMembersCompanion Function({
      Value<String> id,
      Value<String> displayNameEncrypted,
      Value<String?> nicknameEncrypted,
      Value<String> relationship,
      Value<DateTime?> dateOfBirth,
      Value<String?> bloodGroup,
      Value<String?> avatarFileId,
      Value<String?> notesEncrypted,
      Value<bool> isOwner,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$FamilyMembersTableReferences
    extends BaseReferences<_$VaultDatabase, $FamilyMembersTable, FamilyMember> {
  $$FamilyMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$DocumentsTable, List<Document>>
  _documentsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documents,
    aliasName: 'family_members__id__documents__primary_owner_id',
  );

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.primaryOwnerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentOwnersTable, List<DocumentOwner>>
  _documentOwnersRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documentOwners,
    aliasName: 'family_members__id__document_owners__family_member_id',
  );

  $$DocumentOwnersTableProcessedTableManager get documentOwnersRefs {
    final manager = $$DocumentOwnersTableTableManager(
      $_db,
      $_db.documentOwners,
    ).filter((f) => f.familyMemberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentOwnersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FamilyMembersTableFilterComposer
    extends Composer<_$VaultDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayNameEncrypted => $composableBuilder(
    column: $table.displayNameEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nicknameEncrypted => $composableBuilder(
    column: $table.nicknameEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarFileId => $composableBuilder(
    column: $table.avatarFileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notesEncrypted => $composableBuilder(
    column: $table.notesEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOwner => $composableBuilder(
    column: $table.isOwner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> documentsRefs(
    Expression<bool> Function($$DocumentsTableFilterComposer f) f,
  ) {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.primaryOwnerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentOwnersRefs(
    Expression<bool> Function($$DocumentOwnersTableFilterComposer f) f,
  ) {
    final $$DocumentOwnersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentOwners,
      getReferencedColumn: (t) => t.familyMemberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentOwnersTableFilterComposer(
            $db: $db,
            $table: $db.documentOwners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FamilyMembersTableOrderingComposer
    extends Composer<_$VaultDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayNameEncrypted => $composableBuilder(
    column: $table.displayNameEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nicknameEncrypted => $composableBuilder(
    column: $table.nicknameEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarFileId => $composableBuilder(
    column: $table.avatarFileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notesEncrypted => $composableBuilder(
    column: $table.notesEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOwner => $composableBuilder(
    column: $table.isOwner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyMembersTableAnnotationComposer
    extends Composer<_$VaultDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayNameEncrypted => $composableBuilder(
    column: $table.displayNameEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nicknameEncrypted => $composableBuilder(
    column: $table.nicknameEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarFileId => $composableBuilder(
    column: $table.avatarFileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notesEncrypted => $composableBuilder(
    column: $table.notesEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOwner =>
      $composableBuilder(column: $table.isOwner, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> documentsRefs<T extends Object>(
    Expression<T> Function($$DocumentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.primaryOwnerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentOwnersRefs<T extends Object>(
    Expression<T> Function($$DocumentOwnersTableAnnotationComposer a) f,
  ) {
    final $$DocumentOwnersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentOwners,
      getReferencedColumn: (t) => t.familyMemberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentOwnersTableAnnotationComposer(
            $db: $db,
            $table: $db.documentOwners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FamilyMembersTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $FamilyMembersTable,
          FamilyMember,
          $$FamilyMembersTableFilterComposer,
          $$FamilyMembersTableOrderingComposer,
          $$FamilyMembersTableAnnotationComposer,
          $$FamilyMembersTableCreateCompanionBuilder,
          $$FamilyMembersTableUpdateCompanionBuilder,
          (FamilyMember, $$FamilyMembersTableReferences),
          FamilyMember,
          PrefetchHooks Function({bool documentsRefs, bool documentOwnersRefs})
        > {
  $$FamilyMembersTableTableManager(
    _$VaultDatabase db,
    $FamilyMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayNameEncrypted = const Value.absent(),
                Value<String?> nicknameEncrypted = const Value.absent(),
                Value<String> relationship = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> bloodGroup = const Value.absent(),
                Value<String?> avatarFileId = const Value.absent(),
                Value<String?> notesEncrypted = const Value.absent(),
                Value<bool> isOwner = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyMembersCompanion(
                id: id,
                displayNameEncrypted: displayNameEncrypted,
                nicknameEncrypted: nicknameEncrypted,
                relationship: relationship,
                dateOfBirth: dateOfBirth,
                bloodGroup: bloodGroup,
                avatarFileId: avatarFileId,
                notesEncrypted: notesEncrypted,
                isOwner: isOwner,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayNameEncrypted,
                Value<String?> nicknameEncrypted = const Value.absent(),
                required String relationship,
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> bloodGroup = const Value.absent(),
                Value<String?> avatarFileId = const Value.absent(),
                Value<String?> notesEncrypted = const Value.absent(),
                Value<bool> isOwner = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FamilyMembersCompanion.insert(
                id: id,
                displayNameEncrypted: displayNameEncrypted,
                nicknameEncrypted: nicknameEncrypted,
                relationship: relationship,
                dateOfBirth: dateOfBirth,
                bloodGroup: bloodGroup,
                avatarFileId: avatarFileId,
                notesEncrypted: notesEncrypted,
                isOwner: isOwner,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FamilyMembersTable, FamilyMember>(table),
                  $$FamilyMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({documentsRefs = false, documentOwnersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (documentsRefs) db.documents,
                    if (documentOwnersRefs) db.documentOwners,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (documentsRefs)
                        await $_getPrefetchedData<
                          FamilyMember,
                          $FamilyMembersTable,
                          Document
                        >(
                          currentTable: table,
                          referencedTable: $$FamilyMembersTableReferences
                              ._documentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamilyMembersTableReferences(
                                db,
                                table,
                                p0,
                              ).documentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.primaryOwnerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentOwnersRefs)
                        await $_getPrefetchedData<
                          FamilyMember,
                          $FamilyMembersTable,
                          DocumentOwner
                        >(
                          currentTable: table,
                          referencedTable: $$FamilyMembersTableReferences
                              ._documentOwnersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamilyMembersTableReferences(
                                db,
                                table,
                                p0,
                              ).documentOwnersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyMemberId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FamilyMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $FamilyMembersTable,
      FamilyMember,
      $$FamilyMembersTableFilterComposer,
      $$FamilyMembersTableOrderingComposer,
      $$FamilyMembersTableAnnotationComposer,
      $$FamilyMembersTableCreateCompanionBuilder,
      $$FamilyMembersTableUpdateCompanionBuilder,
      (FamilyMember, $$FamilyMembersTableReferences),
      FamilyMember,
      PrefetchHooks Function({bool documentsRefs, bool documentOwnersRefs})
    >;
typedef $$DocumentCategoriesTableCreateCompanionBuilder =
    DocumentCategoriesCompanion Function({
      required String id,
      required String code,
      Value<String?> parentId,
      Value<String?> nameKey,
      Value<String?> customNameEncrypted,
      Value<bool> isSystem,
      Value<int> sortOrder,
      Value<String> iconKey,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DocumentCategoriesTableUpdateCompanionBuilder =
    DocumentCategoriesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String?> parentId,
      Value<String?> nameKey,
      Value<String?> customNameEncrypted,
      Value<bool> isSystem,
      Value<int> sortOrder,
      Value<String> iconKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DocumentCategoriesTableReferences
    extends
        BaseReferences<
          _$VaultDatabase,
          $DocumentCategoriesTable,
          DocumentCategory
        > {
  $$DocumentCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentCategoriesTable _parentIdTable(_$VaultDatabase db) => db
      .documentCategories
      .createAlias('document_categories__parent_id__document_categories__id');

  $$DocumentCategoriesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$DocumentCategoriesTableTableManager(
      $_db,
      $_db.documentCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DocumentsTable, List<Document>>
  _documentsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documents,
    aliasName: 'document_categories__id__documents__category_id',
  );

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentCategoriesTableFilterComposer
    extends Composer<_$VaultDatabase, $DocumentCategoriesTable> {
  $$DocumentCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customNameEncrypted => $composableBuilder(
    column: $table.customNameEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentCategoriesTableFilterComposer get parentId {
    final $$DocumentCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.documentCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.documentCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> documentsRefs(
    Expression<bool> Function($$DocumentsTableFilterComposer f) f,
  ) {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentCategoriesTableOrderingComposer
    extends Composer<_$VaultDatabase, $DocumentCategoriesTable> {
  $$DocumentCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customNameEncrypted => $composableBuilder(
    column: $table.customNameEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentCategoriesTableOrderingComposer get parentId {
    final $$DocumentCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.documentCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.documentCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentCategoriesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $DocumentCategoriesTable> {
  $$DocumentCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get customNameEncrypted => $composableBuilder(
    column: $table.customNameEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DocumentCategoriesTableAnnotationComposer get parentId {
    final $$DocumentCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.parentId,
          referencedTable: $db.documentCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.documentCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> documentsRefs<T extends Object>(
    Expression<T> Function($$DocumentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentCategoriesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $DocumentCategoriesTable,
          DocumentCategory,
          $$DocumentCategoriesTableFilterComposer,
          $$DocumentCategoriesTableOrderingComposer,
          $$DocumentCategoriesTableAnnotationComposer,
          $$DocumentCategoriesTableCreateCompanionBuilder,
          $$DocumentCategoriesTableUpdateCompanionBuilder,
          (DocumentCategory, $$DocumentCategoriesTableReferences),
          DocumentCategory,
          PrefetchHooks Function({bool parentId, bool documentsRefs})
        > {
  $$DocumentCategoriesTableTableManager(
    _$VaultDatabase db,
    $DocumentCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> nameKey = const Value.absent(),
                Value<String?> customNameEncrypted = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentCategoriesCompanion(
                id: id,
                code: code,
                parentId: parentId,
                nameKey: nameKey,
                customNameEncrypted: customNameEncrypted,
                isSystem: isSystem,
                sortOrder: sortOrder,
                iconKey: iconKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                Value<String?> parentId = const Value.absent(),
                Value<String?> nameKey = const Value.absent(),
                Value<String?> customNameEncrypted = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DocumentCategoriesCompanion.insert(
                id: id,
                code: code,
                parentId: parentId,
                nameKey: nameKey,
                customNameEncrypted: customNameEncrypted,
                isSystem: isSystem,
                sortOrder: sortOrder,
                iconKey: iconKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentCategoriesTable, DocumentCategory>(
                    table,
                  ),
                  $$DocumentCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false, documentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (documentsRefs) db.documents],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (parentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.parentId,
                        referencedTable: $$DocumentCategoriesTableReferences
                            ._parentIdTable(db),
                        referencedColumn: $$DocumentCategoriesTableReferences
                            ._parentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (documentsRefs)
                    await $_getPrefetchedData<
                      DocumentCategory,
                      $DocumentCategoriesTable,
                      Document
                    >(
                      currentTable: table,
                      referencedTable: $$DocumentCategoriesTableReferences
                          ._documentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DocumentCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).documentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DocumentCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $DocumentCategoriesTable,
      DocumentCategory,
      $$DocumentCategoriesTableFilterComposer,
      $$DocumentCategoriesTableOrderingComposer,
      $$DocumentCategoriesTableAnnotationComposer,
      $$DocumentCategoriesTableCreateCompanionBuilder,
      $$DocumentCategoriesTableUpdateCompanionBuilder,
      (DocumentCategory, $$DocumentCategoriesTableReferences),
      DocumentCategory,
      PrefetchHooks Function({bool parentId, bool documentsRefs})
    >;
typedef $$PhysicalLocationsTableCreateCompanionBuilder =
    PhysicalLocationsCompanion Function({
      required String id,
      required String nameEncrypted,
      Value<String?> descriptionEncrypted,
      Value<bool> isArchived,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PhysicalLocationsTableUpdateCompanionBuilder =
    PhysicalLocationsCompanion Function({
      Value<String> id,
      Value<String> nameEncrypted,
      Value<String?> descriptionEncrypted,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PhysicalLocationsTableReferences
    extends
        BaseReferences<
          _$VaultDatabase,
          $PhysicalLocationsTable,
          PhysicalLocation
        > {
  $$PhysicalLocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$DocumentsTable, List<Document>>
  _documentsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documents,
    aliasName: 'physical_locations__id__documents__physical_location_id',
  );

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager($_db, $_db.documents).filter(
      (f) => f.physicalLocationId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PhysicalLocationsTableFilterComposer
    extends Composer<_$VaultDatabase, $PhysicalLocationsTable> {
  $$PhysicalLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEncrypted => $composableBuilder(
    column: $table.nameEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEncrypted => $composableBuilder(
    column: $table.descriptionEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> documentsRefs(
    Expression<bool> Function($$DocumentsTableFilterComposer f) f,
  ) {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.physicalLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhysicalLocationsTableOrderingComposer
    extends Composer<_$VaultDatabase, $PhysicalLocationsTable> {
  $$PhysicalLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEncrypted => $composableBuilder(
    column: $table.nameEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEncrypted => $composableBuilder(
    column: $table.descriptionEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhysicalLocationsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $PhysicalLocationsTable> {
  $$PhysicalLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameEncrypted => $composableBuilder(
    column: $table.nameEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEncrypted => $composableBuilder(
    column: $table.descriptionEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> documentsRefs<T extends Object>(
    Expression<T> Function($$DocumentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.physicalLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhysicalLocationsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $PhysicalLocationsTable,
          PhysicalLocation,
          $$PhysicalLocationsTableFilterComposer,
          $$PhysicalLocationsTableOrderingComposer,
          $$PhysicalLocationsTableAnnotationComposer,
          $$PhysicalLocationsTableCreateCompanionBuilder,
          $$PhysicalLocationsTableUpdateCompanionBuilder,
          (PhysicalLocation, $$PhysicalLocationsTableReferences),
          PhysicalLocation,
          PrefetchHooks Function({bool documentsRefs})
        > {
  $$PhysicalLocationsTableTableManager(
    _$VaultDatabase db,
    $PhysicalLocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhysicalLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhysicalLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhysicalLocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nameEncrypted = const Value.absent(),
                Value<String?> descriptionEncrypted = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhysicalLocationsCompanion(
                id: id,
                nameEncrypted: nameEncrypted,
                descriptionEncrypted: descriptionEncrypted,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameEncrypted,
                Value<String?> descriptionEncrypted = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PhysicalLocationsCompanion.insert(
                id: id,
                nameEncrypted: nameEncrypted,
                descriptionEncrypted: descriptionEncrypted,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhysicalLocationsTable, PhysicalLocation>(table),
                  $$PhysicalLocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (documentsRefs) db.documents],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (documentsRefs)
                    await $_getPrefetchedData<
                      PhysicalLocation,
                      $PhysicalLocationsTable,
                      Document
                    >(
                      currentTable: table,
                      referencedTable: $$PhysicalLocationsTableReferences
                          ._documentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PhysicalLocationsTableReferences(
                            db,
                            table,
                            p0,
                          ).documentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.physicalLocationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PhysicalLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $PhysicalLocationsTable,
      PhysicalLocation,
      $$PhysicalLocationsTableFilterComposer,
      $$PhysicalLocationsTableOrderingComposer,
      $$PhysicalLocationsTableAnnotationComposer,
      $$PhysicalLocationsTableCreateCompanionBuilder,
      $$PhysicalLocationsTableUpdateCompanionBuilder,
      (PhysicalLocation, $$PhysicalLocationsTableReferences),
      PhysicalLocation,
      PrefetchHooks Function({bool documentsRefs})
    >;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  required String titleEncrypted,
  required String categoryId,
  Value<String?> primaryOwnerId,
  Value<String> ownershipType,
  Value<String?> documentNumberEncrypted,
  Value<DateTime?> issueDate,
  Value<DateTime?> expiryDate,
  Value<String?> issuingAuthorityEncrypted,
  Value<String?> descriptionEncrypted,
  Value<String?> notesEncrypted,
  Value<String?> physicalLocationId,
  Value<String> status,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<String?> currentVersionId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<String> titleEncrypted,
  Value<String> categoryId,
  Value<String?> primaryOwnerId,
  Value<String> ownershipType,
  Value<String?> documentNumberEncrypted,
  Value<DateTime?> issueDate,
  Value<DateTime?> expiryDate,
  Value<String?> issuingAuthorityEncrypted,
  Value<String?> descriptionEncrypted,
  Value<String?> notesEncrypted,
  Value<String?> physicalLocationId,
  Value<String> status,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<String?> currentVersionId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$DocumentsTableReferences
    extends BaseReferences<_$VaultDatabase, $DocumentsTable, Document> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentCategoriesTable _categoryIdTable(_$VaultDatabase db) => db
      .documentCategories
      .createAlias('documents__category_id__document_categories__id');

  $$DocumentCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$DocumentCategoriesTableTableManager(
      $_db,
      $_db.documentCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FamilyMembersTable _primaryOwnerIdTable(_$VaultDatabase db) => db
      .familyMembers
      .createAlias('documents__primary_owner_id__family_members__id');

  $$FamilyMembersTableProcessedTableManager? get primaryOwnerId {
    final $_column = $_itemColumn<String>('primary_owner_id');
    if ($_column == null) return null;
    final manager = $$FamilyMembersTableTableManager(
      $_db,
      $_db.familyMembers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_primaryOwnerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PhysicalLocationsTable _physicalLocationIdTable(_$VaultDatabase db) =>
      db.physicalLocations.createAlias(
        'documents__physical_location_id__physical_locations__id',
      );

  $$PhysicalLocationsTableProcessedTableManager? get physicalLocationId {
    final $_column = $_itemColumn<String>('physical_location_id');
    if ($_column == null) return null;
    final manager = $$PhysicalLocationsTableTableManager(
      $_db,
      $_db.physicalLocations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_physicalLocationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DocumentVersionsTable, List<DocumentVersion>>
  _documentVersionsRefsTable(_$VaultDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.documentVersions,
        aliasName: 'documents__id__document_versions__document_id',
      );

  $$DocumentVersionsTableProcessedTableManager get documentVersionsRefs {
    final manager = $$DocumentVersionsTableTableManager(
      $_db,
      $_db.documentVersions,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _documentVersionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentOwnersTable, List<DocumentOwner>>
  _documentOwnersRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documentOwners,
    aliasName: 'documents__id__document_owners__document_id',
  );

  $$DocumentOwnersTableProcessedTableManager get documentOwnersRefs {
    final manager = $$DocumentOwnersTableTableManager(
      $_db,
      $_db.documentOwners,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentOwnersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentFilesTable, List<DocumentFile>>
  _documentFilesRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documentFiles,
    aliasName: 'documents__id__document_files__document_id',
  );

  $$DocumentFilesTableProcessedTableManager get documentFilesRefs {
    final manager = $$DocumentFilesTableTableManager(
      $_db,
      $_db.documentFiles,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentFilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentPagesTable, List<DocumentPage>>
  _documentPagesRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documentPages,
    aliasName: 'documents__id__document_pages__document_id',
  );

  $$DocumentPagesTableProcessedTableManager get documentPagesRefs {
    final manager = $$DocumentPagesTableTableManager(
      $_db,
      $_db.documentPages,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentPagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DocumentFieldValuesTable,
    List<DocumentFieldValue>
  >
  _documentFieldValuesRefsTable(_$VaultDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.documentFieldValues,
        aliasName: 'documents__id__document_field_values__document_id',
      );

  $$DocumentFieldValuesTableProcessedTableManager get documentFieldValuesRefs {
    final manager = $$DocumentFieldValuesTableTableManager(
      $_db,
      $_db.documentFieldValues,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _documentFieldValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentTagsTable, List<DocumentTag>>
  _documentTagsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documentTags,
    aliasName: 'documents__id__document_tags__document_id',
  );

  $$DocumentTagsTableProcessedTableManager get documentTagsRefs {
    final manager = $$DocumentTagsTableTableManager(
      $_db,
      $_db.documentTags,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'documents__id__reminders__document_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentsTableFilterComposer
    extends Composer<_$VaultDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleEncrypted => $composableBuilder(
    column: $table.titleEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownershipType => $composableBuilder(
    column: $table.ownershipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentNumberEncrypted => $composableBuilder(
    column: $table.documentNumberEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuingAuthorityEncrypted => $composableBuilder(
    column: $table.issuingAuthorityEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEncrypted => $composableBuilder(
    column: $table.descriptionEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notesEncrypted => $composableBuilder(
    column: $table.notesEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentVersionId => $composableBuilder(
    column: $table.currentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentCategoriesTableFilterComposer get categoryId {
    final $$DocumentCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.documentCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.documentCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamilyMembersTableFilterComposer get primaryOwnerId {
    final $$FamilyMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primaryOwnerId,
      referencedTable: $db.familyMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamilyMembersTableFilterComposer(
            $db: $db,
            $table: $db.familyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhysicalLocationsTableFilterComposer get physicalLocationId {
    final $$PhysicalLocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.physicalLocationId,
      referencedTable: $db.physicalLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhysicalLocationsTableFilterComposer(
            $db: $db,
            $table: $db.physicalLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> documentVersionsRefs(
    Expression<bool> Function($$DocumentVersionsTableFilterComposer f) f,
  ) {
    final $$DocumentVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentVersions,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentVersionsTableFilterComposer(
            $db: $db,
            $table: $db.documentVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentOwnersRefs(
    Expression<bool> Function($$DocumentOwnersTableFilterComposer f) f,
  ) {
    final $$DocumentOwnersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentOwners,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentOwnersTableFilterComposer(
            $db: $db,
            $table: $db.documentOwners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentFilesRefs(
    Expression<bool> Function($$DocumentFilesTableFilterComposer f) f,
  ) {
    final $$DocumentFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentFiles,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentFilesTableFilterComposer(
            $db: $db,
            $table: $db.documentFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentPagesRefs(
    Expression<bool> Function($$DocumentPagesTableFilterComposer f) f,
  ) {
    final $$DocumentPagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentPages,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentPagesTableFilterComposer(
            $db: $db,
            $table: $db.documentPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentFieldValuesRefs(
    Expression<bool> Function($$DocumentFieldValuesTableFilterComposer f) f,
  ) {
    final $$DocumentFieldValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentFieldValues,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentFieldValuesTableFilterComposer(
            $db: $db,
            $table: $db.documentFieldValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentTagsRefs(
    Expression<bool> Function($$DocumentTagsTableFilterComposer f) f,
  ) {
    final $$DocumentTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentTags,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTagsTableFilterComposer(
            $db: $db,
            $table: $db.documentTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$VaultDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleEncrypted => $composableBuilder(
    column: $table.titleEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownershipType => $composableBuilder(
    column: $table.ownershipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentNumberEncrypted => $composableBuilder(
    column: $table.documentNumberEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuingAuthorityEncrypted => $composableBuilder(
    column: $table.issuingAuthorityEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEncrypted => $composableBuilder(
    column: $table.descriptionEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notesEncrypted => $composableBuilder(
    column: $table.notesEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentVersionId => $composableBuilder(
    column: $table.currentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentCategoriesTableOrderingComposer get categoryId {
    final $$DocumentCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.documentCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.documentCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamilyMembersTableOrderingComposer get primaryOwnerId {
    final $$FamilyMembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primaryOwnerId,
      referencedTable: $db.familyMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamilyMembersTableOrderingComposer(
            $db: $db,
            $table: $db.familyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhysicalLocationsTableOrderingComposer get physicalLocationId {
    final $$PhysicalLocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.physicalLocationId,
      referencedTable: $db.physicalLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhysicalLocationsTableOrderingComposer(
            $db: $db,
            $table: $db.physicalLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titleEncrypted => $composableBuilder(
    column: $table.titleEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownershipType => $composableBuilder(
    column: $table.ownershipType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentNumberEncrypted => $composableBuilder(
    column: $table.documentNumberEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issuingAuthorityEncrypted => $composableBuilder(
    column: $table.issuingAuthorityEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEncrypted => $composableBuilder(
    column: $table.descriptionEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notesEncrypted => $composableBuilder(
    column: $table.notesEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentVersionId => $composableBuilder(
    column: $table.currentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DocumentCategoriesTableAnnotationComposer get categoryId {
    final $$DocumentCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.documentCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.documentCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$FamilyMembersTableAnnotationComposer get primaryOwnerId {
    final $$FamilyMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primaryOwnerId,
      referencedTable: $db.familyMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamilyMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.familyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhysicalLocationsTableAnnotationComposer get physicalLocationId {
    final $$PhysicalLocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.physicalLocationId,
          referencedTable: $db.physicalLocations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PhysicalLocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.physicalLocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> documentVersionsRefs<T extends Object>(
    Expression<T> Function($$DocumentVersionsTableAnnotationComposer a) f,
  ) {
    final $$DocumentVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentVersions,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.documentVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentOwnersRefs<T extends Object>(
    Expression<T> Function($$DocumentOwnersTableAnnotationComposer a) f,
  ) {
    final $$DocumentOwnersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentOwners,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentOwnersTableAnnotationComposer(
            $db: $db,
            $table: $db.documentOwners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentFilesRefs<T extends Object>(
    Expression<T> Function($$DocumentFilesTableAnnotationComposer a) f,
  ) {
    final $$DocumentFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentFiles,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.documentFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentPagesRefs<T extends Object>(
    Expression<T> Function($$DocumentPagesTableAnnotationComposer a) f,
  ) {
    final $$DocumentPagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentPages,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentPagesTableAnnotationComposer(
            $db: $db,
            $table: $db.documentPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentFieldValuesRefs<T extends Object>(
    Expression<T> Function($$DocumentFieldValuesTableAnnotationComposer a) f,
  ) {
    final $$DocumentFieldValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.documentFieldValues,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentFieldValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.documentFieldValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> documentTagsRefs<T extends Object>(
    Expression<T> Function($$DocumentTagsTableAnnotationComposer a) f,
  ) {
    final $$DocumentTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentTags,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.documentTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $DocumentsTable,
          Document,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (Document, $$DocumentsTableReferences),
          Document,
          PrefetchHooks Function({
            bool categoryId,
            bool primaryOwnerId,
            bool physicalLocationId,
            bool documentVersionsRefs,
            bool documentOwnersRefs,
            bool documentFilesRefs,
            bool documentPagesRefs,
            bool documentFieldValuesRefs,
            bool documentTagsRefs,
            bool remindersRefs,
          })
        > {
  $$DocumentsTableTableManager(_$VaultDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> titleEncrypted = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> primaryOwnerId = const Value.absent(),
                Value<String> ownershipType = const Value.absent(),
                Value<String?> documentNumberEncrypted = const Value.absent(),
                Value<DateTime?> issueDate = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<String?> issuingAuthorityEncrypted = const Value.absent(),
                Value<String?> descriptionEncrypted = const Value.absent(),
                Value<String?> notesEncrypted = const Value.absent(),
                Value<String?> physicalLocationId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> currentVersionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                titleEncrypted: titleEncrypted,
                categoryId: categoryId,
                primaryOwnerId: primaryOwnerId,
                ownershipType: ownershipType,
                documentNumberEncrypted: documentNumberEncrypted,
                issueDate: issueDate,
                expiryDate: expiryDate,
                issuingAuthorityEncrypted: issuingAuthorityEncrypted,
                descriptionEncrypted: descriptionEncrypted,
                notesEncrypted: notesEncrypted,
                physicalLocationId: physicalLocationId,
                status: status,
                isFavorite: isFavorite,
                isArchived: isArchived,
                currentVersionId: currentVersionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String titleEncrypted,
                required String categoryId,
                Value<String?> primaryOwnerId = const Value.absent(),
                Value<String> ownershipType = const Value.absent(),
                Value<String?> documentNumberEncrypted = const Value.absent(),
                Value<DateTime?> issueDate = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<String?> issuingAuthorityEncrypted = const Value.absent(),
                Value<String?> descriptionEncrypted = const Value.absent(),
                Value<String?> notesEncrypted = const Value.absent(),
                Value<String?> physicalLocationId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> currentVersionId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                titleEncrypted: titleEncrypted,
                categoryId: categoryId,
                primaryOwnerId: primaryOwnerId,
                ownershipType: ownershipType,
                documentNumberEncrypted: documentNumberEncrypted,
                issueDate: issueDate,
                expiryDate: expiryDate,
                issuingAuthorityEncrypted: issuingAuthorityEncrypted,
                descriptionEncrypted: descriptionEncrypted,
                notesEncrypted: notesEncrypted,
                physicalLocationId: physicalLocationId,
                status: status,
                isFavorite: isFavorite,
                isArchived: isArchived,
                currentVersionId: currentVersionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentsTable, Document>(table),
                  $$DocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                primaryOwnerId = false,
                physicalLocationId = false,
                documentVersionsRefs = false,
                documentOwnersRefs = false,
                documentFilesRefs = false,
                documentPagesRefs = false,
                documentFieldValuesRefs = false,
                documentTagsRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (documentVersionsRefs) db.documentVersions,
                    if (documentOwnersRefs) db.documentOwners,
                    if (documentFilesRefs) db.documentFiles,
                    if (documentPagesRefs) db.documentPages,
                    if (documentFieldValuesRefs) db.documentFieldValues,
                    if (documentTagsRefs) db.documentTags,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$DocumentsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$DocumentsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (primaryOwnerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.primaryOwnerId,
                            referencedTable: $$DocumentsTableReferences
                                ._primaryOwnerIdTable(db),
                            referencedColumn: $$DocumentsTableReferences
                                ._primaryOwnerIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (physicalLocationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.physicalLocationId,
                            referencedTable: $$DocumentsTableReferences
                                ._physicalLocationIdTable(db),
                            referencedColumn: $$DocumentsTableReferences
                                ._physicalLocationIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (documentVersionsRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          DocumentVersion
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._documentVersionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentVersionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentOwnersRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          DocumentOwner
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._documentOwnersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentOwnersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentFilesRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          DocumentFile
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._documentFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentPagesRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          DocumentPage
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._documentPagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentPagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentFieldValuesRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          DocumentFieldValue
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._documentFieldValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentFieldValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentTagsRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          DocumentTag
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._documentTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          Reminder
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $DocumentsTable,
      Document,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (Document, $$DocumentsTableReferences),
      Document,
      PrefetchHooks Function({
        bool categoryId,
        bool primaryOwnerId,
        bool physicalLocationId,
        bool documentVersionsRefs,
        bool documentOwnersRefs,
        bool documentFilesRefs,
        bool documentPagesRefs,
        bool documentFieldValuesRefs,
        bool documentTagsRefs,
        bool remindersRefs,
      })
    >;
typedef $$DocumentVersionsTableCreateCompanionBuilder =
    DocumentVersionsCompanion Function({
      required String id,
      required String documentId,
      Value<String?> previousVersionId,
      Value<bool> isCurrent,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DocumentVersionsTableUpdateCompanionBuilder =
    DocumentVersionsCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String?> previousVersionId,
      Value<bool> isCurrent,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DocumentVersionsTableReferences
    extends
        BaseReferences<
          _$VaultDatabase,
          $DocumentVersionsTable,
          DocumentVersion
        > {
  $$DocumentVersionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentsTable _documentIdTable(_$VaultDatabase db) =>
      db.documents.createAlias('document_versions__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentVersionsTableFilterComposer
    extends Composer<_$VaultDatabase, $DocumentVersionsTable> {
  $$DocumentVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentVersionsTableOrderingComposer
    extends Composer<_$VaultDatabase, $DocumentVersionsTable> {
  $$DocumentVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentVersionsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $DocumentVersionsTable> {
  $$DocumentVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentVersionsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $DocumentVersionsTable,
          DocumentVersion,
          $$DocumentVersionsTableFilterComposer,
          $$DocumentVersionsTableOrderingComposer,
          $$DocumentVersionsTableAnnotationComposer,
          $$DocumentVersionsTableCreateCompanionBuilder,
          $$DocumentVersionsTableUpdateCompanionBuilder,
          (DocumentVersion, $$DocumentVersionsTableReferences),
          DocumentVersion,
          PrefetchHooks Function({bool documentId})
        > {
  $$DocumentVersionsTableTableManager(
    _$VaultDatabase db,
    $DocumentVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String?> previousVersionId = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentVersionsCompanion(
                id: id,
                documentId: documentId,
                previousVersionId: previousVersionId,
                isCurrent: isCurrent,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                Value<String?> previousVersionId = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DocumentVersionsCompanion.insert(
                id: id,
                documentId: documentId,
                previousVersionId: previousVersionId,
                isCurrent: isCurrent,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentVersionsTable, DocumentVersion>(table),
                  $$DocumentVersionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentId,
                        referencedTable: $$DocumentVersionsTableReferences
                            ._documentIdTable(db),
                        referencedColumn: $$DocumentVersionsTableReferences
                            ._documentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $DocumentVersionsTable,
      DocumentVersion,
      $$DocumentVersionsTableFilterComposer,
      $$DocumentVersionsTableOrderingComposer,
      $$DocumentVersionsTableAnnotationComposer,
      $$DocumentVersionsTableCreateCompanionBuilder,
      $$DocumentVersionsTableUpdateCompanionBuilder,
      (DocumentVersion, $$DocumentVersionsTableReferences),
      DocumentVersion,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$DocumentOwnersTableCreateCompanionBuilder =
    DocumentOwnersCompanion Function({
      required String documentId,
      required String familyMemberId,
      Value<String> role,
      Value<int> rowid,
    });
typedef $$DocumentOwnersTableUpdateCompanionBuilder =
    DocumentOwnersCompanion Function({
      Value<String> documentId,
      Value<String> familyMemberId,
      Value<String> role,
      Value<int> rowid,
    });

final class $$DocumentOwnersTableReferences
    extends
        BaseReferences<_$VaultDatabase, $DocumentOwnersTable, DocumentOwner> {
  $$DocumentOwnersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentsTable _documentIdTable(_$VaultDatabase db) =>
      db.documents.createAlias('document_owners__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FamilyMembersTable _familyMemberIdTable(_$VaultDatabase db) => db
      .familyMembers
      .createAlias('document_owners__family_member_id__family_members__id');

  $$FamilyMembersTableProcessedTableManager get familyMemberId {
    final $_column = $_itemColumn<String>('family_member_id')!;

    final manager = $$FamilyMembersTableTableManager(
      $_db,
      $_db.familyMembers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyMemberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentOwnersTableFilterComposer
    extends Composer<_$VaultDatabase, $DocumentOwnersTable> {
  $$DocumentOwnersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamilyMembersTableFilterComposer get familyMemberId {
    final $$FamilyMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyMemberId,
      referencedTable: $db.familyMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamilyMembersTableFilterComposer(
            $db: $db,
            $table: $db.familyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentOwnersTableOrderingComposer
    extends Composer<_$VaultDatabase, $DocumentOwnersTable> {
  $$DocumentOwnersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamilyMembersTableOrderingComposer get familyMemberId {
    final $$FamilyMembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyMemberId,
      referencedTable: $db.familyMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamilyMembersTableOrderingComposer(
            $db: $db,
            $table: $db.familyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentOwnersTableAnnotationComposer
    extends Composer<_$VaultDatabase, $DocumentOwnersTable> {
  $$DocumentOwnersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamilyMembersTableAnnotationComposer get familyMemberId {
    final $$FamilyMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyMemberId,
      referencedTable: $db.familyMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamilyMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.familyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentOwnersTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $DocumentOwnersTable,
          DocumentOwner,
          $$DocumentOwnersTableFilterComposer,
          $$DocumentOwnersTableOrderingComposer,
          $$DocumentOwnersTableAnnotationComposer,
          $$DocumentOwnersTableCreateCompanionBuilder,
          $$DocumentOwnersTableUpdateCompanionBuilder,
          (DocumentOwner, $$DocumentOwnersTableReferences),
          DocumentOwner,
          PrefetchHooks Function({bool documentId, bool familyMemberId})
        > {
  $$DocumentOwnersTableTableManager(
    _$VaultDatabase db,
    $DocumentOwnersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentOwnersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentOwnersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentOwnersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> documentId = const Value.absent(),
                Value<String> familyMemberId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentOwnersCompanion(
                documentId: documentId,
                familyMemberId: familyMemberId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String documentId,
                required String familyMemberId,
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentOwnersCompanion.insert(
                documentId: documentId,
                familyMemberId: familyMemberId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentOwnersTable, DocumentOwner>(table),
                  $$DocumentOwnersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({documentId = false, familyMemberId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (documentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.documentId,
                            referencedTable: $$DocumentOwnersTableReferences
                                ._documentIdTable(db),
                            referencedColumn: $$DocumentOwnersTableReferences
                                ._documentIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (familyMemberId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.familyMemberId,
                            referencedTable: $$DocumentOwnersTableReferences
                                ._familyMemberIdTable(db),
                            referencedColumn: $$DocumentOwnersTableReferences
                                ._familyMemberIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentOwnersTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $DocumentOwnersTable,
      DocumentOwner,
      $$DocumentOwnersTableFilterComposer,
      $$DocumentOwnersTableOrderingComposer,
      $$DocumentOwnersTableAnnotationComposer,
      $$DocumentOwnersTableCreateCompanionBuilder,
      $$DocumentOwnersTableUpdateCompanionBuilder,
      (DocumentOwner, $$DocumentOwnersTableReferences),
      DocumentOwner,
      PrefetchHooks Function({bool documentId, bool familyMemberId})
    >;
typedef $$DocumentFilesTableCreateCompanionBuilder =
    DocumentFilesCompanion Function({
      required String id,
      required String documentId,
      Value<String> fileType,
      required String mimeType,
      required String encryptedRelativePath,
      Value<String?> originalFilenameEncrypted,
      required int sizeBytes,
      required String integrityHash,
      required int encryptionVersion,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DocumentFilesTableUpdateCompanionBuilder =
    DocumentFilesCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String> fileType,
      Value<String> mimeType,
      Value<String> encryptedRelativePath,
      Value<String?> originalFilenameEncrypted,
      Value<int> sizeBytes,
      Value<String> integrityHash,
      Value<int> encryptionVersion,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DocumentFilesTableReferences
    extends BaseReferences<_$VaultDatabase, $DocumentFilesTable, DocumentFile> {
  $$DocumentFilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentsTable _documentIdTable(_$VaultDatabase db) =>
      db.documents.createAlias('document_files__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DocumentPagesTable, List<DocumentPage>>
  _documentPagesRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documentPages,
    aliasName: 'document_files__id__document_pages__document_file_id',
  );

  $$DocumentPagesTableProcessedTableManager get documentPagesRefs {
    final manager = $$DocumentPagesTableTableManager(
      $_db,
      $_db.documentPages,
    ).filter((f) => f.documentFileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentPagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentFilesTableFilterComposer
    extends Composer<_$VaultDatabase, $DocumentFilesTable> {
  $$DocumentFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedRelativePath => $composableBuilder(
    column: $table.encryptedRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFilenameEncrypted => $composableBuilder(
    column: $table.originalFilenameEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get integrityHash => $composableBuilder(
    column: $table.integrityHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get encryptionVersion => $composableBuilder(
    column: $table.encryptionVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> documentPagesRefs(
    Expression<bool> Function($$DocumentPagesTableFilterComposer f) f,
  ) {
    final $$DocumentPagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentPages,
      getReferencedColumn: (t) => t.documentFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentPagesTableFilterComposer(
            $db: $db,
            $table: $db.documentPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentFilesTableOrderingComposer
    extends Composer<_$VaultDatabase, $DocumentFilesTable> {
  $$DocumentFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedRelativePath => $composableBuilder(
    column: $table.encryptedRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFilenameEncrypted => $composableBuilder(
    column: $table.originalFilenameEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get integrityHash => $composableBuilder(
    column: $table.integrityHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get encryptionVersion => $composableBuilder(
    column: $table.encryptionVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentFilesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $DocumentFilesTable> {
  $$DocumentFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get encryptedRelativePath => $composableBuilder(
    column: $table.encryptedRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalFilenameEncrypted => $composableBuilder(
    column: $table.originalFilenameEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get integrityHash => $composableBuilder(
    column: $table.integrityHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get encryptionVersion => $composableBuilder(
    column: $table.encryptionVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> documentPagesRefs<T extends Object>(
    Expression<T> Function($$DocumentPagesTableAnnotationComposer a) f,
  ) {
    final $$DocumentPagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentPages,
      getReferencedColumn: (t) => t.documentFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentPagesTableAnnotationComposer(
            $db: $db,
            $table: $db.documentPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentFilesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $DocumentFilesTable,
          DocumentFile,
          $$DocumentFilesTableFilterComposer,
          $$DocumentFilesTableOrderingComposer,
          $$DocumentFilesTableAnnotationComposer,
          $$DocumentFilesTableCreateCompanionBuilder,
          $$DocumentFilesTableUpdateCompanionBuilder,
          (DocumentFile, $$DocumentFilesTableReferences),
          DocumentFile,
          PrefetchHooks Function({bool documentId, bool documentPagesRefs})
        > {
  $$DocumentFilesTableTableManager(
    _$VaultDatabase db,
    $DocumentFilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<String> encryptedRelativePath = const Value.absent(),
                Value<String?> originalFilenameEncrypted = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> integrityHash = const Value.absent(),
                Value<int> encryptionVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentFilesCompanion(
                id: id,
                documentId: documentId,
                fileType: fileType,
                mimeType: mimeType,
                encryptedRelativePath: encryptedRelativePath,
                originalFilenameEncrypted: originalFilenameEncrypted,
                sizeBytes: sizeBytes,
                integrityHash: integrityHash,
                encryptionVersion: encryptionVersion,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                Value<String> fileType = const Value.absent(),
                required String mimeType,
                required String encryptedRelativePath,
                Value<String?> originalFilenameEncrypted = const Value.absent(),
                required int sizeBytes,
                required String integrityHash,
                required int encryptionVersion,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DocumentFilesCompanion.insert(
                id: id,
                documentId: documentId,
                fileType: fileType,
                mimeType: mimeType,
                encryptedRelativePath: encryptedRelativePath,
                originalFilenameEncrypted: originalFilenameEncrypted,
                sizeBytes: sizeBytes,
                integrityHash: integrityHash,
                encryptionVersion: encryptionVersion,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentFilesTable, DocumentFile>(table),
                  $$DocumentFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({documentId = false, documentPagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (documentPagesRefs) db.documentPages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (documentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.documentId,
                            referencedTable: $$DocumentFilesTableReferences
                                ._documentIdTable(db),
                            referencedColumn: $$DocumentFilesTableReferences
                                ._documentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (documentPagesRefs)
                        await $_getPrefetchedData<
                          DocumentFile,
                          $DocumentFilesTable,
                          DocumentPage
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentFilesTableReferences
                              ._documentPagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentFilesTableReferences(
                                db,
                                table,
                                p0,
                              ).documentPagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentFileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $DocumentFilesTable,
      DocumentFile,
      $$DocumentFilesTableFilterComposer,
      $$DocumentFilesTableOrderingComposer,
      $$DocumentFilesTableAnnotationComposer,
      $$DocumentFilesTableCreateCompanionBuilder,
      $$DocumentFilesTableUpdateCompanionBuilder,
      (DocumentFile, $$DocumentFilesTableReferences),
      DocumentFile,
      PrefetchHooks Function({bool documentId, bool documentPagesRefs})
    >;
typedef $$DocumentPagesTableCreateCompanionBuilder =
    DocumentPagesCompanion Function({
      required String id,
      required String documentId,
      required String documentFileId,
      required int pageNumber,
      Value<String?> encryptedPath,
      Value<String?> thumbnailPath,
      Value<int> rotation,
      Value<int?> width,
      Value<int?> height,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DocumentPagesTableUpdateCompanionBuilder =
    DocumentPagesCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String> documentFileId,
      Value<int> pageNumber,
      Value<String?> encryptedPath,
      Value<String?> thumbnailPath,
      Value<int> rotation,
      Value<int?> width,
      Value<int?> height,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DocumentPagesTableReferences
    extends BaseReferences<_$VaultDatabase, $DocumentPagesTable, DocumentPage> {
  $$DocumentPagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentsTable _documentIdTable(_$VaultDatabase db) =>
      db.documents.createAlias('document_pages__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DocumentFilesTable _documentFileIdTable(_$VaultDatabase db) => db
      .documentFiles
      .createAlias('document_pages__document_file_id__document_files__id');

  $$DocumentFilesTableProcessedTableManager get documentFileId {
    final $_column = $_itemColumn<String>('document_file_id')!;

    final manager = $$DocumentFilesTableTableManager(
      $_db,
      $_db.documentFiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentFileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentPagesTableFilterComposer
    extends Composer<_$VaultDatabase, $DocumentPagesTable> {
  $$DocumentPagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rotation => $composableBuilder(
    column: $table.rotation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentFilesTableFilterComposer get documentFileId {
    final $$DocumentFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentFileId,
      referencedTable: $db.documentFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentFilesTableFilterComposer(
            $db: $db,
            $table: $db.documentFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentPagesTableOrderingComposer
    extends Composer<_$VaultDatabase, $DocumentPagesTable> {
  $$DocumentPagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rotation => $composableBuilder(
    column: $table.rotation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentFilesTableOrderingComposer get documentFileId {
    final $$DocumentFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentFileId,
      referencedTable: $db.documentFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentFilesTableOrderingComposer(
            $db: $db,
            $table: $db.documentFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentPagesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $DocumentPagesTable> {
  $$DocumentPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rotation =>
      $composableBuilder(column: $table.rotation, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentFilesTableAnnotationComposer get documentFileId {
    final $$DocumentFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentFileId,
      referencedTable: $db.documentFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.documentFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentPagesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $DocumentPagesTable,
          DocumentPage,
          $$DocumentPagesTableFilterComposer,
          $$DocumentPagesTableOrderingComposer,
          $$DocumentPagesTableAnnotationComposer,
          $$DocumentPagesTableCreateCompanionBuilder,
          $$DocumentPagesTableUpdateCompanionBuilder,
          (DocumentPage, $$DocumentPagesTableReferences),
          DocumentPage,
          PrefetchHooks Function({bool documentId, bool documentFileId})
        > {
  $$DocumentPagesTableTableManager(
    _$VaultDatabase db,
    $DocumentPagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> documentFileId = const Value.absent(),
                Value<int> pageNumber = const Value.absent(),
                Value<String?> encryptedPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rotation = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentPagesCompanion(
                id: id,
                documentId: documentId,
                documentFileId: documentFileId,
                pageNumber: pageNumber,
                encryptedPath: encryptedPath,
                thumbnailPath: thumbnailPath,
                rotation: rotation,
                width: width,
                height: height,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required String documentFileId,
                required int pageNumber,
                Value<String?> encryptedPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rotation = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DocumentPagesCompanion.insert(
                id: id,
                documentId: documentId,
                documentFileId: documentFileId,
                pageNumber: pageNumber,
                encryptedPath: encryptedPath,
                thumbnailPath: thumbnailPath,
                rotation: rotation,
                width: width,
                height: height,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentPagesTable, DocumentPage>(table),
                  $$DocumentPagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({documentId = false, documentFileId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (documentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.documentId,
                            referencedTable: $$DocumentPagesTableReferences
                                ._documentIdTable(db),
                            referencedColumn: $$DocumentPagesTableReferences
                                ._documentIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (documentFileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.documentFileId,
                            referencedTable: $$DocumentPagesTableReferences
                                ._documentFileIdTable(db),
                            referencedColumn: $$DocumentPagesTableReferences
                                ._documentFileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentPagesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $DocumentPagesTable,
      DocumentPage,
      $$DocumentPagesTableFilterComposer,
      $$DocumentPagesTableOrderingComposer,
      $$DocumentPagesTableAnnotationComposer,
      $$DocumentPagesTableCreateCompanionBuilder,
      $$DocumentPagesTableUpdateCompanionBuilder,
      (DocumentPage, $$DocumentPagesTableReferences),
      DocumentPage,
      PrefetchHooks Function({bool documentId, bool documentFileId})
    >;
typedef $$DocumentFieldValuesTableCreateCompanionBuilder =
    DocumentFieldValuesCompanion Function({
      required String id,
      required String documentId,
      required String fieldKey,
      Value<String?> labelEncrypted,
      required String valueEncrypted,
      Value<String> valueType,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DocumentFieldValuesTableUpdateCompanionBuilder =
    DocumentFieldValuesCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String> fieldKey,
      Value<String?> labelEncrypted,
      Value<String> valueEncrypted,
      Value<String> valueType,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DocumentFieldValuesTableReferences
    extends
        BaseReferences<
          _$VaultDatabase,
          $DocumentFieldValuesTable,
          DocumentFieldValue
        > {
  $$DocumentFieldValuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentsTable _documentIdTable(_$VaultDatabase db) => db.documents
      .createAlias('document_field_values__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentFieldValuesTableFilterComposer
    extends Composer<_$VaultDatabase, $DocumentFieldValuesTable> {
  $$DocumentFieldValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldKey => $composableBuilder(
    column: $table.fieldKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelEncrypted => $composableBuilder(
    column: $table.labelEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueEncrypted => $composableBuilder(
    column: $table.valueEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentFieldValuesTableOrderingComposer
    extends Composer<_$VaultDatabase, $DocumentFieldValuesTable> {
  $$DocumentFieldValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldKey => $composableBuilder(
    column: $table.fieldKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelEncrypted => $composableBuilder(
    column: $table.labelEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueEncrypted => $composableBuilder(
    column: $table.valueEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentFieldValuesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $DocumentFieldValuesTable> {
  $$DocumentFieldValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fieldKey =>
      $composableBuilder(column: $table.fieldKey, builder: (column) => column);

  GeneratedColumn<String> get labelEncrypted => $composableBuilder(
    column: $table.labelEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valueEncrypted => $composableBuilder(
    column: $table.valueEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentFieldValuesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $DocumentFieldValuesTable,
          DocumentFieldValue,
          $$DocumentFieldValuesTableFilterComposer,
          $$DocumentFieldValuesTableOrderingComposer,
          $$DocumentFieldValuesTableAnnotationComposer,
          $$DocumentFieldValuesTableCreateCompanionBuilder,
          $$DocumentFieldValuesTableUpdateCompanionBuilder,
          (DocumentFieldValue, $$DocumentFieldValuesTableReferences),
          DocumentFieldValue,
          PrefetchHooks Function({bool documentId})
        > {
  $$DocumentFieldValuesTableTableManager(
    _$VaultDatabase db,
    $DocumentFieldValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentFieldValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentFieldValuesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DocumentFieldValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> fieldKey = const Value.absent(),
                Value<String?> labelEncrypted = const Value.absent(),
                Value<String> valueEncrypted = const Value.absent(),
                Value<String> valueType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentFieldValuesCompanion(
                id: id,
                documentId: documentId,
                fieldKey: fieldKey,
                labelEncrypted: labelEncrypted,
                valueEncrypted: valueEncrypted,
                valueType: valueType,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required String fieldKey,
                Value<String?> labelEncrypted = const Value.absent(),
                required String valueEncrypted,
                Value<String> valueType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DocumentFieldValuesCompanion.insert(
                id: id,
                documentId: documentId,
                fieldKey: fieldKey,
                labelEncrypted: labelEncrypted,
                valueEncrypted: valueEncrypted,
                valueType: valueType,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentFieldValuesTable, DocumentFieldValue>(
                    table,
                  ),
                  $$DocumentFieldValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentId,
                        referencedTable: $$DocumentFieldValuesTableReferences
                            ._documentIdTable(db),
                        referencedColumn: $$DocumentFieldValuesTableReferences
                            ._documentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentFieldValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $DocumentFieldValuesTable,
      DocumentFieldValue,
      $$DocumentFieldValuesTableFilterComposer,
      $$DocumentFieldValuesTableOrderingComposer,
      $$DocumentFieldValuesTableAnnotationComposer,
      $$DocumentFieldValuesTableCreateCompanionBuilder,
      $$DocumentFieldValuesTableUpdateCompanionBuilder,
      (DocumentFieldValue, $$DocumentFieldValuesTableReferences),
      DocumentFieldValue,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String nameEncrypted,
  required String normalizedNameHash,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> nameEncrypted,
  Value<String> normalizedNameHash,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$VaultDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DocumentTagsTable, List<DocumentTag>>
  _documentTagsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.documentTags,
    aliasName: 'tags__id__document_tags__tag_id',
  );

  $$DocumentTagsTableProcessedTableManager get documentTagsRefs {
    final manager = $$DocumentTagsTableTableManager(
      $_db,
      $_db.documentTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$VaultDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEncrypted => $composableBuilder(
    column: $table.nameEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedNameHash => $composableBuilder(
    column: $table.normalizedNameHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> documentTagsRefs(
    Expression<bool> Function($$DocumentTagsTableFilterComposer f) f,
  ) {
    final $$DocumentTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTagsTableFilterComposer(
            $db: $db,
            $table: $db.documentTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer
    extends Composer<_$VaultDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEncrypted => $composableBuilder(
    column: $table.nameEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedNameHash => $composableBuilder(
    column: $table.normalizedNameHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameEncrypted => $composableBuilder(
    column: $table.nameEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedNameHash => $composableBuilder(
    column: $table.normalizedNameHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> documentTagsRefs<T extends Object>(
    Expression<T> Function($$DocumentTagsTableAnnotationComposer a) f,
  ) {
    final $$DocumentTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.documentTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool documentTagsRefs})
        > {
  $$TagsTableTableManager(_$VaultDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nameEncrypted = const Value.absent(),
                Value<String> normalizedNameHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                nameEncrypted: nameEncrypted,
                normalizedNameHash: normalizedNameHash,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameEncrypted,
                required String normalizedNameHash,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                nameEncrypted: nameEncrypted,
                normalizedNameHash: normalizedNameHash,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, Tag>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (documentTagsRefs) db.documentTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (documentTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, DocumentTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._documentTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).documentTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool documentTagsRefs})
    >;
typedef $$DocumentTagsTableCreateCompanionBuilder =
    DocumentTagsCompanion Function({
      required String documentId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$DocumentTagsTableUpdateCompanionBuilder =
    DocumentTagsCompanion Function({
      Value<String> documentId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$DocumentTagsTableReferences
    extends BaseReferences<_$VaultDatabase, $DocumentTagsTable, DocumentTag> {
  $$DocumentTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$VaultDatabase db) =>
      db.documents.createAlias('document_tags__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$VaultDatabase db) =>
      db.tags.createAlias('document_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentTagsTableFilterComposer
    extends Composer<_$VaultDatabase, $DocumentTagsTable> {
  $$DocumentTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentTagsTableOrderingComposer
    extends Composer<_$VaultDatabase, $DocumentTagsTable> {
  $$DocumentTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentTagsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $DocumentTagsTable> {
  $$DocumentTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentTagsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $DocumentTagsTable,
          DocumentTag,
          $$DocumentTagsTableFilterComposer,
          $$DocumentTagsTableOrderingComposer,
          $$DocumentTagsTableAnnotationComposer,
          $$DocumentTagsTableCreateCompanionBuilder,
          $$DocumentTagsTableUpdateCompanionBuilder,
          (DocumentTag, $$DocumentTagsTableReferences),
          DocumentTag,
          PrefetchHooks Function({bool documentId, bool tagId})
        > {
  $$DocumentTagsTableTableManager(_$VaultDatabase db, $DocumentTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> documentId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentTagsCompanion(
                documentId: documentId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String documentId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => DocumentTagsCompanion.insert(
                documentId: documentId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentTagsTable, DocumentTag>(table),
                  $$DocumentTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentId,
                        referencedTable: $$DocumentTagsTableReferences
                            ._documentIdTable(db),
                        referencedColumn: $$DocumentTagsTableReferences
                            ._documentIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$DocumentTagsTableReferences
                            ._tagIdTable(db),
                        referencedColumn: $$DocumentTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $DocumentTagsTable,
      DocumentTag,
      $$DocumentTagsTableFilterComposer,
      $$DocumentTagsTableOrderingComposer,
      $$DocumentTagsTableAnnotationComposer,
      $$DocumentTagsTableCreateCompanionBuilder,
      $$DocumentTagsTableUpdateCompanionBuilder,
      (DocumentTag, $$DocumentTagsTableReferences),
      DocumentTag,
      PrefetchHooks Function({bool documentId, bool tagId})
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required String documentId,
  Value<String> reminderType,
  required DateTime targetDate,
  Value<int?> offsetDays,
  required DateTime scheduledAt,
  Value<String> status,
  Value<int?> notificationId,
  Value<DateTime?> snoozedUntil,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String> documentId,
  Value<String> reminderType,
  Value<DateTime> targetDate,
  Value<int?> offsetDays,
  Value<DateTime> scheduledAt,
  Value<String> status,
  Value<int?> notificationId,
  Value<DateTime?> snoozedUntil,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$VaultDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$VaultDatabase db) =>
      db.documents.createAlias('reminders__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$VaultDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offsetDays => $composableBuilder(
    column: $table.offsetDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$VaultDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetDays => $composableBuilder(
    column: $table.offsetDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$VaultDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get offsetDays => $composableBuilder(
    column: $table.offsetDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool documentId})
        > {
  $$RemindersTableTableManager(_$VaultDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> reminderType = const Value.absent(),
                Value<DateTime> targetDate = const Value.absent(),
                Value<int?> offsetDays = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                documentId: documentId,
                reminderType: reminderType,
                targetDate: targetDate,
                offsetDays: offsetDays,
                scheduledAt: scheduledAt,
                status: status,
                notificationId: notificationId,
                snoozedUntil: snoozedUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                Value<String> reminderType = const Value.absent(),
                required DateTime targetDate,
                Value<int?> offsetDays = const Value.absent(),
                required DateTime scheduledAt,
                Value<String> status = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                documentId: documentId,
                reminderType: reminderType,
                targetDate: targetDate,
                offsetDays: offsetDays,
                scheduledAt: scheduledAt,
                status: status,
                notificationId: notificationId,
                snoozedUntil: snoozedUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, Reminder>(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentId,
                        referencedTable: $$RemindersTableReferences
                            ._documentIdTable(db),
                        referencedColumn: $$RemindersTableReferences
                            ._documentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$BackupRecordsTableCreateCompanionBuilder =
    BackupRecordsCompanion Function({
      required String id,
      Value<String?> relativePath,
      required DateTime createdAt,
      required int sizeBytes,
      required bool verified,
      Value<int> rowid,
    });
typedef $$BackupRecordsTableUpdateCompanionBuilder =
    BackupRecordsCompanion Function({
      Value<String> id,
      Value<String?> relativePath,
      Value<DateTime> createdAt,
      Value<int> sizeBytes,
      Value<bool> verified,
      Value<int> rowid,
    });

class $$BackupRecordsTableFilterComposer
    extends Composer<_$VaultDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupRecordsTableOrderingComposer
    extends Composer<_$VaultDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupRecordsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get verified =>
      $composableBuilder(column: $table.verified, builder: (column) => column);
}

class $$BackupRecordsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $BackupRecordsTable,
          BackupRecord,
          $$BackupRecordsTableFilterComposer,
          $$BackupRecordsTableOrderingComposer,
          $$BackupRecordsTableAnnotationComposer,
          $$BackupRecordsTableCreateCompanionBuilder,
          $$BackupRecordsTableUpdateCompanionBuilder,
          (
            BackupRecord,
            BaseReferences<_$VaultDatabase, $BackupRecordsTable, BackupRecord>,
          ),
          BackupRecord,
          PrefetchHooks Function()
        > {
  $$BackupRecordsTableTableManager(
    _$VaultDatabase db,
    $BackupRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> relativePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupRecordsCompanion(
                id: id,
                relativePath: relativePath,
                createdAt: createdAt,
                sizeBytes: sizeBytes,
                verified: verified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> relativePath = const Value.absent(),
                required DateTime createdAt,
                required int sizeBytes,
                required bool verified,
                Value<int> rowid = const Value.absent(),
              }) => BackupRecordsCompanion.insert(
                id: id,
                relativePath: relativePath,
                createdAt: createdAt,
                sizeBytes: sizeBytes,
                verified: verified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BackupRecordsTable, BackupRecord>(table),
                  BaseReferences<
                    _$VaultDatabase,
                    $BackupRecordsTable,
                    BackupRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $BackupRecordsTable,
      BackupRecord,
      $$BackupRecordsTableFilterComposer,
      $$BackupRecordsTableOrderingComposer,
      $$BackupRecordsTableAnnotationComposer,
      $$BackupRecordsTableCreateCompanionBuilder,
      $$BackupRecordsTableUpdateCompanionBuilder,
      (
        BackupRecord,
        BaseReferences<_$VaultDatabase, $BackupRecordsTable, BackupRecord>,
      ),
      BackupRecord,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String valueEncrypted,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> valueEncrypted,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$VaultDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueEncrypted => $composableBuilder(
    column: $table.valueEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$VaultDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueEncrypted => $composableBuilder(
    column: $table.valueEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueEncrypted => $composableBuilder(
    column: $table.valueEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$VaultDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$VaultDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueEncrypted = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                valueEncrypted: valueEncrypted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueEncrypted,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                valueEncrypted: valueEncrypted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<
                    _$VaultDatabase,
                    $AppSettingsTable,
                    AppSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$VaultDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$PendingOperationsTableCreateCompanionBuilder =
    PendingOperationsCompanion Function({
      required String id,
      required String operationType,
      required String entityId,
      required String state,
      Value<String?> payloadEncrypted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PendingOperationsTableUpdateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<String> id,
      Value<String> operationType,
      Value<String> entityId,
      Value<String> state,
      Value<String?> payloadEncrypted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PendingOperationsTableFilterComposer
    extends Composer<_$VaultDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadEncrypted => $composableBuilder(
    column: $table.payloadEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOperationsTableOrderingComposer
    extends Composer<_$VaultDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadEncrypted => $composableBuilder(
    column: $table.payloadEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOperationsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get payloadEncrypted => $composableBuilder(
    column: $table.payloadEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PendingOperationsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $PendingOperationsTable,
          PendingOperation,
          $$PendingOperationsTableFilterComposer,
          $$PendingOperationsTableOrderingComposer,
          $$PendingOperationsTableAnnotationComposer,
          $$PendingOperationsTableCreateCompanionBuilder,
          $$PendingOperationsTableUpdateCompanionBuilder,
          (
            PendingOperation,
            BaseReferences<
              _$VaultDatabase,
              $PendingOperationsTable,
              PendingOperation
            >,
          ),
          PendingOperation,
          PrefetchHooks Function()
        > {
  $$PendingOperationsTableTableManager(
    _$VaultDatabase db,
    $PendingOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> payloadEncrypted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingOperationsCompanion(
                id: id,
                operationType: operationType,
                entityId: entityId,
                state: state,
                payloadEncrypted: payloadEncrypted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operationType,
                required String entityId,
                required String state,
                Value<String?> payloadEncrypted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingOperationsCompanion.insert(
                id: id,
                operationType: operationType,
                entityId: entityId,
                state: state,
                payloadEncrypted: payloadEncrypted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingOperationsTable, PendingOperation>(table),
                  BaseReferences<
                    _$VaultDatabase,
                    $PendingOperationsTable,
                    PendingOperation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $PendingOperationsTable,
      PendingOperation,
      $$PendingOperationsTableFilterComposer,
      $$PendingOperationsTableOrderingComposer,
      $$PendingOperationsTableAnnotationComposer,
      $$PendingOperationsTableCreateCompanionBuilder,
      $$PendingOperationsTableUpdateCompanionBuilder,
      (
        PendingOperation,
        BaseReferences<
          _$VaultDatabase,
          $PendingOperationsTable,
          PendingOperation
        >,
      ),
      PendingOperation,
      PrefetchHooks Function()
    >;

class $VaultDatabaseManager {
  final _$VaultDatabase _db;
  $VaultDatabaseManager(this._db);
  $$VaultsTableTableManager get vaults =>
      $$VaultsTableTableManager(_db, _db.vaults);
  $$FamilyMembersTableTableManager get familyMembers =>
      $$FamilyMembersTableTableManager(_db, _db.familyMembers);
  $$DocumentCategoriesTableTableManager get documentCategories =>
      $$DocumentCategoriesTableTableManager(_db, _db.documentCategories);
  $$PhysicalLocationsTableTableManager get physicalLocations =>
      $$PhysicalLocationsTableTableManager(_db, _db.physicalLocations);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$DocumentVersionsTableTableManager get documentVersions =>
      $$DocumentVersionsTableTableManager(_db, _db.documentVersions);
  $$DocumentOwnersTableTableManager get documentOwners =>
      $$DocumentOwnersTableTableManager(_db, _db.documentOwners);
  $$DocumentFilesTableTableManager get documentFiles =>
      $$DocumentFilesTableTableManager(_db, _db.documentFiles);
  $$DocumentPagesTableTableManager get documentPages =>
      $$DocumentPagesTableTableManager(_db, _db.documentPages);
  $$DocumentFieldValuesTableTableManager get documentFieldValues =>
      $$DocumentFieldValuesTableTableManager(_db, _db.documentFieldValues);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$DocumentTagsTableTableManager get documentTags =>
      $$DocumentTagsTableTableManager(_db, _db.documentTags);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$BackupRecordsTableTableManager get backupRecords =>
      $$BackupRecordsTableTableManager(_db, _db.backupRecords);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(_db, _db.pendingOperations);
}
