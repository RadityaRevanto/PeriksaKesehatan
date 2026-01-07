import 'package:dartz/dartz.dart';
import 'package:periksa_kesehatan/core/network/api_exception.dart';
import 'package:periksa_kesehatan/data/datasources/remote/health_remote_datasource.dart';
import 'package:periksa_kesehatan/data/models/health/health_data_model.dart';
import 'package:periksa_kesehatan/data/models/health/health_summary_model.dart';
import 'package:periksa_kesehatan/data/models/health/health_alert_model.dart';
import 'package:periksa_kesehatan/domain/entities/failure.dart';
import 'package:periksa_kesehatan/domain/entities/health_data.dart';

/// Repository untuk health data
abstract class HealthRepository {
  Future<Either<Failure, HealthData>> saveHealthData(HealthData healthData);
  Future<Either<Failure, HealthData?>> getHealthData();
  Future<Either<Failure, HealthSummaryModel?>> getHealthHistory();
  Future<Either<Failure, List<int>>> downloadHealthHistoryPdf(String timeRange);
  Future<Either<Failure, HealthAlertsModel?>> checkHealthAlerts();
}

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  HealthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, HealthData>> saveHealthData(HealthData healthData) async {
    try {
      // Convert entity to model
      final healthDataModel = HealthDataModel.fromEntity(healthData);
      
      // Save to remote
      final response = await remoteDataSource.saveHealthData(healthDataModel);
      
      // Convert response to entity
      final savedHealthData = response.toEntity();
      
      return Right(savedHealthData);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HealthData?>> getHealthData() async {
    try {
      // Get from remote (backend return data terbaru)
      final response = await remoteDataSource.getHealthData();
      
      // Convert model to entity (nullable)
      final healthData = response?.toEntity();
      
      return Right(healthData);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HealthSummaryModel?>> getHealthHistory() async {
    try {
      // Get from remote
      final response = await remoteDataSource.getHealthHistory();
      
      return Right(response);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> downloadHealthHistoryPdf(String timeRange) async {
    try {
      // Download PDF from remote
      final pdfBytes = await remoteDataSource.downloadHealthHistoryPdf(timeRange);
      
      return Right(pdfBytes);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HealthAlertsModel?>> checkHealthAlerts() async {
    try {
      // Get from remote
      final response = await remoteDataSource.checkHealthAlerts();
      
      return Right(response);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
