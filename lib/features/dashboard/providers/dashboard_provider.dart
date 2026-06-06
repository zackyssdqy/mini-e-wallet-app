import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/dashboard_data.dart';
import '../../auth/providers/auth_providers.dart';

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get<DashboardData>(
    '/api/dashboard',
    converter: (json) {
      final data = _asMap(json);
      return DashboardData.fromJson(data);
    },
  );

  if (response.data == null) {
    throw ApiException.api(response.message ?? 'Dashboard tidak tersedia');
  }

  return response.data!;
});

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}
