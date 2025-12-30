import 'package:dio/dio.dart';
import 'package:periksa_kesehatan/core/storage/storage_service.dart';

/// Interceptor untuk menambahkan token authentication ke request
class AuthInterceptor extends Interceptor {
  final StorageService _storageService = StorageService.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ambil token dari storage
    final token = _storageService.getToken();

    // Tambahkan token ke header jika tersedia
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired atau invalid
    if (err.response?.statusCode == 401) {
      // TODO: Implementasi refresh token logic di sini
      // Untuk sekarang, kita hanya akan melewatkan error
    }

    super.onError(err, handler);
  }
}

