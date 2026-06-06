import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String formatRupiah(num value) {
    return _currency.format(value).replaceAll(',00', '');
  }

  static String formatSignedRupiah(num value, {required bool incoming}) {
    final formatted = formatRupiah(value.abs());
    return incoming ? '+$formatted' : '-$formatted';
  }
}
