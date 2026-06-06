import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_providers.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/transaction/screens/transaction_screen.dart';
import '../features/transfer/screens/transfer_screen.dart';
import '../shared/layouts/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!loggedIn) {
        return isLoginRoute ? null : '/login';
      }

      if (isLoginRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const MaterialPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/transfer',
            pageBuilder: (context, state) => const MaterialPage(
              child: TransferScreen(),
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => const MaterialPage(
              child: TransactionScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text(
            state.error?.toString() ?? 'Halaman tidak ditemukan',
          ),
        ),
      );
    },
  );
});
