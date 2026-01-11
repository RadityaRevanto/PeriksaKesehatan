import 'dart:io';
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
  final File? imageFile;

  const UpdatePersonalInfo(this.token, this.personalInfo, {this.imageFile});

  @override
  List<Object?> get props => [token, personalInfo, imageFile];
}

class CreatePersonalInfo extends PersonalInfoEvent {
  final String token;
  final PersonalInfoModel personalInfo;
  final File? imageFile;

  const CreatePersonalInfo(this.token, this.personalInfo, {this.imageFile});

  @override
  List<Object?> get props => [token, personalInfo, imageFile];
}
