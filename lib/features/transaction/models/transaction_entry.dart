enum TransactionDirection { incoming, outgoing }

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.counterpartName,
    required this.amount,
    required this.direction,
    required this.occurredAt,
    this.description,
    this.rawType,
  });

  final String id;
  final String counterpartName;
  final int amount;
  final TransactionDirection direction;
  final DateTime? occurredAt;
  final String? description;
  final String? rawType;

  bool get isIncoming => direction == TransactionDirection.incoming;

  String get title {
    if (description != null && description!.trim().isNotEmpty) {
      return description!;
    }
    return isIncoming ? 'Transfer dari $counterpartName' : 'Transfer ke $counterpartName';
  }

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    final rawType = _pickString(json, const [
      'type',
      'transaction_type',
      'direction',
      'status',
    ]);
    final incoming = _determineIncoming(json, rawType);

    return TransactionEntry(
      id: _pickString(json, const ['id', 'transaction_id']) ?? '',
      counterpartName: _pickString(json, const [
            'counterpart_name',
            'receiver_name',
            'sender_name',
            'name',
            'counterpart',
            'target_name',
            'user_name',
          ]) ??
          'Pengguna',
      amount: _pickInt(json, const ['amount', 'nominal', 'value']) ?? 0,
      direction: incoming ? TransactionDirection.incoming : TransactionDirection.outgoing,
      occurredAt: _pickDate(json, const ['created_at', 'date', 'transaction_date', 'occurred_at']),
      description: _pickString(json, const ['description', 'note', 'remarks', 'message']),
      rawType: rawType,
    );
  }

  static bool _determineIncoming(Map<String, dynamic> json, String? rawType) {
    final directFlag = json['is_incoming'];
    if (directFlag is bool) {
      return directFlag;
    }

    final direction = rawType?.toLowerCase().trim();
    const incomingKeywords = <String>[
      'incoming',
      'receive',
      'received',
      'credit',
      'income',
      'in',
      'topup',
      'top_up',
      'deposit',
    ];
    if (direction != null) {
      for (final keyword in incomingKeywords) {
        if (direction.contains(keyword)) {
          return true;
        }
      }
    }

    final type = json['transaction_type']?.toString().toLowerCase();
    if (type != null) {
      for (final keyword in incomingKeywords) {
        if (type.contains(keyword)) {
          return true;
        }
      }
    }

    return false;
  }

  static String? _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
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

  static DateTime? _pickDate(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is DateTime) {
        return value;
      }
      if (value != null) {
        final parsed = DateTime.tryParse(value.toString());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }
}
