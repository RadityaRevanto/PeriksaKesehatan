import 'dart:io';
import 'package:periksa_kesehatan/core/network/api_client.dart';
import 'package:periksa_kesehatan/data/models/profile/personal_info_model.dart';
import 'package:dio/dio.dart';

class PersonalInfoRemoteDatasource {
  final ApiClient apiClient;

  PersonalInfoRemoteDatasource(this.apiClient);

  Future<PersonalInfoModel?> getPersonalInfo(String token) async {
    try {
      final response = await apiClient.get(
        '/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          return PersonalInfoModel.fromJson(data);
        }
        return null;
      }
      throw Exception('Failed to load personal info');
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalInfoModel> updatePersonalInfo(
    String token,
    PersonalInfoModel personalInfo, {
    File? imageFile,
  }) async {
    try {
      final map = personalInfo.toJson();
      // Remove photo_url to avoid validation error
      map.remove('photo_url');
      
      // If image is provided, add as MultipartFile
      if (imageFile != null) {
        map['photo'] = await MultipartFile.fromFile(imageFile.path);
      }

      final response = await apiClient.put(
        '/profile',
        data: FormData.fromMap(map),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PersonalInfoModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to update personal info');
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalInfoModel> createPersonalInfo(
    String token,
    PersonalInfoModel personalInfo, {
    File? imageFile,
  }) async {
    try {
      // Gunakan toJsonForCreate() untuk memastikan name dan birth_date selalu ada
      final map = personalInfo.toJsonForCreate();
      // Remove photo_url to avoid validation error
      map.remove('photo_url');
      
      // If image is provided, add as MultipartFile
      if (imageFile != null) {
        map['photo'] = await MultipartFile.fromFile(imageFile.path);
      }

      final response = await apiClient.put(
        '/profile',
        data: FormData.fromMap(map),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return PersonalInfoModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create personal info');
    } catch (e) {
      rethrow;
    }
  }
}
