import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('periksa_kesehatan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ... same as before but updated ...
    // 1. User & Profile
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        nama TEXT,
        username TEXT,
        email TEXT,
        notification_enabled INTEGER,
        language TEXT,
        token TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE personal_infos (
        user_id INTEGER PRIMARY KEY,
        name TEXT,
        birth_date TEXT,
        phone TEXT,
        address TEXT,
        photo_url TEXT,
        weight REAL,
        height REAL,
        is_synced INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    
    // Pending Registrations (Offline Registration)
    await db.execute('''
      CREATE TABLE pending_registrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT,
        confirm_password TEXT,
        recorded_at TEXT
      )
    ''');

    // 2. Health Data
    await db.execute('''
      CREATE TABLE health_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        systolic INTEGER,
        diastolic INTEGER,
        blood_sugar INTEGER,
        weight REAL,
        height_cm INTEGER,
        heart_rate INTEGER,
        activity TEXT,
        record_date TEXT UNIQUE,
        is_synced INTEGER DEFAULT 1
      )
    ''');

    // 3. Educational Content
    await db.execute('''
      CREATE TABLE educational_videos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        video_title TEXT,
        video_url TEXT,
        thumbnail_url TEXT,
        category_id INTEGER,
        health_condition TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    // 4. Alerts
    await db.execute('''
      CREATE TABLE health_alerts (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        alert_type TEXT,
        message TEXT,
        status TEXT,
        recommendations TEXT,
        recorded_at TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS education_categories');
      await db.execute('DROP TABLE IF EXISTS education_videos');
      await _createDB(db, newVersion);
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_registrations ( ... )
      '''); // simplified for brevity but I should be careful
    }
    // Correct way: handle incrementally
    if (oldVersion < 3) {
       await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_registrations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          password TEXT,
          confirm_password TEXT,
          recorded_at TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      // Add thumbnail_url to educational_videos
      try {
        await db.execute('ALTER TABLE educational_videos ADD COLUMN thumbnail_url TEXT');
      } catch (e) {
        // Column might already exist if createDB ran for v4
      }
    }
    if (oldVersion < 5) {
      // Recreate personal_infos with user_id as PK to support clean offline upserts
      try {
         await db.execute('ALTER TABLE personal_infos RENAME TO personal_infos_old');
         await db.execute('''
          CREATE TABLE personal_infos (
            user_id INTEGER PRIMARY KEY,
            name TEXT,
            birth_date TEXT,
            phone TEXT,
            address TEXT,
            photo_url TEXT,
            is_synced INTEGER DEFAULT 1,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
        await db.execute('''
          INSERT OR REPLACE INTO personal_infos (user_id, name, birth_date, phone, address, photo_url, is_synced)
          SELECT user_id, name, birth_date, phone, address, photo_url, 1 FROM personal_infos_old
        ''');
        await db.execute('DROP TABLE personal_infos_old');
      } catch (e) {
         // If table didn't exist or other error, ensure it exists now
         await db.execute('''
          CREATE TABLE IF NOT EXISTS personal_infos (
            user_id INTEGER PRIMARY KEY,
            name TEXT,
            birth_date TEXT,
            phone TEXT,
            address TEXT,
            photo_url TEXT,
            is_synced INTEGER DEFAULT 1,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
      }
    }
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE personal_infos ADD COLUMN weight REAL');
        await db.execute('ALTER TABLE personal_infos ADD COLUMN height REAL');
      } catch (e) {
        // Columns might already exist
      }
    }
  }

  // --- CRUD & Sync Logic ---

  // Health Data
  Future<int> insertHealthData(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(
      'health_data',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getHealthDataHistory() async {
    final db = await instance.database;
    return await db.query('health_data', orderBy: 'record_date DESC');
  }

  Future<List<Map<String, dynamic>>> getUnsyncedHealthData() async {
    final db = await instance.database;
    return await db.query('health_data', where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<int> updateHealthData(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'health_data',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<int> deleteHealthData(int id) async {
    final db = await instance.database;
    return await db.delete('health_data', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<void> markHealthDataSynced(int localId) async {
     final db = await instance.database;
     await db.update('health_data', {'is_synced': 1}, where: 'id = ?', whereArgs: [localId]);
  }

  // --- Caching Methods for Read-Only Content ---

  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Clear old categories to ensure exact mirror of server
      await txn.delete('categories');
      
      final batch = txn.batch();
      for (var category in categories) {
        batch.insert(
          'categories',
          category,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> cacheVideos(List<Map<String, dynamic>> videos) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Clear old videos
      await txn.delete('educational_videos');
      
      final batch = txn.batch();
      for (var video in videos) {
        batch.insert(
          'educational_videos',
          video,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> cacheAlerts(int userId, List<Map<String, dynamic>> alerts) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Clear old alerts for this user
      await txn.delete('health_alerts', where: 'user_id = ?', whereArgs: [userId]);
      
      final batch = txn.batch();
      for (var alert in alerts) {
        batch.insert(
          'health_alerts',
          alert,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
  
  // Getters for Cache
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getVideos() async {
    final db = await instance.database;
    return await db.query('educational_videos');
  }

  Future<List<Map<String, dynamic>>> getAlerts(int userId) async {
    final db = await instance.database;
    return await db.query('health_alerts', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<Map<String, dynamic>?> getUnsyncedPersonalInfo() async {
    final db = await instance.database;
    final results = await db.query('personal_infos', where: 'is_synced = ?', whereArgs: [0], limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> markPersonalInfoSynced(int userId) async {
    final db = await instance.database;
    await db.update('personal_infos', {'is_synced': 1}, where: 'user_id = ?', whereArgs: [userId]);
  }

  // --- Offline Registration Helpers ---
  
  Future<int> insertPendingRegistration(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('pending_registrations', row);
  }

  Future<List<Map<String, dynamic>>> getPendingRegistrations() async {
    final db = await instance.database;
    return await db.query('pending_registrations');
  }

  Future<int> deletePendingRegistration(int id) async {
    final db = await instance.database;
    return await db.delete('pending_registrations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
