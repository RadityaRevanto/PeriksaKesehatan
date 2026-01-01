import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:periksa_kesehatan/core/network/api_client.dart';
import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:periksa_kesehatan/data/datasources/local/auth_local_datasource.dart';
import 'package:periksa_kesehatan/data/datasources/remote/auth_remote_datasource.dart';
import 'package:periksa_kesehatan/data/datasources/remote/health_remote_datasource.dart';
import 'package:periksa_kesehatan/data/datasources/remote/education_remote_datasource.dart';
import 'package:periksa_kesehatan/data/datasources/remote/personal_info_remote_datasource.dart';
import 'package:periksa_kesehatan/data/repositories/auth_repository.dart';
import 'package:periksa_kesehatan/data/repositories/health_repository.dart';
import 'package:periksa_kesehatan/data/repositories/education_repository.dart';
import 'package:periksa_kesehatan/data/repositories/personal_info_repository.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/education/education_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/personal_info/personal_info_bloc.dart';

/// Service locator menggunakan GetIt
final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  // Initialize StorageService
  await StorageService.instance.init();

  // Core
  sl.registerLazySingleton(() => StorageService.instance);
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => http.Client());

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storageService: sl()),
  );
  sl.registerLazySingleton<HealthRemoteDataSource>(
    () => HealthRemoteDataSourceImpl(
      client: sl(),
      storageService: sl(),
    ),
  );
  sl.registerLazySingleton<EducationRemoteDataSource>(
    () => EducationRemoteDataSourceImpl(
      client: sl(),
      storageService: sl(),
    ),
  );
  sl.registerLazySingleton<PersonalInfoRemoteDatasource>(
    () => PersonalInfoRemoteDatasource(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      storageService: sl(),
    ),
  );
  sl.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<EducationRepository>(
    () => EducationRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<PersonalInfoRepository>(
    () => PersonalInfoRepository(sl()),
  );

  // BLoC
  sl.registerFactory(
    () => AuthBloc(authRepository: sl()),
  );
  sl.registerFactory(
    () => HealthBloc(healthRepository: sl()),
  );
  sl.registerFactory(
    () => EducationBloc(educationRepository: sl()),
  );
  sl.registerFactory(
    () => PersonalInfoBloc(sl()),
  );
}

