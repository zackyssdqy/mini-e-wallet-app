import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/transaction_item.dart';
import '../providers/transaction_provider.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsControllerProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final thresholdReached = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (thresholdReached) {
      ref.read(transactionsControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsControllerProvider);
    final controller = ref.read(transactionsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: SafeArea(
        child: state.isLoading && state.items.isEmpty
            ? const LoadingIndicator()
            : RefreshIndicator(
                onRefresh: () => controller.refresh(),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    if (state.errorMessage != null && state.items.isEmpty)
                      _TransactionErrorState(
                        message: state.errorMessage!,
                        onRetry: controller.refresh,
                      )
                    else if (state.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 72),
                        child: EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'Belum ada transaksi',
                          subtitle: 'Riwayat transaksi Anda akan muncul di sini.',
                        ),
                      )
                    else ...[
                      for (final transaction in state.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TransactionItem(transaction: transaction),
                        ),
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (!state.hasMore)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                              'Tidak ada transaksi lagi',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _TransactionErrorState extends StatelessWidget {
  const _TransactionErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
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
            onPressed: () => onRetry(),
          ),
        ],
      ),
    );
  }
}
