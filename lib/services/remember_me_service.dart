import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola fitur "Remember Me" pada login
class RememberMeService {
  static const String _keyRememberMe = 'remember_me';
  static const String _keyIdentifier = 'saved_identifier';
  static const String _keyPassword = 'saved_password';

  final SharedPreferences _prefs;

  RememberMeService(this._prefs);

  /// Cek apakah user memilih "Remember Me"
  bool isRememberMeEnabled() {
    return _prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Simpan kredensial user
  Future<void> saveCredentials({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    await _prefs.setBool(_keyRememberMe, rememberMe);
    
    if (rememberMe) {
      await _prefs.setString(_keyIdentifier, identifier);
      await _prefs.setString(_keyPassword, password);
    } else {
      // Hapus kredensial jika remember me tidak dicentang
      await clearCredentials();
    }
  }

  /// Ambil identifier yang tersimpan
  String? getSavedIdentifier() {
    if (isRememberMeEnabled()) {
      return _prefs.getString(_keyIdentifier);
    }
    return null;
  }

  /// Ambil password yang tersimpan
  String? getSavedPassword() {
    if (isRememberMeEnabled()) {
      return _prefs.getString(_keyPassword);
    }
    return null;
  }

  /// Hapus semua kredensial yang tersimpan
  Future<void> clearCredentials() async {
    await _prefs.remove(_keyIdentifier);
    await _prefs.remove(_keyPassword);
    await _prefs.setBool(_keyRememberMe, false);
  }

  /// Ambil semua kredensial yang tersimpan
  Map<String, String?> getSavedCredentials() {
    return {
      'identifier': getSavedIdentifier(),
      'password': getSavedPassword(),
    };
  }
}
