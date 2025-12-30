import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:periksa_kesehatan/core/network/api_endpoints.dart';
import 'package:periksa_kesehatan/core/network/api_exception.dart';
import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:periksa_kesehatan/data/models/education/education_model.dart';

/// Remote data source untuk education data
abstract class EducationRemoteDataSource {
  Future<List<EducationCategoryModel>> getEducationalVideos();
  Future<EducationCategoryModel> getEducationalVideosByCategory(int categoryId);
}

class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  final http.Client client;
  final StorageService storageService;

  EducationRemoteDataSourceImpl({
    required this.client,
    required this.storageService,
  });

  @override
  Future<List<EducationCategoryModel>> getEducationalVideos() async {
    try {
      // Get token dari storage
      final token = storageService.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Token tidak ditemukan. Silakan login kembali.',
          statusCode: 401,
        );
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.educationVideos}');
      
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Response memiliki format: { "data": [...] }
        if (jsonResponse['data'] != null) {
          final List<dynamic> dataList = jsonResponse['data'] as List<dynamic>;
          return dataList
              .map((category) => EducationCategoryModel.fromJson(category as Map<String, dynamic>))
              .toList();
        }
        
        return [];
      } else {
        final errorBody = jsonDecode(response.body);
        throw ApiException(
          message: errorBody['message'] ?? 'Gagal mengambil data video edukasi',
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
  Future<EducationCategoryModel> getEducationalVideosByCategory(int categoryId) async {
    try {
      // Get token dari storage
      final token = storageService.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Token tidak ditemukan. Silakan login kembali.',
          statusCode: 401,
        );
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.educationVideosByCategory}/$categoryId');
      
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Response langsung berisi data kategori
        return EducationCategoryModel.fromJson(jsonResponse as Map<String, dynamic>);
      } else {
        final errorBody = jsonDecode(response.body);
        throw ApiException(
          message: errorBody['message'] ?? 'Gagal mengambil data video edukasi',
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
