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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table untuk User
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        token TEXT,
        created_at TEXT
      )
    ''');

    // Table untuk Education Categories
    await db.execute('''
      CREATE TABLE education_categories (
        id INTEGER PRIMARY KEY,
        kategori TEXT
      )
    ''');

    // Table untuk Education Videos
    await db.execute('''
      CREATE TABLE education_videos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        title TEXT,
        url TEXT,
        duration TEXT,
        thumbnailUrl TEXT,
        FOREIGN KEY (category_id) REFERENCES education_categories (id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
