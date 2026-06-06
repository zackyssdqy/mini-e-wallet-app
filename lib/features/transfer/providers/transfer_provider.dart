import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../../transaction/providers/transaction_provider.dart';

final transferControllerProvider =
    StateNotifierProvider<TransferController, bool>(TransferController.new);

class TransferController extends StateNotifier<bool> {
  TransferController(this._ref) : super(false);

  final Ref _ref;

  Future<void> submit({
    required int receiverId,
    required int amount,
  }) async {
    if (state) {
      return;
    }

    state = true;

    try {
      await _ref.read(apiClientProvider).post<dynamic>(
            '/api/transfers',
            data: <String, dynamic>{
              'receiver_id': receiverId,
              'amount': amount,
            },
          );

      _ref.invalidate(dashboardProvider);
      try {
        await _ref.read(transactionsControllerProvider.notifier).refresh();
      } catch (_) {
        // Refresh can fail independently; the transfer itself already succeeded.
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException.api('Transfer gagal diproses');
    } finally {
      state = false;
    }
  }
}
