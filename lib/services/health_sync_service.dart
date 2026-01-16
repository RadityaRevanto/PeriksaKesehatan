import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:periksa_kesehatan/core/database/database_helper.dart';
import 'package:periksa_kesehatan/core/network/api_endpoints.dart';
import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:sqflite/sqflite.dart';

enum SyncStatus { idle, syncing, synced, error }

class HealthSyncService {
  final DatabaseHelper databaseHelper;
  final StorageService storageService;
  final http.Client client;
  
  final _controller = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _controller.stream;
  
  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  HealthSyncService({
    required this.databaseHelper,
    required this.storageService,
    required this.client,
  });

  /// Initialize listener for connectivity changes
  void init() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
       bool hasInternet = await _hasInternetConnection();
       _connectivityController.add(hasInternet);
       if (hasInternet) {
         _checkInternetAndSync();
       }
    });
    
    // Also check immediately on startup
    _checkInitialStatus();
  }
  
  Future<void> _checkInitialStatus() async {
    bool hasInternet = await _hasInternetConnection();
    _connectivityController.add(hasInternet);
    if (hasInternet) {
      _checkInternetAndSync();
    }
  }
  
  Future<void> _checkInternetAndSync() async {
    // Check if there is actual internet connection using native lookup
    bool hasConnection = await _hasInternetConnection();
    if (hasConnection) {
      print("SyncService: Network detected, starting sync process...");
      _controller.add(SyncStatus.syncing);
      
      try {
        await syncPendingRegistrations();
        await syncPendingProfile();
        await syncPendingData();
        
        print("SyncService: Sync process finished.");
      } catch (e) {
        print("SyncService: Unexpected error during sync: $e");
        _controller.add(SyncStatus.error);
      }
    } else {
      print("SyncService: No internet connection detected.");
    }
  }

  Future<void> syncPendingProfile() async {
     final data = await databaseHelper.getUnsyncedPersonalInfo();
     if (data == null) {
       print("SyncService: No pending profile data to sync.");
       return;
     }

     print("SyncService: Found pending profile data: ${data.keys.toList()}");
     
     final token = await storageService.getToken();
     if (token == null) return;

     try {
        final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.updateProfile}');
        
        // Backend expects multipart/form-data, not JSON
        final formData = <String, String>{};
        if (data['name'] != null) formData['name'] = data['name'].toString();
        if (data['birth_date'] != null) formData['birth_date'] = data['birth_date'].toString();
        if (data['phone'] != null) formData['phone'] = data['phone'].toString();
        if (data['address'] != null) formData['address'] = data['address'].toString();
        if (data['weight'] != null) formData['weight'] = data['weight'].toString();
        if (data['height'] != null) formData['height'] = data['height'].toString();
        
        final request = http.MultipartRequest('PUT', url);
        request.headers['Authorization'] = 'Bearer $token';
        request.fields.addAll(formData);
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
           print("SyncService: Profile synced successfully.");
           await databaseHelper.markPersonalInfoSynced(data['user_id']);
        } else {
           print("SyncService: Profile sync failed with status ${response.statusCode}: ${response.body}");
        }
     } catch (e) {
        print("Profile sync error: $e");
     }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // --- Registration Sync ---
  Future<void> syncPendingRegistrations() async {
    final pendingRegs = await databaseHelper.getPendingRegistrations();
    if (pendingRegs.isEmpty) return;
    
    _controller.add(SyncStatus.syncing);

    final db = await databaseHelper.database;

    for (var reg in pendingRegs) {
      try {
        final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.register}');
        final response = await client.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': reg['name'],
            'email': reg['email'],
            'password': reg['password'],
            'password_confirmation': reg['confirm_password'],
          }),
        );
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonResponse = jsonDecode(response.body);
          final data = jsonResponse['data']; // Assuming structure { data: { user: {...}, token: "..." } }

          final userJson = data['user'];
          final newToken = data['token'];
          final newUserId = userJson['id']; // int or string? usually int from Laravel
          
          // Transaction to migrate local temporary user (ID 0) to Real User (ID newUserId)
          await db.transaction((txn) async {
             // 1. Update User Table
             await txn.update(
               'users',
               {
                 'id': newUserId,
                 'token': newToken,
                 'nama': userJson['name'],
                 'email': userJson['email'],
               },
               where: 'token = ?',
               whereArgs: ['OFFLINE_TOKEN'],
             );

             // 2. Update Foreign Keys in other tables
             final tables = ['personal_infos', 'health_data', 'health_alerts'];
             for (var table in tables) {
               await txn.update(
                 table,
                 {'user_id': newUserId},
                 where: 'user_id = ?',
                 whereArgs: [0], // Assuming 0 was the temp ID
               );
             }
             
             // 3. Delete pending request
             await txn.delete('pending_registrations', where: 'id = ?', whereArgs: [reg['id']]);
          });
          
          // 4. Update Secure Storage so future app restarts use valid token
          await storageService.saveToken(newToken);
          await storageService.saveUserId(newUserId.toString());
          await storageService.saveUserName(userJson['name']);
          await storageService.saveUserEmail(userJson['email']);
          await storageService.setLoggedIn(true);
          
          print("Successfully synced registration for ${reg['email']}");
        } else {
             // 409 Conflict, 422 Validation
             if (response.statusCode == 409 || response.statusCode == 422) {
                await db.delete('pending_registrations', where: 'id = ?', whereArgs: [reg['id']]);
             }
        }
      } catch (e) {
        print("Registration sync error: $e");
      }
    }
  }

  /// Sync pending data from local SQLite to Server
  Future<void> syncPendingData() async {
    final pendingData = await databaseHelper.getUnsyncedHealthData();
    if (pendingData.isEmpty) return;

    _controller.add(SyncStatus.syncing);

    final token = await storageService.getToken();
    if (token == null) {
      print("SyncService: Cannot sync data - token is null");
      return;
    }

    int successCount = 0;
    bool has401Error = false;

    for (var row in pendingData) {
      if (has401Error) break;

      try {
        // Construct Request Body
        // PENTING: Sertakan record_date dari lokal
        final body = {
           if (row['systolic'] != null) 'systolic': row['systolic'],
           if (row['diastolic'] != null) 'diastolic': row['diastolic'],
           if (row['blood_sugar'] != null) 'blood_sugar': row['blood_sugar'],
           if (row['weight'] != null) 'weight': row['weight'],
           if (row['heart_rate'] != null) 'heart_rate': row['heart_rate'],
           if (row['activity'] != null) 'activity': row['activity'],
           if (row['height_cm'] != null) 'height': row['height_cm'], 
           'record_date': row['record_date'], // Format YYYY-MM-DD from SQLite
        };
        
        final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.saveHealthData}');
        
        final response = await client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
           await databaseHelper.markHealthDataSynced(row['id']);
           successCount++;
        } else if (response.statusCode == 401) {
           // Token expired -> Stop sync
           has401Error = true;
        } else {
           // Other error -> Skip and keep is_synced = 0
           print("Sync failed for id ${row['id']}: ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("Sync exception for id ${row['id']}: $e");
      }
    }
    
    if (has401Error) {
      print("SyncService: Sync aborted due to 401 Unauthorized.");
      _controller.add(SyncStatus.error);
    } else if (successCount > 0) {
      print("SyncService: Successfully synced $successCount health data records.");
      _controller.add(SyncStatus.synced);
      // Back to idle after showing synced status
      Future.delayed(const Duration(seconds: 4), () {
        _controller.add(SyncStatus.idle);
      });
    } else {
      print("SyncService: No new health data records synced.");
      _controller.add(SyncStatus.idle);
    }
  }
}
