import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../features/transaction/models/transaction_entry.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
  });

  final TransactionEntry transaction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final amountColor = transaction.isIncoming ? colorScheme.tertiary : colorScheme.primary;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    transaction.isIncoming ? colorScheme.tertiary.withOpacity(0.12) : colorScheme.primary.withOpacity(0.12),
                foregroundColor: amountColor,
                child: Icon(
                  transaction.isIncoming ? Icons.call_received : Icons.call_made,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDateTime(transaction.occurredAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (transaction.rawType != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.rawType!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                CurrencyFormatter.formatSignedRupiah(
                  transaction.amount,
                  incoming: transaction.isIncoming,
                ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: amountColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
