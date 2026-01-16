import 'package:dartz/dartz.dart';
import 'package:periksa_kesehatan/core/database/database_helper.dart';
import 'package:periksa_kesehatan/data/datasources/local/auth_local_datasource.dart';
import 'package:periksa_kesehatan/core/network/api_exception.dart';
import 'package:periksa_kesehatan/data/datasources/remote/health_remote_datasource.dart';
import 'package:periksa_kesehatan/data/models/health/health_data_model.dart';
import 'package:periksa_kesehatan/data/models/health/health_summary_model.dart';
import 'package:periksa_kesehatan/data/models/health/health_alert_model.dart';
import 'package:periksa_kesehatan/domain/entities/failure.dart';
import 'package:periksa_kesehatan/domain/entities/health_data.dart';
import 'package:periksa_kesehatan/domain/entities/health_alert.dart';

/// Repository untuk health data
abstract class HealthRepository {
  Future<Either<Failure, HealthData>> saveHealthData(HealthData healthData);
  Future<Either<Failure, HealthData?>> getHealthData();
  Future<Either<Failure, HealthSummaryModel?>> getHealthHistory({String timeRange = '7Days'});
  Future<Either<Failure, List<int>>> downloadHealthHistoryPdf(String timeRange);
  Future<Either<Failure, HealthAlertsModel?>> checkHealthAlerts();
}



