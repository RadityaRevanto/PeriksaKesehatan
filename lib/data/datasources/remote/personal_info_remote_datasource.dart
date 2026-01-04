import 'package:periksa_kesehatan/core/network/api_client.dart';
import 'package:periksa_kesehatan/data/models/profile/personal_info_model.dart';
import 'package:dio/dio.dart';

class PersonalInfoRemoteDatasource {
  final ApiClient apiClient;

  PersonalInfoRemoteDatasource(this.apiClient);

  Future<PersonalInfoModel?> getPersonalInfo(String token) async {
    try {
      final response = await apiClient.get(
        '/profile/personal-info',
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
    PersonalInfoModel personalInfo,
  ) async {
    try {
      final response = await apiClient.put(
        '/profile/personal-info',
        data: personalInfo.toJson(),
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
    PersonalInfoModel personalInfo,
  ) async {
    try {
      final response = await apiClient.post(
        '/profile/personal-info',
        data: personalInfo.toJson(),
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
