import 'package:flutter/material.dart';

import 'app_card.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balanceText,
  });

  final String balanceText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Saat Ini',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.85),
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              balanceText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 34,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
