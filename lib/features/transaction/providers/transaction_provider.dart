import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/transaction_entry.dart';
import '../models/transactions_page.dart';

final transactionsControllerProvider =
    StateNotifierProvider<TransactionsController, TransactionsState>(
  TransactionsController.new,
);

class TransactionsState {
  const TransactionsState({
    required this.items,
    required this.currentPage,
    required this.hasMore,
    required this.isLoading,
    required this.isLoadingMore,
    this.errorMessage,
  });

  final List<TransactionEntry> items;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  factory TransactionsState.initial() {
    return const TransactionsState(
      items: <TransactionEntry>[],
      currentPage: 0,
      hasMore: true,
      isLoading: false,
      isLoadingMore: false,
    );
  }

  TransactionsState copyWith({
    List<TransactionEntry>? items,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return TransactionsState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

class TransactionsController extends StateNotifier<TransactionsState> {
  TransactionsController(this._ref) : super(TransactionsState.initial());

  final Ref _ref;

  ApiClient get _apiClient => _ref.read(apiClientProvider);

  Future<void> loadInitial({bool force = false}) async {
    if (state.isLoading) {
      return;
    }
    if (!force && state.items.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final page = await _fetchPage(page: 1);
      state = state.copyWith(
        items: page.items,
        currentPage: page.currentPage,
        hasMore: page.hasMore,
        isLoading: false,
        isLoadingMore: false,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat riwayat transaksi',
      );
      rethrow;
    }
  }

  Future<void> refresh() => loadInitial(force: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final nextPage = state.currentPage + 1;
      final page = await _fetchPage(page: nextPage);
      state = state.copyWith(
        items: [...state.items, ...page.items],
        currentPage: page.currentPage,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoadingMore: false, errorMessage: error.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Gagal memuat transaksi berikutnya',
      );
      rethrow;
    }
  }

  Future<TransactionsPage> _fetchPage({required int page}) async {
    final response = await _apiClient.get<TransactionsPage>(
      '/api/transactions',
      queryParameters: <String, dynamic>{
        'page': page,
        'sort': 'desc',
      },
      converter: (json) => TransactionsPage.fromJson(json),
    );

    return response.data ??
        const TransactionsPage(items: <TransactionEntry>[], currentPage: 1, lastPage: 1);
  }
}
