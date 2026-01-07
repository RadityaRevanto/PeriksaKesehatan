import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:periksa_kesehatan/core/network/api_endpoints.dart';
import 'package:periksa_kesehatan/core/network/api_exception.dart';
import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:periksa_kesehatan/data/models/health/health_data_model.dart';
import 'package:periksa_kesehatan/data/models/health/health_summary_model.dart';
import 'package:periksa_kesehatan/data/models/health/health_alert_model.dart';

/// Remote data source untuk health data
abstract class HealthRemoteDataSource {
  Future<HealthDataModel> saveHealthData(HealthDataModel healthData);
  Future<HealthDataModel?> getHealthData();
  Future<HealthSummaryModel?> getHealthHistory();
  Future<List<int>> downloadHealthHistoryPdf(String timeRange);
  Future<HealthAlertsModel?> checkHealthAlerts();
}

class HealthRemoteDataSourceImpl implements HealthRemoteDataSource {
  final http.Client client;
  final StorageService storageService;

  HealthRemoteDataSourceImpl({
    required this.client,
    required this.storageService,
  });

  @override
  Future<HealthDataModel> saveHealthData(HealthDataModel healthData) async {
    try {
      // Get token dari storage
      final token = await storageService.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Token tidak ditemukan. Silakan login kembali.',
          statusCode: 401,
        );
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.saveHealthData}');
      
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(healthData.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        
        // Jika response memiliki data field
        if (jsonResponse['data'] != null) {
          return HealthDataModel.fromJson(jsonResponse['data']);
        }
        
        // Jika response langsung berisi data
        return HealthDataModel.fromJson(jsonResponse);
      } else {
        final errorBody = jsonDecode(response.body);
        throw ApiException(
          message: errorBody['message'] ?? 'Gagal menyimpan data kesehatan',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Terjadi kesalahan: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<HealthDataModel?> getHealthData() async {
    try {
      // Get token dari storage
      final token = await storageService.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Token tidak ditemukan. Silakan login kembali.',
          statusCode: 401,
        );
      }

      // Backend selalu return data terbaru (tanpa filter tanggal)
      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getHealthData}');
      
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Response memiliki format: { "status": 200, "message": "...", "data": {...} }
        // Data adalah single object, bukan array
        if (jsonResponse['data'] != null) {
          return HealthDataModel.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        }
        
        return null;
      } else {
        final errorBody = jsonDecode(response.body);
        throw ApiException(
          message: errorBody['message'] ?? 'Gagal mengambil data kesehatan',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Terjadi kesalahan: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<HealthSummaryModel?> getHealthHistory() async {
    try {
      // Get token dari storage
      final token = await storageService.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Token tidak ditemukan. Silakan login kembali.',
          statusCode: 401,
        );
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getHealthHistory}');
      
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Response memiliki format: { "data": { "summary": {...}, "trend_charts": {...}, "reading_history": [...] } }
        if (jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as Map<String, dynamic>;
          final Map<String, dynamic> summaryData = {};
          
          // Parse summary if exists
          if (data['summary'] != null) {
            summaryData.addAll(data['summary'] as Map<String, dynamic>);
          }
          
          // Parse trend_charts if exists
          if (data['trend_charts'] != null) {
            summaryData['trend_charts'] = data['trend_charts'];
          }
          
          // Parse reading_history if exists
          if (data['reading_history'] != null) {
            summaryData['reading_history'] = data['reading_history'];
          }
          
          if (summaryData.isNotEmpty) {
            return HealthSummaryModel.fromJson(summaryData);
          }
        }
        
        return null;
      } else {
        final errorBody = jsonDecode(response.body);
        throw ApiException(
          message: errorBody['message'] ?? 'Gagal mengambil ringkasan statistik',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Terjadi kesalahan: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<int>> downloadHealthHistoryPdf(String timeRange) async {
    try {
      // Get token dari storage
      final token = storageService.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Token tidak ditemukan. Silakan login kembali.',
          statusCode: 401,
        );
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.downloadHealthHistoryPdf}').replace(
        queryParameters: {
          'time_range': timeRange,
        },
      );
      
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/pdf',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        // Try to parse error message if response is JSON
        try {
          final errorBody = jsonDecode(response.body);
          throw ApiException(
            message: errorBody['message'] ?? 'Gagal mengunduh PDF',
            statusCode: response.statusCode,
          );
        } catch (_) {
          throw ApiException(
            message: 'Gagal mengunduh PDF',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Terjadi kesalahan: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<HealthAlertsModel?> checkHealthAlerts() async {
    try {
      // Get token dari storage
      final token = await storageService.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Token tidak ditemukan. Silakan login kembali.',
          statusCode: 401,
        );
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.checkHealthAlerts}');
      
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Response memiliki format: { "status": 200, "message": "...", "data": { "alerts": [...] } }
        if (jsonResponse['data'] != null) {
          return HealthAlertsModel.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        }
        
        return null;
      } else {
        final errorBody = jsonDecode(response.body);
        throw ApiException(
          message: errorBody['message'] ?? 'Gagal memeriksa peringatan kesehatan',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Terjadi kesalahan: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
