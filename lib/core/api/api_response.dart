class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  final bool success;
  final String? message;
  final T? data;

  factory ApiResponse.fromJson(
    Object? json, {
    T Function(Object? json)? converter,
  }) {
    if (json is Map<String, dynamic>) {
      final success = json['success'] == true;
      final message = json['message']?.toString();
      final rawData = json.containsKey('data') ? json['data'] : null;
      final parsedData = converter == null ? rawData as T? : _convert(rawData, converter);

      return ApiResponse<T>(
        success: success || json.isEmpty,
        message: message,
        data: parsedData,
      );
    }

    if (converter != null) {
      return ApiResponse<T>(success: true, data: converter(json));
    }

    return ApiResponse<T>(success: true, data: json as T?);
  }

  static T? _convert<T>(Object? rawData, T Function(Object? json) converter) {
    if (rawData == null) {
      return null;
    }
    return converter(rawData);
  }
}
