import '../../transaction/models/transaction_entry.dart';

class DashboardData {
  const DashboardData({
    required this.name,
    required this.balance,
    required this.recentTransactions,
  });

  final String name;
  final int balance;
  final List<TransactionEntry> recentTransactions;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final recentTransactionsRaw = json['recent_transactions'];
    final recentTransactions = <TransactionEntry>[];

    if (recentTransactionsRaw is List) {
      for (final item in recentTransactionsRaw) {
        if (item is Map<String, dynamic>) {
          recentTransactions.add(TransactionEntry.fromJson(item));
        } else if (item is Map) {
          recentTransactions.add(TransactionEntry.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return DashboardData(
      name: _asString(json['name']) ?? 'Pengguna',
      balance: _asInt(json['balance']) ?? 0,
      recentTransactions: recentTransactions,
    );
  }

  static String? _asString(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _asInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}
