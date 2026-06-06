import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy HH:mm');

  static String formatDateTime(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return _displayFormat.format(value);
  }
}
