import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String formatIsoString(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return '';
    }
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(dt);
    } catch (_) {
      return isoString;
    }
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime.toLocal());
  }
}

