import 'package:periksa_kesehatan/data/datasources/remote/education_remote_datasource.dart';
import 'package:periksa_kesehatan/data/models/education/education_model.dart';
import 'package:periksa_kesehatan/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Repository untuk mengelola data education
abstract class EducationRepository {
  Future<List<EducationCategoryModel>> getEducationalVideos();
  Future<EducationCategoryModel> getEducationalVideosByCategory(int categoryId);
}



class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource remoteDataSource;
  final DatabaseHelper databaseHelper; // Inject DatabaseHelper

  EducationRepositoryImpl({
    required this.remoteDataSource,
    required this.databaseHelper,
  });

  @override
  Future<List<EducationCategoryModel>> getEducationalVideos() async {
    try {
      // 1. Coba ambil data dari API (Online)
      final categories = await remoteDataSource.getEducationalVideos();
      
      // 2. Jika berhasil, simpan ke SQLite (Cache)
      await _saveToLocal(categories);
      
      return categories;
    } catch (e) {
      // 3. Jika gagal (Offline/Error), ambil dari SQLite
      final localCategories = await _getFromLocal();
      if (localCategories.isNotEmpty) {
        return localCategories;
      }
      
      // Jika lokal juga kosong, lempar error aslinya
      rethrow;
    }
  }

  @override
  Future<EducationCategoryModel> getEducationalVideosByCategory(int categoryId) async {
    // Bisa diterapkan pola yang sama jika perlu detail per kategori
    return await remoteDataSource.getEducationalVideosByCategory(categoryId);
  }

  /// Helpers untuk SQLite
  Future<void> _saveToLocal(List<EducationCategoryModel> categories) async {
    final db = await databaseHelper.database;
    await db.transaction((txn) async {
      // Bersihkan data lama agar tidak duplikat/conflict
      await txn.delete('education_videos');
      await txn.delete('education_categories');

      for (var category in categories) {
        // Simpan Category
         await txn.insert(
          'education_categories',
          {
            'id': category.id,
            'kategori': category.kategori,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Simpan Videos untuk Category tersebut
        for (var video in category.videos) {
           await txn.insert(
            'education_videos',
            {
              'category_id': category.id,
              'title': video.title,
              'url': video.url,
              'duration': video.duration,
              'thumbnailUrl': video.thumbnailUrl,
            },
          );
        }
      }
    });
  }

  Future<List<EducationCategoryModel>> _getFromLocal() async {
    final db = await databaseHelper.database;
    
    // Ambil semua category
    final categoryMaps = await db.query('education_categories');
    
    List<EducationCategoryModel> categories = [];
    
    for (var catMap in categoryMaps) {
      final categoryId = catMap['id'] as int;
      
      // Ambil video berdasarkan category_id
      final videoMaps = await db.query(
        'education_videos',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );
      
      final videos = videoMaps.map((v) => VideoModel(
        title: v['title'] as String,
        url: v['url'] as String,
        duration: v['duration'] as String,
        thumbnailUrl: v['thumbnailUrl'] as String,
      )).toList();

      categories.add(EducationCategoryModel(
        id: categoryId,
        kategori: catMap['kategori'] as String,
        videos: videos,
      ));
    }
    
    return categories;
  }
}
