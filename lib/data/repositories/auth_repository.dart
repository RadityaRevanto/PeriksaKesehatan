import 'package:dartz/dartz.dart';
import 'dart:io'; // Import SocketException
import 'package:periksa_kesehatan/core/network/api_exception.dart';
import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:periksa_kesehatan/data/datasources/local/auth_local_datasource.dart';
import 'package:periksa_kesehatan/data/datasources/remote/auth_remote_datasource.dart';
import 'package:periksa_kesehatan/domain/entities/failure.dart';
import 'package:periksa_kesehatan/domain/entities/user.dart';

/// Repository untuk authentication
abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<User?> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.storageService,
  });

  @override
  Future<Either<Failure, User>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        identifier: identifier,
        password: password,
      );

      final user = response.toEntity();

      // Simpan data ke local storage
      await localDataSource.saveUserData(
        token: response.token,
        user: user,
      );

      return Right(user);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('Tidak ada koneksi internet. Mohon periksa jaringan Anda.'));
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Network is unreachable')) {
        return const Left(NetworkFailure('Tidak ada koneksi internet. Mohon periksa jaringan Anda.'));
      }
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      final user = response.toEntity();

      // Simpan data ke local storage
      await localDataSource.saveUserData(
        token: response.token,
        user: user,
      );

      return Right(user);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('Tidak ada koneksi internet. Mohon periksa jaringan Anda.'));
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Network is unreachable')) {
        return const Left(NetworkFailure('Tidak ada koneksi internet. Mohon periksa jaringan Anda.'));
      }
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Hapus data dari remote (optional, tergantung API)
      await remoteDataSource.logout();
    } catch (e) {
      // Continue dengan clear local data meskipun remote logout gagal
    } finally {
      // Selalu hapus data lokal
      await localDataSource.clearUserData();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getCurrentUser();
  }
}

