import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../features/transaction/providers/transaction_provider.dart';
import '../models/auth_session.dart';

final authStorageProvider = Provider<AuthStorage>((ref) {
  throw UnimplementedError('authStorageProvider must be overridden in main');
});

final initialTokenProvider = Provider<String?>((ref) {
  return null;
});

final dioProvider = Provider<Dio>((ref) {
  final dio = buildDio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authControllerProvider).token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await ref.read(authControllerProvider.notifier).clearSession();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthState {
  const AuthState({
    required this.token,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? token;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final initialToken = ref.watch(initialTokenProvider);
    return AuthState(token: initialToken);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await ref.read(apiClientProvider).post<AuthSession>(
            '/api/login',
            data: <String, dynamic>{
              'email': email,
              'password': password,
            },
            converter: (json) {
              final payload = _readPayload(json);
              return AuthSession.fromJson(payload);
            },
          );

      final session = response.data;
      if (session == null || session.token.isEmpty) {
        throw ApiException.api('Token login tidak ditemukan');
      }

      await ref.read(authStorageProvider).saveToken(session.token);
      state = AuthState(token: session.token);
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan saat login',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(apiClientProvider).post<dynamic>('/api/logout');
    } catch (_) {
      // Logout should still clear the local session even if the API call fails.
    } finally {
      await clearSession();
    }
  }

  Future<void> clearSession() async {
    await ref.read(authStorageProvider).clearToken();
    state = const AuthState(token: null);
    ref.invalidate(dashboardProvider);
    ref.invalidate(transactionsControllerProvider);
  }

  Map<String, dynamic> _readPayload(Object? json) {
    if (json is Map<String, dynamic>) {
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return json;
    }
    return <String, dynamic>{};
  }
}
