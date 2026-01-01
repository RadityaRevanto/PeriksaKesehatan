import 'package:equatable/equatable.dart';
import 'package:periksa_kesehatan/data/models/profile/personal_info_model.dart';

abstract class PersonalInfoEvent extends Equatable {
  const PersonalInfoEvent();

  @override
  List<Object?> get props => [];
}

class LoadPersonalInfo extends PersonalInfoEvent {
  final String token;

  const LoadPersonalInfo(this.token);

  @override
  List<Object?> get props => [token];
}

class UpdatePersonalInfo extends PersonalInfoEvent {
  final String token;
  final PersonalInfoModel personalInfo;

  const UpdatePersonalInfo(this.token, this.personalInfo);

  @override
  List<Object?> get props => [token, personalInfo];
}

class CreatePersonalInfo extends PersonalInfoEvent {
  final String token;
  final PersonalInfoModel personalInfo;

  const CreatePersonalInfo(this.token, this.personalInfo);

  @override
  List<Object?> get props => [token, personalInfo];
}
