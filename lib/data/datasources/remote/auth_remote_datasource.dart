import 'package:periksa_kesehatan/core/network/api_client.dart';
import 'package:periksa_kesehatan/core/network/api_endpoints.dart';
import 'package:periksa_kesehatan/core/network/api_exception.dart';
import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:periksa_kesehatan/data/models/auth/auth_response_model.dart';

/// Remote data source untuk authentication
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.register,
        data: {
          'nama': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Ambil token dari storage
      final token = StorageService.instance.getToken();
      
      // Kirim request logout dengan token di body
      await apiClient.post(
        ApiEndpoints.logout,
        data: {
          'token': token,
        },
      );
    } catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

