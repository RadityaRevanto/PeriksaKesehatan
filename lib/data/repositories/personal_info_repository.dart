import 'dart:io';
import 'package:periksa_kesehatan/data/datasources/remote/personal_info_remote_datasource.dart';
import 'package:periksa_kesehatan/data/models/profile/personal_info_model.dart';

class PersonalInfoRepository {
  final PersonalInfoRemoteDatasource remoteDatasource;

  PersonalInfoRepository(this.remoteDatasource);

  Future<PersonalInfoModel?> getPersonalInfo(String token) async {
    try {
      return await remoteDatasource.getPersonalInfo(token);
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalInfoModel> updatePersonalInfo(
    String token,
    PersonalInfoModel personalInfo, {
    File? imageFile,
  }) async {
    try {
      return await remoteDatasource.updatePersonalInfo(token, personalInfo, imageFile: imageFile);
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalInfoModel> createPersonalInfo(
    String token,
    PersonalInfoModel personalInfo, {
    File? imageFile,
  }) async {
    try {
      return await remoteDatasource.createPersonalInfo(token, personalInfo, imageFile: imageFile);
    } catch (e) {
      rethrow;
    }
  }
}
