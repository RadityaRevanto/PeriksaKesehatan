import 'dart:async';
import 'dart:io';
import 'package:periksa_kesehatan/core/database/database_helper.dart';
import 'package:periksa_kesehatan/data/datasources/remote/personal_info_remote_datasource.dart';
import 'package:periksa_kesehatan/data/models/profile/personal_info_model.dart';
import 'package:sqflite/sqflite.dart';

class PersonalInfoRepository {
  final PersonalInfoRemoteDatasource remoteDatasource;
  final DatabaseHelper databaseHelper;

  PersonalInfoRepository({
    required this.remoteDatasource,
    required this.databaseHelper,
  });

  Future<PersonalInfoModel?> getPersonalInfo(String token) async {
    // OPTIMIZATION: Local-first strategy for faster UI
    // 1. Get cached data first (instant)
    final cachedData = await _getFromLocal();
    
    // 2. Try to fetch fresh data from server in background
    try {
      final response = await remoteDatasource.getPersonalInfo(token)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('PersonalInfo API timeout - using cached data');
              return null;
            },
          );
      
      if (response != null) {
        await _saveToLocal(response, isSynced: true);
        return response; // Return fresh data if available
      }
    } catch (e) {
      print('PersonalInfo fetch error: $e - using cached data');
    }
    
    // 3. Return cached data (either from step 1 or if server failed)
    return cachedData;
  }

  Future<PersonalInfoModel> updatePersonalInfo(
    String token,
    PersonalInfoModel personalInfo, {
    File? imageFile,
  }) async {
    try {
      final response = await remoteDatasource.updatePersonalInfo(token, personalInfo, imageFile: imageFile);
      await _saveToLocal(response, isSynced: true);
      return response;
    } catch (e) {
      // Offline Save
      await _saveToLocal(personalInfo, isSynced: false);
      return personalInfo;
    }
  }

  Future<PersonalInfoModel> createPersonalInfo(
    String token,
    PersonalInfoModel personalInfo, {
    File? imageFile,
  }) async {
    try {
      final response = await remoteDatasource.createPersonalInfo(token, personalInfo, imageFile: imageFile);
      await _saveToLocal(response, isSynced: true);
      return response;
    } catch (e) {
      // Offline Save
      await _saveToLocal(personalInfo, isSynced: false);
      return personalInfo;
    }
  }

  Future<void> _saveToLocal(PersonalInfoModel data, {bool isSynced = true}) async {
    final db = await databaseHelper.database;
    // We assume we know the user_id. PersonalInfoModel might not have user_id, but it has name/phone etc.
    // Wait, PersonalInfoModel usually maps to response. Does it have ID?
    // Let's assume we can get user_id from somewhere or it is attached.
    // Actually, PersonalInfoModel is just profile data.
    // We need user_id to insert into personal_infos table which has foreign keys.
    // Or we update based on something else?
    // Actually, normally getPersonalInfo returns data linked to content based on token.
    // But to save locally:
    // If PersonalInfoModel doesn't have user_id, we might have an issue linking it to 'users' table if we don't know who is logged in.
    // BUT AuthRepository session keeps track of who is logged in.
    // Maybe we just query the only user we have? Or we need user_id injected. 
    // Let's check `users` table for the current logged-in user (token exists).
    
    final List<Map<String, dynamic>> users = await db.query('users', limit: 1); 
    if (users.isEmpty) return; // No user logged in locally?
    final userId = users.first['id'];

    await db.insert(
      'personal_infos',
      {
        'user_id': userId,
        'name': data.name,
        'birth_date': data.birthDate,
        'phone': data.phone,
        'address': data.address,
        'photo_url': data.photoUrl,
        'weight': data.weight,
        'height': data.height,
        'is_synced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PersonalInfoModel?> _getFromLocal() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> users = await db.query('users', limit: 1);
    if (users.isEmpty) return null;
    final userId = users.first['id'];

    final List<Map<String, dynamic>> maps = await db.query(
      'personal_infos',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Fetch latest height/weight from health_data as fallback
    double? latestWeight;
    double? latestHeight;
    final healthDocs = await db.query('health_data', orderBy: 'record_date DESC', limit: 1);
    if (healthDocs.isNotEmpty) {
      latestWeight = healthDocs.first['weight'] != null ? (healthDocs.first['weight'] as num).toDouble() : null;
      latestHeight = healthDocs.first['height_cm'] != null ? (healthDocs.first['height_cm'] as num).toDouble() : null;
    }

    if (maps.isNotEmpty) {
      final row = maps.first;
      int? age;
      if (row['birth_date'] != null && row['birth_date'].toString().isNotEmpty) {
        try {
          final birthDate = DateTime.parse(row['birth_date']);
          final today = DateTime.now();
          age = today.year - birthDate.year;
          if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
            age--;
          }
        } catch (_) {}
      }

      return PersonalInfoModel(
        name: row['name'],
        birthDate: row['birth_date'],
        phone: row['phone'],
        address: row['address'],
        photoUrl: row['photo_url'],
        age: age, 
        weight: row['weight'] ?? latestWeight, 
        height: row['height'] ?? latestHeight,
      );
    }

    
    // Fallback: Use basic user info from 'users' table if detailed profile not found
    final userRow = users.first;
    return PersonalInfoModel(
      name: userRow['nama'],
      birthDate: null,
      phone: null,
      address: null,
      photoUrl: null,
      age: null,
      weight: latestWeight,
      height: latestHeight,
    );
  }
}
