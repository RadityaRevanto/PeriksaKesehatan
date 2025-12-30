import 'package:periksa_kesehatan/data/datasources/remote/education_remote_datasource.dart';
import 'package:periksa_kesehatan/data/models/education/education_model.dart';

/// Repository untuk mengelola data education
abstract class EducationRepository {
  Future<List<EducationCategoryModel>> getEducationalVideos();
  Future<EducationCategoryModel> getEducationalVideosByCategory(int categoryId);
}

class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource remoteDataSource;

  EducationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<EducationCategoryModel>> getEducationalVideos() async {
    return await remoteDataSource.getEducationalVideos();
  }

  @override
  Future<EducationCategoryModel> getEducationalVideosByCategory(int categoryId) async {
    return await remoteDataSource.getEducationalVideosByCategory(categoryId);
  }
}
