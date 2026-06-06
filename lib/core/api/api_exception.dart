class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.timeout() {
    return ApiException('Koneksi ke server terlalu lama');
  }

  factory ApiException.network() {
    return ApiException('Tidak dapat terhubung ke server');
  }

  factory ApiException.unauthorized() {
    return ApiException('Sesi Anda telah berakhir');
  }

  factory ApiException.api(String message, {int? statusCode}) {
    return ApiException(message, statusCode: statusCode);
  }

  @override
  String toString() => message;
}
