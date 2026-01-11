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
  Future<HealthSummaryModel?> getHealthHistory({String timeRange = '7Days'});
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
        print('REMOTE ERROR: ${response.statusCode}');
        print('REMOTE BODY: ${response.body}');
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
  Future<HealthSummaryModel?> getHealthHistory({String timeRange = '7Days'}) async {
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
        
        // Response memiliki format: { "data": { "summary": { "7Days": {...}, "1Month": {...}, "3Months": {...} }, "trend_charts": { "blood_pressure": { "7Days": [...], ... } }, "reading_history": { "7Days": [...], "1Month": { "records": [...] }, "3Months": { "records": [...] } } } }
        if (jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as Map<String, dynamic>;
          final Map<String, dynamic> summaryData = {};
          
          // Parse summary - extract from selected time range key
          if (data['summary'] != null) {
            final summary = data['summary'] as Map<String, dynamic>;
            // Extract data from the selected time range key
            if (summary[timeRange] != null) {
              summaryData.addAll(summary[timeRange] as Map<String, dynamic>);
            }
          }
          
          // Parse trend_charts - extract selected time range arrays from each metric
          if (data['trend_charts'] != null) {
            final trendCharts = data['trend_charts'] as Map<String, dynamic>;
            final Map<String, dynamic> extractedTrends = {};
            
            // For each metric (blood_pressure, blood_sugar, weight, activity)
            trendCharts.forEach((key, value) {
              if (value is Map<String, dynamic> && value[timeRange] != null) {
                // Extract the selected time range array for this metric
                extractedTrends[key] = value[timeRange];
              }
            });
            
            if (extractedTrends.isNotEmpty) {
              summaryData['trend_charts'] = extractedTrends;
            }
          }
          
          // Parse reading_history - extract from selected time range key
          if (data['reading_history'] != null) {
            final readingHistory = data['reading_history'] as Map<String, dynamic>;
            // Extract data from the selected time range key
            if (readingHistory[timeRange] != null) {
              // For 7Days, it's a direct array
              // For 1Month and 3Months, it's an object with 'records' array
              final timeRangeData = readingHistory[timeRange];
              if (timeRangeData is List) {
                summaryData['reading_history'] = timeRangeData;
              } else if (timeRangeData is Map<String, dynamic> && timeRangeData['records'] != null) {
                summaryData['reading_history'] = timeRangeData['records'];
              }
            }
          }
          
          if (summaryData.isNotEmpty) {
            return HealthSummaryModel.fromJson(summaryData);
          }
          
          // Return null if no data (e.g., for new users)
          // This allows UI to show empty state gracefully
          return null;
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

  /// Helper method to get readable time range label
  String _getTimeRangeLabel(String timeRange) {
    switch (timeRange) {
      case '7Days':
        return '7 hari terakhir';
      case '30Days':
      case '1Month':
        return '30 hari terakhir';
      case '90Days':
      case '3Months':
        return '3 bulan terakhir';
      default:
        return timeRange;
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
