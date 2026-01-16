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
    final defaultData = _getDefaultLocalData();
    try {
      // 1. Coba ambil data dari API (Online)
      final remoteCategories = await remoteDataSource.getEducationalVideos();
      
      // 2. Jika berhasil, simpan ke SQLite (Cache)
      await _saveToLocal(remoteCategories);
      
      // 3. Merging: Pastikan video lokal ada di paling atas atau digabung berdasarkan kategori
      final List<EducationCategoryModel> merged = List.from(defaultData);
      
      for (var remoteCat in remoteCategories) {
        final existingIndex = merged.indexWhere((c) => c.kategori == remoteCat.kategori);
        if (existingIndex != -1) {
          // Tambahkan video remote ke kategori lokal yang ada jika belum ada di lokal
          for (var remoteVideo in remoteCat.videos) {
            if (!merged[existingIndex].videos.any((v) => v.title == remoteVideo.title)) {
              merged[existingIndex].videos.add(remoteVideo);
            }
          }
        } else {
          merged.add(remoteCat);
        }
      }
      
      return merged;
    } catch (e) {
      // 3. Jika gagal (Offline/Error), ambil dari SQLite
      final localCategories = await _getFromLocal();
      if (localCategories.isNotEmpty) {
        // Tetap merge dengan default agar selalu ada video lokal asli
        final Map<String, EducationCategoryModel> map = {};
        for (var c in defaultData) { map[c.kategori] = c; }
        for (var c in localCategories) {
           if (map.containsKey(c.kategori)) {
              for (var v in c.videos) {
                 if (!map[c.kategori]!.videos.any((lv) => lv.title == v.title)) {
                    map[c.kategori]!.videos.add(v);
                 }
              }
           } else {
              map[c.kategori] = c;
           }
        }
        return map.values.toList();
      }
      
      // 4. Jika SQLite juga kosong (misal belum pernah online), gunakan data default
      return defaultData;
    }
  }

  @override
  Future<EducationCategoryModel> getEducationalVideosByCategory(int categoryId) async {
    try {
      final remoteCat = await remoteDataSource.getEducationalVideosByCategory(categoryId);
      // Check if this category exists in local default
      final defaultData = _getDefaultLocalData();
      final localCat = defaultData.firstWhere(
        (c) => c.kategori == remoteCat.kategori,
        orElse: () => EducationCategoryModel(id: -1, kategori: '', videos: []),
      );
      
      if (localCat.id != -1) {
        for (var v in remoteCat.videos) {
          if (!localCat.videos.any((lv) => lv.title == v.title)) {
            localCat.videos.add(v);
          }
        }
        return localCat;
      }
      return remoteCat;
    } catch (e) {
       // Fallback Offline
       final allLocal = await getEducationalVideos();
       return allLocal.firstWhere(
         (cat) => cat.id == categoryId,
         orElse: () => EducationCategoryModel(id: categoryId, kategori: 'Kategori', videos: []),
       );
    }
  }

  /// Data default yang selalu tersedia meskipun belum pernah online
  List<EducationCategoryModel> _getDefaultLocalData() {
    return [
       EducationCategoryModel(
        id: 992,
        kategori: 'Hipertensi',
        videos: [
            VideoModel(
              title: 'Cara Menjaga Tekanan Darah Agar Tetap Stabil',
              url: 'assets/videos/videoplayback.mp4',
              duration: '04:46',
              thumbnailUrl: 'assets/images/blood_pressure_thumb.png',
            )
        ],
      ),
       EducationCategoryModel(
        id: 993,
        kategori: 'Jantung',
        videos: [
            VideoModel(
              title: 'Cara Menjaga Kesehatan Jantung',
              url: 'assets/videos/jantung.mp4',
              duration: '06:36',
              thumbnailUrl: 'assets/images/heart_signs_thumb.png',
            )
        ],
      ),
    ];
  }

  /// Helpers untuk SQLite
  Future<void> _saveToLocal(List<EducationCategoryModel> categories) async {
    List<Map<String, dynamic>> categoryMaps = [];
    List<Map<String, dynamic>> videoMaps = [];

    for (var category in categories) {
      categoryMaps.add({
        'id': category.id,
        'name': category.kategori,
      });

      for (var video in category.videos) {
        videoMaps.add({
          'category_id': category.id,
          'video_title': video.title,
          'video_url': video.url,
          'thumbnail_url': video.thumbnailUrl,
          'health_condition': video.duration, 
        });
      }
    }

    await databaseHelper.cacheCategories(categoryMaps);
    await databaseHelper.cacheVideos(videoMaps);
  }


  Future<List<EducationCategoryModel>> _getFromLocal() async {
    final categoryMaps = await databaseHelper.getCategories();
    final videoMaps = await databaseHelper.getVideos();
    
    Map<int, List<VideoModel>> videos = {};
    for (var v in videoMaps) {
      final catId = v['category_id'] as int;
      final video = VideoModel(
        title: v['video_title'] as String,
        url: v['video_url'] as String,
        duration: v['health_condition'] as String? ?? '00:00',
        thumbnailUrl: v['thumbnail_url'] as String? ?? '',
      );
      
      if (!videos.containsKey(catId)) videos[catId] = [];
      videos[catId]!.add(video);
    }

    List<EducationCategoryModel> categories = [];
    for (var catMap in categoryMaps) {
      final categoryId = catMap['id'] as int;
      categories.add(EducationCategoryModel(
        id: categoryId,
        kategori: catMap['name'] as String,
        videos: videos[categoryId] ?? [],
      ));
    }
    
    return categories;
  }
}
