import 'package:dio/dio.dart';

/// Custom exception untuk API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;

  /// Factory constructor untuk DioException
  factory ApiException.fromDioException(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException(
            message: 'Koneksi timeout. Periksa koneksi internet Anda.',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.badResponse:
          // Coba ambil message dari response data terlebih dahulu
          String message = _extractMessageFromResponse(error.response?.data);
          // Jika tidak ada message dari response, gunakan default berdasarkan status code
          if (message.isEmpty) {
            message = _handleStatusCode(error.response?.statusCode);
          }
          return ApiException(
            message: message,
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.cancel:
          return ApiException(
            message: 'Request dibatalkan',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.unknown:
        default:
          return ApiException(
            message: 'Terjadi kesalahan. Periksa koneksi internet Anda.',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
      }
    }
    return ApiException(message: 'Terjadi kesalahan yang tidak diketahui');
  }

  /// Extract message dari response data
  static String _extractMessageFromResponse(dynamic data) {
    if (data == null) return '';
    
    try {
      if (data is Map<String, dynamic>) {
        // Coba ambil dari field 'message'
        if (data.containsKey('message') && data['message'] != null) {
          return data['message'].toString();
        }
        // Coba ambil dari field 'error'
        if (data.containsKey('error') && data['error'] != null) {
          return data['error'].toString();
        }
      }
    } catch (e) {
      // Jika gagal extract, return empty string
    }
    
    return '';
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid';
      case 401:
        return 'Unauthorized. Silakan login kembali.';
      case 403:
        return 'Akses ditolak';
      case 404:
        return 'Data tidak ditemukan';
      case 500:
        return 'Terjadi kesalahan pada server';
      default:
        return 'Terjadi kesalahan';
    }
  }
}

