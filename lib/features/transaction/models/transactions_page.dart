import 'transaction_entry.dart';

class TransactionsPage {
  const TransactionsPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  final List<TransactionEntry> items;
  final int currentPage;
  final int? lastPage;

  bool get hasMore => lastPage == null ? items.isNotEmpty : currentPage < lastPage!;

  factory TransactionsPage.fromJson(Object? json) {
    if (json is List) {
      return TransactionsPage(
        items: _parseTransactions(json),
        currentPage: 1,
        lastPage: 1,
      );
    }

    if (json is Map<String, dynamic>) {
      final data = json['data'];
      final container = data is Map<String, dynamic> ? data : json;
      final listSource = data is List ? data : container['data'];
      final items = listSource is List ? _parseTransactions(listSource) : <TransactionEntry>[];
      final meta = _extractMap(container['meta']) ?? _extractMap(json['meta']);

      return TransactionsPage(
        items: items,
        currentPage: _pickInt(meta ?? json, const ['current_page', 'page']) ?? 1,
        lastPage: _pickInt(meta ?? json, const ['last_page', 'total_pages']),
      );
    }

    return const TransactionsPage(items: <TransactionEntry>[], currentPage: 1, lastPage: 1);
  }

  static List<TransactionEntry> _parseTransactions(List source) {
    return source
        .whereType<Map>()
        .map((item) => TransactionEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  static int? _pickInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value != null) {
        final parsed = int.tryParse(value.toString());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static Map<String, dynamic>? _extractMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