class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final DatabaseHelper databaseHelper;

  HealthRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
    required this.databaseHelper,
  });

  @override
  Future<Either<Failure, HealthData>> saveHealthData(HealthData healthData) async {
    final healthDataModel = HealthDataModel.fromEntity(healthData);
    final user = await authLocalDataSource.getCurrentUser();
    final userId = user != null ? int.tryParse(user.id) : null; 

    // DEBUG: Log the dates
    print('🔍 SAVE HEALTH DEBUG:');
    print('   Entity date: ${healthData.date}');
    print('   Model recordDate: ${healthDataModel.recordDate}');
    print('   JSON payload: ${healthDataModel.toJson()}');

    // LOCAL-FIRST APPROACH:
    // 1. ALWAYS save to local database first
    print('SAVE HEALTH: Saving to local database first (Local-First approach)...');
    try {
      await _saveToLocal(healthDataModel, userId, false); // is_synced = 0
      print('SAVE HEALTH: Successfully saved to local DB for date: ${healthData.date}');
    } catch (localError) {
      print('SAVE HEALTH: Failed to save to local DB: $localError');
      return Left(CacheFailure(localError.toString()));
    }

    // 2. Try to sync to server in background
    try {
      print('SAVE HEALTH: Attempting to sync to server...');
      final response = await remoteDataSource.saveHealthData(healthDataModel);
      final savedEntity = response.toEntity();
      
      // 3. Update local record to mark as synced
      print('SAVE HEALTH: Server sync success! Updating local record to is_synced=1');
      await _saveToLocal(HealthDataModel.fromEntity(savedEntity), userId, true);
      
      return Right(savedEntity);
    } catch (e) {
      // Server sync failed, but data is already saved locally
      print('SAVE HEALTH: Server sync failed ($e), but data is safe in local DB');
      return Right(healthData); // Return success because local save succeeded
    }
  }

  Future<void> _saveToLocal(HealthDataModel data, int? userId, bool isSynced) async {
    // CRITICAL: Use recordDate if available (this is the date the user selected)
    // Fallback to createdAt (server timestamp) or DateTime.now()
    final DateTime dateToUse = data.recordDate ?? data.createdAt ?? DateTime.now();
    
    // Format as YYYY-MM-DD for uniqueness per day
    // Use local date components to avoid timezone conversion issues
    final dateStr = '${dateToUse.year.toString().padLeft(4, '0')}-${dateToUse.month.toString().padLeft(2, '0')}-${dateToUse.day.toString().padLeft(2, '0')}';
    
    print('_saveToLocal: Saving data for date: $dateStr, is_synced: $isSynced');
    
    final db = await databaseHelper.database;
    
    // 1. Ambil data yang sudah ada untuk tanggal tersebut
    final List<Map<String, dynamic>> existing = await db.query(
      'health_data',
      where: 'record_date = ?',
      whereArgs: [dateStr],
    );

    Map<String, dynamic> row;
    
    if (existing.isNotEmpty) {
      // 2. Jika ada, gabungkan (Merge)
      print('_saveToLocal: Merging with existing data for $dateStr');
      final oldData = existing.first;
      row = {
        'id': oldData['id'], // Gunakan ID yang sama agar replace bekerja dengan benar
        'user_id': userId ?? oldData['user_id'],
        'systolic': data.systolic ?? oldData['systolic'],
        'diastolic': data.diastolic ?? oldData['diastolic'],
        'blood_sugar': data.bloodSugar ?? oldData['blood_sugar'],
        'weight': data.weight ?? oldData['weight'],
        'height_cm': data.height?.round() ?? oldData['height_cm'],
        'heart_rate': data.heartRate ?? oldData['heart_rate'],
        'activity': data.activity ?? oldData['activity'],
        'record_date': dateStr,
        'is_synced': isSynced ? 1 : 0,
      };
    } else {
      // 3. Jika baru, buat row baru
      print('_saveToLocal: Creating new record for $dateStr');
      row = {
        'user_id': userId,
        'systolic': data.systolic,
        'diastolic': data.diastolic,
        'blood_sugar': data.bloodSugar,
        'weight': data.weight,
        'height_cm': data.height?.round(),
        'heart_rate': data.heartRate,
        'activity': data.activity,
        'record_date': dateStr, 
        'is_synced': isSynced ? 1 : 0,
      };
    }
    
    await databaseHelper.insertHealthData(row);
    print('_saveToLocal: Successfully saved to local DB for $dateStr');
  }

  @override
  Future<Either<Failure, HealthData?>> getHealthData() async {
    try {
      // Get from remote
      final response = await remoteDataSource.getHealthData();
      
      // Cache logic
      if (response != null) {
        print('🔍 GET HEALTH DATA - Server Response:');
        print('   Response recordDate: ${response.recordDate}');
        print('   Response createdAt: ${response.createdAt}');
        
        final user = await authLocalDataSource.getCurrentUser();
        final userId = user != null ? int.tryParse(user.id) : null;
        // Save to local as synced
        await _saveToLocal(response, userId, true);
        
        final entity = response.toEntity();
        print('   Entity date: ${entity.date}');
        
        return Right(entity);
      }
      
      // If server returns null, try to get from local
      print('GET HEALTH DATA: Server returned null, checking local data...');
      final localData = await databaseHelper.getHealthDataHistory();
      if (localData.isNotEmpty) {
        // Get the latest record (first item, sorted by date DESC)
        final row = localData.first;
        final dateStr = row['record_date'] as String;
        // Parse date parts to avoid timezone issues
        final dateParts = dateStr.split('-');
        final recordDate = DateTime(
          int.parse(dateParts[0]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[2]), // day
          12, // Set to noon to avoid timezone edge cases
        );
        
        final healthData = HealthData(
          date: recordDate,
          systolic: row['systolic'],
          diastolic: row['diastolic'],
          bloodSugar: row['blood_sugar'],
          weight: row['weight'],
          height: row['height_cm'] != null ? (row['height_cm'] as int).toDouble() : null,
          activity: row['activity'],
          heartRate: row['heart_rate'],
        );
        print('GET HEALTH DATA: Returning local data for date: ${row['record_date']}');
        return Right(healthData);
      }
      
      return const Right(null);
    } catch (e) {
      print('GET HEALTH DATA: Server error ($e), falling back to local data...');
      // Fallback Local
      try {
        final localData = await databaseHelper.getHealthDataHistory();
        if (localData.isNotEmpty) {
           // We assume the first (latest by record_date DESC) is the latest data
           final row = localData.first;
           final dateStr = row['record_date'] as String;
           // Parse date parts to avoid timezone issues
           final dateParts = dateStr.split('-');
           final recordDate = DateTime(
             int.parse(dateParts[0]), // year
             int.parse(dateParts[1]), // month
             int.parse(dateParts[2]), // day
             12, // Set to noon to avoid timezone edge cases
           );
           
           final healthData = HealthData(
             date: recordDate,
             systolic: row['systolic'],
             diastolic: row['diastolic'],
             bloodSugar: row['blood_sugar'],
             weight: row['weight'],
             height: row['height_cm'] != null ? (row['height_cm'] as int).toDouble() : null,
             activity: row['activity'],
             heartRate: row['heart_rate'],
           );
           print('GET HEALTH DATA: Returning local data for date: ${row['record_date']}');
           return Right(healthData);
        }
        return const Right(null);
      } catch (localError) {
        return Left(CacheFailure(localError.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, HealthSummaryModel?>> getHealthHistory({String timeRange = '7Days'}) async {
    try {
      final response = await remoteDataSource.getHealthHistory(timeRange: timeRange);
      
      if (response != null) {
        await _cacheHistory(response);
        
        // Background sync: Upload any unsynced local data to server
        // This runs asynchronously without blocking the response
        syncUnsyncedData().then((_) {
          print('SYNC: Background sync completed');
        }).catchError((error) {
          print('SYNC: Background sync failed: $error');
        });
        
        // Merge server data with local unsynced data
        final localData = await databaseHelper.getHealthDataHistory();
        final unsyncedData = localData.where((row) => row['is_synced'] == 0).toList();
        
        if (unsyncedData.isNotEmpty && response.readingHistory != null) {
          // Convert unsynced local data to ReadingHistory format
          final List<ReadingHistory> additionalHistory = [];
          
          for (var row in unsyncedData) {
            final date = row['record_date'] as String;
            // Parse date parts to avoid timezone issues
            final dateParts = date.split('-');
            final dateTime = DateTime(
              int.parse(dateParts[0]), // year
              int.parse(dateParts[1]), // month
              int.parse(dateParts[2]), // day
              12, // Set to noon to avoid timezone edge cases
            );
            
            // Add blood pressure if exists
            if (row['systolic'] != null && row['diastolic'] != null) {
              additionalHistory.add(ReadingHistory(
                id: row['id'] as int,
                dateTime: dateTime,
                metricType: 'tekanan_darah',
                value: '${row['systolic']}/${row['diastolic']} mmHg',
                status: 'Normal',
              ));
            }
            
            // Add blood sugar if exists
            if (row['blood_sugar'] != null) {
              additionalHistory.add(ReadingHistory(
                id: row['id'] as int,
                dateTime: dateTime,
                metricType: 'gula_darah',
                value: '${row['blood_sugar']} mg/dL',
                status: 'Normal',
              ));
            }
            
            // Add weight if exists
            if (row['weight'] != null) {
              additionalHistory.add(ReadingHistory(
                id: row['id'] as int,
                dateTime: dateTime,
                metricType: 'berat_badan',
                value: '${row['weight']} kg',
                status: 'Normal',
              ));
            }
          }
          
          // Merge and sort by date (newest first)
          final mergedHistory = [...response.readingHistory!, ...additionalHistory];
          mergedHistory.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          
          // Create new response with merged data
          return Right(HealthSummaryModel(
            bloodPressure: response.bloodPressure,
            bloodSugar: response.bloodSugar,
            weight: response.weight,
            trendCharts: response.trendCharts,
            readingHistory: mergedHistory,
            latestHeight: response.latestHeight,
          ));
        }
      }
      
      return Right(response);
    } catch (e) {
      // Offline Fallback
      try {
        final localData = await databaseHelper.getHealthDataHistory();
        if (localData.isEmpty) return const Right(null);

        // 1. Filter by Time Range
        DateTime cutoff;
        final now = DateTime.now();
        if (timeRange == '30Days') {
          cutoff = now.subtract(const Duration(days: 30));
        } else if (timeRange == '3Months') {
          cutoff = now.subtract(const Duration(days: 90));
        } else {
          cutoff = now.subtract(const Duration(days: 7));
        }

        final filteredData = localData.where((row) {
          try {
            final date = DateTime.parse(row['record_date']);
            // Include dates that are on or after the cutoff date
            final include = date.isAfter(cutoff) || date.isAtSameMomentAs(cutoff) || 
                   date.year == cutoff.year && date.month == cutoff.month && date.day == cutoff.day;
            return include;
          } catch (_) { return false; }
        }).toList();

        print('OFFLINE HISTORY: Total local records: ${localData.length}');
        print('OFFLINE HISTORY: Filtered records: ${filteredData.length}');
        print('OFFLINE HISTORY: Cutoff date: ${cutoff.toIso8601String().split('T')[0]}');
        for (var row in filteredData) {
          print('OFFLINE HISTORY: Date: ${row['record_date']}, Synced: ${row['is_synced']}');
        }

        if (filteredData.isEmpty) return const Right(null);

        // 2. Data Grouping Helpers
        String getLabel(DateTime date) {
          if (timeRange == '3Months') {
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
            return "${months[date.month - 1]} ${date.year}";
          } else if (timeRange == '30Days' || timeRange == '1Month') {
            // Group by calendar week (1-7 = Week 1, 8-14 = Week 2, etc.)
            int weekNum = ((date.day - 1) ~/ 7) + 1;
            print('WEEK CALC: Date: ${date.day}/${date.month}, Week: $weekNum');
            return "Week $weekNum";
          } else {
            return "${date.day}/${date.month}";
          }
        }

        // 3. Process Data
        print('OFFLINE HISTORY: Starting data processing for timeRange: $timeRange');
        double totalSys = 0, totalDia = 0, totalSugar = 0, totalWeight = 0;
        int countSys = 0, countSugar = 0, countWeight = 0;
        
        // Buckets for trends
        final Map<String, List<double>> bpSysBucket = {};
        final Map<String, List<double>> bpDiaBucket = {};
        final Map<String, List<double>> sugarBucket = {};
        final Map<String, List<double>> weightBucket = {};
        final readingHistory = <Map<String, dynamic>>[];

        for (final row in filteredData) {
          final dateStr = row['record_date'] as String;
          final date = DateTime.parse(dateStr);
          final label = getLabel(date);
          final id = row['id'] as int;
          print('OFFLINE HISTORY: Processing row - Date: $dateStr, Label: $label');

          // Overall Stats & Reading History (always detailed)
          if (row['systolic'] != null && row['diastolic'] != null) {
            final s = (row['systolic'] as num).toDouble();
            final d = (row['diastolic'] as num).toDouble();
            totalSys += s; totalDia += d; countSys++;
            
            bpSysBucket.putIfAbsent(label, () => []).add(s);
            bpDiaBucket.putIfAbsent(label, () => []).add(d);
            
            readingHistory.add({
              'id': id, 'date_time': dateStr, 'metric_type': 'tekanan_darah',
              'value': '${row['systolic']}/${row['diastolic']} mmHg', 'status': 'Normal'
            });
          }

          if (row['blood_sugar'] != null) {
            final g = (row['blood_sugar'] as num).toDouble();
            totalSugar += g; countSugar++;
            sugarBucket.putIfAbsent(label, () => []).add(g);
            readingHistory.add({
              'id': id, 'date_time': dateStr, 'metric_type': 'gula_darah',
              'value': '${row['blood_sugar']} mg/dL', 'status': 'Normal'
            });
          }

          if (row['weight'] != null) {
            final w = (row['weight'] as num).toDouble();
            totalWeight += w; countWeight++;
            weightBucket.putIfAbsent(label, () => []).add(w);
            readingHistory.add({
              'id': id, 'date_time': dateStr, 'metric_type': 'berat_badan',
              'value': '${row['weight']} kg', 'status': 'Normal'
            });
          }
        }

        // 4. Averaging Buckets for Charts
        final bpTrends = bpSysBucket.keys.map((lbl) {
           final sysList = bpSysBucket[lbl]!;
           final diaList = bpDiaBucket[lbl]!;
           final avgSys = sysList.reduce((a, b) => a + b) / sysList.length;
           final avgDia = diaList.reduce((a, b) => a + b) / diaList.length;
           return {
             if (timeRange == '3Months') 'month': lbl else if (timeRange == '30Days') 'week': lbl else 'date': lbl,
             'systolic': avgSys, 'diastolic': avgDia
           };
        }).toList();

        final sugarTrends = sugarBucket.keys.map((lbl) {
           final list = sugarBucket[lbl]!;
           final avg = list.reduce((a, b) => a + b) / list.length;
           return {
             if (timeRange == '3Months') 'month': lbl else if (timeRange == '30Days') 'week': lbl else 'date': lbl,
             'avg_value': avg
           };
        }).toList();

        final weightTrends = weightBucket.keys.map((lbl) {
           final list = weightBucket[lbl]!;
           final avg = list.reduce((a, b) => a + b) / list.length;
           return {
             if (timeRange == '3Months') 'month': lbl else if (timeRange == '30Days') 'week': lbl else 'date': lbl,
             'weight': avg
           };
        }).toList();

        // 5. Build Final Model Map
        double? latestHeight;
        for (var row in filteredData) {
          if (row['height_cm'] != null) {
            latestHeight = (row['height_cm'] as num).toDouble();
            break;
          }
        }

        final resultJson = {
          'blood_pressure': countSys > 0 ? {
            'avg_systolic': totalSys / countSys,
            'avg_diastolic': totalDia / countSys,
            'change_percent': 0.0,
            'systolic_status': 'Normal',
            'diastolic_status': 'Normal',
            'normal_range': '120/80 mmHg'
          } : null,
          'blood_sugar': countSugar > 0 ? {
            'avg_value': totalSugar / countSugar,
            'change_percent': 0.0,
            'status': 'Normal',
            'normal_range': '< 140 mg/dL'
          } : null,
          'weight': countWeight > 0 ? {
            'avg_weight': totalWeight / countWeight,
            'trend': 'Stabil',
            'change_percent': 0.0
          } : null,
          'trend_charts': {
            'blood_pressure': bpTrends,
            'blood_sugar': sugarTrends,
            'weight': weightTrends,
          },
          'reading_history': readingHistory,
          'latest_height': latestHeight,
        };

        return Right(HealthSummaryModel.fromJson(resultJson));
      } catch (localError) {
        return Left(CacheFailure(localError.toString()));
      }
    }
  }

  /// Helper to cache history list into SQLite
  Future<void> _cacheHistory(HealthSummaryModel summary) async {
    if (summary.readingHistory == null || summary.readingHistory!.isEmpty) return;
    
    final user = await authLocalDataSource.getCurrentUser();
    final userId = user != null ? int.tryParse(user.id) : null;
    
    // Group readings by date
    final Map<String, Map<String, dynamic>> groupedByDate = {};
    
    for (var reading in summary.readingHistory!) {
      // Extract date only (YYYY-MM-DD) using local date components to avoid timezone issues
      final dt = reading.dateTime;
      final date = '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      
      if (!groupedByDate.containsKey(date)) {
        groupedByDate[date] = {'record_date': date, 'user_id': userId};
      }
      
      final metricType = reading.metricType;
      final value = reading.value;
      
      if (metricType == 'tekanan_darah') {
        // Parse "120/80 mmHg"
        final parts = value.split('/');
        if (parts.length == 2) {
          groupedByDate[date]!['systolic'] = int.tryParse(parts[0].trim());
          groupedByDate[date]!['diastolic'] = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '').trim());
        }
      } else if (metricType == 'gula_darah') {
        // Parse "120 mg/dL"
        final numStr = value.replaceAll(RegExp(r'[^0-9]'), '');
        groupedByDate[date]!['blood_sugar'] = int.tryParse(numStr);
      } else if (metricType == 'berat_badan') {
        // Parse "65.5 kg"
        final numStr = value.replaceAll(RegExp(r'[^0-9.]'), '');
        groupedByDate[date]!['weight'] = double.tryParse(numStr);
      } else if (metricType == 'tinggi_badan' || metricType == 'height') {
        // Parse "170 cm" or "170.5 cm"
        final numStr = value.replaceAll(RegExp(r'[^0-9.]'), '');
        final heightValue = double.tryParse(numStr);
        if (heightValue != null) {
          groupedByDate[date]!['height_cm'] = heightValue.round();
        }
      }
    }
    
    // Save to database (merge with existing data)
    final db = await databaseHelper.database;
    for (var entry in groupedByDate.entries) {
      final date = entry.key;
      final newData = entry.value;
      
      // Check if record exists
      final existing = await db.query('health_data', where: 'record_date = ?', whereArgs: [date]);
      
      if (existing.isNotEmpty) {
        final oldData = existing.first;
        final isLocalUnsynced = (oldData['is_synced'] == 0);
        
        // CRITICAL: Don't overwrite unsynced local data with server data
        // If local data is unsynced, it means it's newer than what the server has
        if (isLocalUnsynced) {
          print('_cacheHistory: Skipping merge for $date - local data is unsynced (newer)');
          continue; // Skip this entry, keep local unsynced data intact
        }
        
        // Merge with existing data (only if local is already synced)
        final merged = {
          'id': oldData['id'],
          'user_id': userId ?? oldData['user_id'],
          'systolic': newData['systolic'] ?? oldData['systolic'],
          'diastolic': newData['diastolic'] ?? oldData['diastolic'],
          'blood_sugar': newData['blood_sugar'] ?? oldData['blood_sugar'],
          'weight': newData['weight'] ?? oldData['weight'],
          'height_cm': newData['height_cm'] ?? oldData['height_cm'],
          'heart_rate': oldData['heart_rate'],
          'activity': oldData['activity'],
          'record_date': date,
          'is_synced': 1, // Data from server is already synced
        };
        await db.update('health_data', merged, where: 'id = ?', whereArgs: [oldData['id']]);
      } else {
        // Insert new record
        newData['is_synced'] = 1;
        await db.insert('health_data', newData);
      }
    }
  }

  @override
  Future<Either<Failure, List<int>>> downloadHealthHistoryPdf(String timeRange) async {
    try {
      final pdfBytes = await remoteDataSource.downloadHealthHistoryPdf(timeRange);
      return Right(pdfBytes);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HealthAlertsModel?>> checkHealthAlerts() async {
    try {
      final response = await remoteDataSource.checkHealthAlerts();
      if (response != null) {
        await _saveAlertsToLocal(response);
      }
      return Right(response);
    } catch (e) {
      // Offline implementation for Alerts
      try {
        final localAlerts = await _getAlertsFromLocal();
        return Right(localAlerts);
      } catch (localError) {
        return Left(CacheFailure(localError.toString()));
      }
    }
  }

  Future<void> _saveAlertsToLocal(HealthAlertsModel alertsModel) async {
    final db = await databaseHelper.database;
    final user = await authLocalDataSource.getCurrentUser();
    final userId = user != null ? int.tryParse(user.id) : null;

    await db.transaction((txn) async {
      await txn.delete('health_alerts'); 
      
      for (var alert in alertsModel.alerts) {
        // alert is HealthAlert
        await txn.insert(
          'health_alerts',
          {
            'user_id': userId,
            'alert_type': alert.alertType, // Fixed: type -> alertType
            'message': alert.label,        // Fixed: message -> label (or explanation)
            'status': alert.status,
            'recommendations': alert.explanation,
            'recorded_at': DateTime.now().toIso8601String(),
          },
        );
      }
    });
  }

  Future<HealthAlertsModel?> _getAlertsFromLocal() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('health_alerts');
    
    if (maps.isEmpty) {
      // If table is empty, try to generate from latest health data
      final user = await authLocalDataSource.getCurrentUser();
      final userId = user != null ? int.tryParse(user.id) : null;
      return await _generateAlertsFromLatestData(userId);
    }

    final List<HealthAlert> alerts = maps.map((row) {
      return HealthAlert(
         alertType: row['alert_type'] ?? '',
         category: '', 
         value: '',    
         label: row['message'] ?? '',    
         status: row['status'] ?? '',
         recordedAt: row['recorded_at'] != null ? DateTime.parse(row['recorded_at']) : DateTime.now(),
         explanation: row['recommendations'] ?? '', 
         immediateActions: const [],
         medicalAttention: const [],
         managementTips: const [],
         educationVideos: const [],
      );
    }).toList();

    return HealthAlertsModel(alerts: alerts);
  }

  /// Generate basic alerts locally based on latest health data when offline
  Future<HealthAlertsModel?> _generateAlertsFromLatestData(int? userId) async {
    final localHistory = await databaseHelper.getHealthDataHistory();
    if (localHistory.isEmpty) return null;

    final latest = localHistory.first;
    final List<HealthAlert> generatedAlerts = [];

    // 1. Blood Pressure Alert
    if (latest['systolic'] != null && latest['diastolic'] != null) {
      final sys = latest['systolic'] as int;
      final dia = latest['diastolic'] as int;
      
      String status = 'NORMAL';
      String explanation = 'Tekanan darah Anda dalam rentang normal.';
      
      if (sys >= 180 || dia >= 110) {
        status = 'KRITIS';
        explanation = 'Tekanan darah Anda sangat tinggi (Krisis Hipertensi). Segera hubungi bantuan medis!';
      } else if (sys >= 160 || dia >= 100) {
        status = 'SANGAT TINGGI';
        explanation = 'Tekanan darah Anda tinggi (Hipertensi Tahap 2). Segera konsultasi dengan dokter.';
      } else if (sys >= 140 || dia >= 90) {
        status = 'TINGGI';
        explanation = 'Tekanan darah Anda terpantau tinggi (Hipertensi Tahap 1). Kurangi konsumsi garam dan pantau rutin.';
      } else if (sys < 90 || dia < 60) {
        status = 'RENDAH';
        explanation = 'Tekanan darah Anda terpantau rendah (Hipotensi). Pastikan asupan cairan cukup.';
      }

      if (status != 'NORMAL') {
        generatedAlerts.add(HealthAlert(
          alertType: 'Tekanan Darah',
          category: 'Jantung',
          value: '$sys/$dia mmHg',
          label: 'Status: $status',
          status: status,
          recordedAt: DateTime.parse(latest['record_date']),
          explanation: explanation,
          immediateActions: const [],
          medicalAttention: const [],
          managementTips: const [],
          educationVideos: const [],
        ));
      }
    }

    // 2. Blood Sugar Alert
    if (latest['blood_sugar'] != null) {
      final sugar = latest['blood_sugar'] as int;
      String status = 'NORMAL';
      String explanation = 'Kadar gula darah Anda terpantau normal.';

      if (sugar >= 200) {
        status = 'SANGAT TINGGI';
        explanation = 'Kadar gula darah Anda sangat tinggi. Hindari konsumsi gula dan segera periksa ke dokter.';
      } else if (sugar >= 140) {
        status = 'TINGGI';
        explanation = 'Kadar gula darah Anda terpantau tinggi. Perhatikan pola makan Anda.';
      } else if (sugar < 70) {
        status = 'RENDAH';
        explanation = 'Kadar gula darah Anda rendah (Hipoglikemia). Konsumsi sumber gula segera.';
      }

      if (status != 'NORMAL') {
        generatedAlerts.add(HealthAlert(
          alertType: 'Gula Darah',
          category: 'Diabetes',
          value: '$sugar mg/dL',
          label: 'Status: $status',
          status: status,
          recordedAt: DateTime.parse(latest['record_date']),
          explanation: explanation,
          immediateActions: const [],
          medicalAttention: const [],
          managementTips: const [],
          educationVideos: const [],
        ));
      }
    }

    if (generatedAlerts.isEmpty) return null;
    return HealthAlertsModel(alerts: generatedAlerts);
  }

  /// Sync unsynced local data to server in background
  Future<void> syncUnsyncedData() async {
    try {
      final localData = await databaseHelper.getHealthDataHistory();
      final unsyncedData = localData.where((row) => row['is_synced'] == 0).toList();
      
      if (unsyncedData.isEmpty) {
        print('SYNC: No unsynced data to upload');
        return;
      }
      
      print('SYNC: Found ${unsyncedData.length} unsynced records to upload');
      
      final user = await authLocalDataSource.getCurrentUser();
      final userId = user != null ? int.tryParse(user.id) : null;
      
      for (var row in unsyncedData) {
        try {
          // Convert local row to HealthDataModel
          final dateStr = row['record_date'] as String;
          // Parse date parts to avoid timezone issues
          final dateParts = dateStr.split('-');
          final recordDate = DateTime(
            int.parse(dateParts[0]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[2]), // day
            12, // Set to noon to avoid timezone edge cases
          );
          
          final healthData = HealthData(
            date: recordDate,
            systolic: row['systolic'],
            diastolic: row['diastolic'],
            bloodSugar: row['blood_sugar'],
            weight: row['weight'],
            height: row['height_cm'] != null ? (row['height_cm'] as int).toDouble() : null,
            activity: row['activity'],
            heartRate: row['heart_rate'],
          );
          
          final healthDataModel = HealthDataModel.fromEntity(healthData);
          
          // Try to upload to server
          print('SYNC: Uploading data for date: ${row['record_date']}');
          await remoteDataSource.saveHealthData(healthDataModel);
          
          // Mark as synced in local database
          final db = await databaseHelper.database;
          await db.update(
            'health_data',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
          
          print('SYNC: Successfully synced data for date: ${row['record_date']}');
        } catch (e) {
          print('SYNC: Failed to sync data for date: ${row['record_date']} - $e');
          // Continue with next record even if one fails
        }
      }
    } catch (e) {
      print('SYNC: Error during background sync: $e');
    }
  }
}
