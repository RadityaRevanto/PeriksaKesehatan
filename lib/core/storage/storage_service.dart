import 'package:shared_preferences/shared_preferences.dart';
import 'package:periksa_kesehatan/core/storage/storage_keys.dart';

/// Service untuk mengelola SharedPreferences
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  /// Singleton instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Simpan token
  Future<bool> saveToken(String token) async {
    return await _prefs?.setString(StorageKeys.token, token) ?? false;
  }

  /// Ambil token
  String? getToken() {
    return _prefs?.getString(StorageKeys.token);
  }

  /// Simpan user ID
  Future<bool> saveUserId(String userId) async {
    return await _prefs?.setString(StorageKeys.userId, userId) ?? false;
  }

  /// Ambil user ID
  String? getUserId() {
    return _prefs?.getString(StorageKeys.userId);
  }

  /// Simpan user email
  Future<bool> saveUserEmail(String email) async {
    return await _prefs?.setString(StorageKeys.userEmail, email) ?? false;
  }

  /// Ambil user email
  String? getUserEmail() {
    return _prefs?.getString(StorageKeys.userEmail);
  }

  /// Simpan user name
  Future<bool> saveUserName(String name) async {
    return await _prefs?.setString(StorageKeys.userName, name) ?? false;
  }

  /// Ambil user name
  String? getUserName() {
    return _prefs?.getString(StorageKeys.userName);
  }

  /// Set status login
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    return await _prefs?.setBool(StorageKeys.isLoggedIn, isLoggedIn) ?? false;
  }

  /// Cek status login
  bool isLoggedIn() {
    return _prefs?.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  /// Simpan semua data user setelah login
  Future<bool> saveUserData({
    required String token,
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      await Future.wait([
        saveToken(token),
        saveUserId(userId),
        saveUserEmail(email),
        saveUserName(name),
        setLoggedIn(true),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Hapus semua data user (logout)
  Future<bool> clearUserData() async {
    try {
      if (_prefs != null) {
        await Future.wait([
          _prefs!.remove(StorageKeys.token),
          _prefs!.remove(StorageKeys.userId),
          _prefs!.remove(StorageKeys.userEmail),
          _prefs!.remove(StorageKeys.userName),
          _prefs!.remove(StorageKeys.isLoggedIn),
        ]);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Hapus semua data dari SharedPreferences
  Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}

