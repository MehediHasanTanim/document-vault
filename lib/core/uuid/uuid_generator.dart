import 'package:uuid/uuid.dart';

abstract interface class UuidGenerator {
  String v4();
}

class PackageUuidGenerator implements UuidGenerator {
  const PackageUuidGenerator([this._uuid = const Uuid()]);
  final Uuid _uuid;
  @override
  String v4() => _uuid.v4();
}
