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

  Future<void> savePendingRegistration(Map<String, dynamic> data);
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
    // 1. Simpan Token & Status Login di SharedPreferences
    await storageService.saveToken(token);
    await storageService.setLoggedIn(true);
    
    // 2. Simpan Data User Lengkap di SQLite
    final db = await databaseHelper.database;
    final userId = int.tryParse(user.id) ?? 0;

    await db.transaction((txn) async {
       // Table: users
       // Note: username, notification_enabled, language defaults if missing
       await txn.insert(
        'users',
        {
          'id': userId,
          'nama': user.name,
          'username': user.name.toLowerCase().replaceAll(' ', ''),
          'email': user.email,
          'token': token, 
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Table: personal_infos
      // Check validation: user only provides basic info on auth response usually.
      // We upsert what we have.
      // If data exists, we probably don't want to overwrite specific fields like address if they are null in 'user' object?
      // But 'User' entity is simple. For detailed profile, PersonalInfoRepository handles it.
      // Here we set the basics so Profile Page has something to show offline immediately.
      // We use INSERT OR IGNORE or just standard Insert-Replace for shared fields.
      // Let's use Query first to preserve existing fields if any? 
      // Simplified: Just upsert known fields.
      
      // Check if row exists
      final existingInfo = await txn.query('personal_infos', where: 'user_id = ?', whereArgs: [userId]);
      
      if (existingInfo.isNotEmpty) {
          await txn.update(
            'personal_infos',
            {
               'name': user.name,
               if (user.phone != null) 'phone': user.phone,
               if (user.avatar != null) 'photo_url': user.avatar,
            },
            where: 'user_id = ?',
            whereArgs: [userId],
          );
      } else {
          await txn.insert(
            'personal_infos',
            {
              'user_id': userId,
              'name': user.name,
              'phone': user.phone,
              'photo_url': user.avatar,
              // defaults
              'birth_date': '',
              'address': '',
            },
            conflictAlgorithm: ConflictAlgorithm.replace, 
          );
      }
    });
  }

  @override
  Future<User?> getCurrentUser() async {
    // Coba ambil dari SQLite dulu
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty) {
      final userRow = maps.first;
      
      // Optionally join/fetch personal_infos for phone/avatar
      final userId = userRow['id'];
      final infoMaps = await db.query('personal_infos', where: 'user_id = ?', whereArgs: [userId]);
      String? phone;
      String? avatar;
      
      if (infoMaps.isNotEmpty) {
         phone = infoMaps.first['phone'] as String?;
         avatar = infoMaps.first['photo_url'] as String?;
      }

      return User(
        id: userRow['id'].toString(),
        email: userRow['email'],
        name: userRow['nama'],
        phone: phone,
        avatar: avatar,
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
    await db.transaction((txn) async {
       print('LOGOUT: Clearing all user data from local database...');
       await txn.delete('health_alerts');
       await txn.delete('health_data'); // PENTING: Hapus data kesehatan agar tidak tercampur
       await txn.delete('personal_infos');
       await txn.delete('educational_videos'); // Hapus cache video edukasi
       await txn.delete('users');
       print('LOGOUT: All user data cleared successfully.');
       // Note: Pending registrations are usually kept until synced? 
       // If user logs out, we should clear pending registrations to avoid syncing another user's data?
       // But pending registration implies NO user is logged in yet.
       // So logout only happens if we ARE logged in.
       // Safe to clear or keep? Let's keep pending_registrations.
    });
  }

  @override
  Future<void> savePendingRegistration(Map<String, dynamic> data) async {
    await databaseHelper.insertPendingRegistration(data);
  }
}

