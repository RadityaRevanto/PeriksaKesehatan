import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:periksa_kesehatan/domain/entities/user.dart';

/// Local data source untuk authentication (SharedPreferences)
abstract class AuthLocalDataSource {
  Future<void> saveUserData({
    required String token,
    required User user,
  });

  Future<User?> getCurrentUser();

  Future<bool> isLoggedIn();

  Future<void> clearUserData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService storageService;

  AuthLocalDataSourceImpl({required this.storageService});

  @override
  Future<void> saveUserData({
    required String token,
    required User user,
  }) async {
    await storageService.saveUserData(
      token: token,
      userId: user.id,
      email: user.email,
      name: user.name,
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    final userId = storageService.getUserId();
    final email = storageService.getUserEmail();
    final name = storageService.getUserName();

    if (userId != null && email != null && name != null) {
      return User(
        id: userId,
        email: email,
        name: name,
      );
    }

    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return storageService.isLoggedIn();
  }

  @override
  Future<void> clearUserData() async {
    await storageService.clearUserData();
  }
}

