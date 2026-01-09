import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:periksa_kesehatan/domain/entities/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:periksa_kesehatan/core/database/database_helper.dart';

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
  final DatabaseHelper databaseHelper;

  AuthLocalDataSourceImpl({
    required this.storageService, 
    required this.databaseHelper,
  });

  @override
  Future<void> saveUserData({
    required String token,
    required User user,
  }) async {
    // 1. Simpan Token & Status Login di SharedPreferences (Cepat & Ringan)
    await storageService.saveToken(token);
    await storageService.setLoggedIn(true);
    
    // 2. Simpan Data User Lengkap di SQLite (Structured Data)
    final db = await databaseHelper.database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'token': token, // Optional: Backup token di DB
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    // Coba ambil dari SQLite dulu (Lebih lengkap & robust)
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty) {
      return User(
        id: maps.first['id'],
        email: maps.first['email'],
        name: maps.first['name'],
      );
    }

    // Fallback ke SharedPreferences jika SQLite kosong
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
    
    // Hapus data user di SQLite juga
    final db = await databaseHelper.database;
    await db.delete('users');
  }
}

