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
    PersonalInfoModel personalInfo,
  ) async {
    try {
      final response = await apiClient.put(
        '/profile',
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
    } on DioException catch (e) {
      // Jika 404 (profil belum ada), throw exception dengan message khusus
      if (e.response?.statusCode == 404) {
        throw Exception('Profile not found, need to create first');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalInfoModel> createPersonalInfo(
    String token,
    PersonalInfoModel personalInfo,
  ) async {
    try {
      // Gunakan toJsonForCreate() untuk memastikan name dan birth_date selalu ada
      final response = await apiClient.post(
        '/profile',
        data: personalInfo.toJsonForCreate(),
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
    } on DioException catch (e) {
      // Jika 409 (conflict) atau 400 dengan message profil sudah ada, throw exception khusus
      if (e.response?.statusCode == 409 || 
          (e.response?.statusCode == 400 && 
           (e.response?.data?['message']?.toString().toLowerCase().contains('sudah ada') == true ||
            e.response?.data?['message']?.toString().toLowerCase().contains('already exists') == true))) {
        throw Exception('Profile already exists');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
