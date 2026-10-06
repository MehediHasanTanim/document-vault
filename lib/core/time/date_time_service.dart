import 'package:intl/intl.dart';

abstract interface class DateTimeService {
  DateTime now();
  String formatDate(DateTime value, String languageCode);
}

class SystemDateTimeService implements DateTimeService {
  const SystemDateTimeService();
  @override
  DateTime now() => DateTime.now();
  @override
  String formatDate(DateTime value, String languageCode) =>
      DateFormat.yMMMd(languageCode).format(value);
}
