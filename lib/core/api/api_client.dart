import 'package:dio/dio.dart';

import '../constants/app_config.dart';
import 'api_exception.dart';
import 'api_response.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? converter,
  }) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      ),
      converter: converter,
    );
    return response;
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? converter,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
      converter: converter,
    );
    return response;
  }

  Future<ApiResponse<T>> _request<T>(
    Future<Response<dynamic>> Function() request, {
    T Function(Object? json)? converter,
  }) async {
    try {
      final response = await request();
      final apiResponse = ApiResponse<T>.fromJson(
        response.data,
        converter: converter,
      );

      if (!apiResponse.success) {
        throw ApiException.api(
          apiResponse.message ?? 'Permintaan gagal diproses',
          statusCode: response.statusCode,
        );
      }

      return apiResponse;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  ApiException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException.timeout();
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException.network();
    }

    final response = error.response;
    if (response?.statusCode == 401) {
      return ApiException.unauthorized();
    }

    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return ApiException.api(message, statusCode: response?.statusCode);
      }
    }

    if (error.message != null && error.message!.isNotEmpty) {
      return ApiException.api(error.message!, statusCode: response?.statusCode);
    }

    return ApiException.api('Terjadi kesalahan tidak terduga');
  }
}

Dio buildDio() {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
}
