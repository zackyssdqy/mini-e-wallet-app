import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/storage/auth_storage.dart';
import 'features/auth/providers/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final authStorage = AuthStorage(sharedPreferences);
  final initialToken = await authStorage.readToken();

  runApp(
    ProviderScope(
      overrides: [
        authStorageProvider.overrideWithValue(authStorage),
        initialTokenProvider.overrideWithValue(initialToken),
      ],
      child: const MiniEWalletApp(),
    ),
  );
}
