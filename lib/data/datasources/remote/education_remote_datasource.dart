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
          List<EducationCategoryModel> categories = dataList
              .map((category) => EducationCategoryModel.fromJson(category as Map<String, dynamic>))
              .toList();
          
          // INJECT: Local Categories & Videos
          final localCategories = [
             EducationCategoryModel(
              id: 991,
              kategori: 'Diabetes',
              videos: [],
            ),
             EducationCategoryModel(
              id: 992,
              kategori: 'Hipertensi',
              videos: [
                  VideoModel(
                    title: 'Cara Membaca Hasil Pemeriksaan Tekanan Darah?',
                    url: 'assets/videos/videoplayback.mp4',
                    duration: '0:30',
                    thumbnailUrl: 'assets/images/blood_pressure_thumb.png',
                  )
              ],
            ),
             EducationCategoryModel(
              id: 993,
              kategori: 'Jantung',
              videos: [
                  VideoModel(
                    title: '7 Tanda Jantung Anda Bermasalah',
                    url: 'assets/videos/jantung.mp4',
                    duration: '06:36',
                    thumbnailUrl: 'assets/images/heart_signs_thumb.png',
                  )
              ],
            ),
             EducationCategoryModel(
              id: 994,
              kategori: 'Berat Badan',
              videos: [],
            ),
          ];

          categories.insertAll(0, localCategories);

          // Deduplicate based on category name
          final uniqueCategories = <String, EducationCategoryModel>{};
          for (var category in categories) {
             // If we already saw this category name, we might want to keep the one with videos (our local one probably has videos for now, or the remote one).
             // Strategy: First come first serve (Local is inserted at 0, so it takes precedence). 
             // OR: Merge duplicate keys?
             // Since the user is complaining about duplicates, let's just keep the FIRST occurrence.
             if (!uniqueCategories.containsKey(category.kategori)) {
               uniqueCategories[category.kategori] = category;
             } else {
                // If it exists, maybe we want to add videos from the duplicate to the existing one?
                // For now, simple deduplication to fix the "kedouble" visual issue.
             }
          }
          
          return uniqueCategories.values.toList();
          

        }
        
        // Return at least the local video if API is empty
         return [
             EducationCategoryModel(
              id: 991,
              kategori: 'Diabetes',
              videos: [],
            ),
             EducationCategoryModel(
              id: 992,
              kategori: 'Hipertensi',
              videos: [
                  VideoModel(
                    title: 'Cara Membaca Hasil Pemeriksaan Tekanan Darah?',
                    url: 'assets/videos/videoplayback.mp4',
                    duration: '04:46',
                    thumbnailUrl: 'assets/images/blood_pressure_thumb.png',
                  )
              ],
            ),
             EducationCategoryModel(
              id: 993,
              kategori: 'Jantung',
              videos: [
                  VideoModel(
                    title: '7 Tanda Jantung Anda Bermasalah',
                    url: 'assets/videos/jantung.mp4',
                    duration: '06:36',
                    thumbnailUrl: 'assets/images/heart_signs_thumb.png',
                  )
              ],
            ),
             EducationCategoryModel(
              id: 994,
              kategori: 'Berat Badan',
              videos: [],
            ),
         ];
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
