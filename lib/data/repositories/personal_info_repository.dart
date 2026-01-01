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
    PersonalInfoModel personalInfo,
  ) async {
    try {
      return await remoteDatasource.updatePersonalInfo(token, personalInfo);
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalInfoModel> createPersonalInfo(
    String token,
    PersonalInfoModel personalInfo,
  ) async {
    try {
      return await remoteDatasource.createPersonalInfo(token, personalInfo);
    } catch (e) {
      rethrow;
    }
  }
}
