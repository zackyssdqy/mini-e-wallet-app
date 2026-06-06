import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/balance_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/transaction_item.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsyncValue = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: dashboardAsyncValue.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => _DashboardErrorState(
            message: _resolveErrorMessage(error),
            onRetry: () => ref.invalidate(dashboardProvider),
          ),
          data: (dashboard) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardProvider);
                await ref.read(dashboardProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Text(
                    'Selamat datang, ${dashboard.name}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  BalanceCard(balanceText: CurrencyFormatter.formatRupiah(dashboard.balance)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Transfer Dana',
                          onPressed: () => _goToTransfer(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Riwayat Transaksi',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => _goToTransactions(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '5 transaksi terakhir',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (dashboard.recentTransactions.isEmpty)
                    const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Belum ada transaksi',
                      subtitle: 'Transaksi terakhir Anda akan muncul di sini.',
                    )
                  else
                    ...dashboard.recentTransactions.map(
                      (transaction) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TransactionItem(transaction: transaction),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _goToTransfer(BuildContext context) {
    context.go('/transfer');
  }

  void _goToTransactions(BuildContext context) {
    context.go('/transactions');
  }
}

String _resolveErrorMessage(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  return 'Gagal memuat dashboard';
}

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Coba Lagi',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
