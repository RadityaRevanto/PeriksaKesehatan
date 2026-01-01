import 'package:equatable/equatable.dart';
import 'package:periksa_kesehatan/data/models/profile/personal_info_model.dart';

abstract class PersonalInfoState extends Equatable {
  const PersonalInfoState();

  @override
  List<Object?> get props => [];
}

class PersonalInfoInitial extends PersonalInfoState {}

class PersonalInfoLoading extends PersonalInfoState {}

class PersonalInfoLoaded extends PersonalInfoState {
  final PersonalInfoModel? personalInfo;

  const PersonalInfoLoaded(this.personalInfo);

  @override
  List<Object?> get props => [personalInfo];
}

class PersonalInfoError extends PersonalInfoState {
  final String message;

  const PersonalInfoError(this.message);

  @override
  List<Object?> get props => [message];
}

class PersonalInfoUpdated extends PersonalInfoState {
  final PersonalInfoModel personalInfo;

  const PersonalInfoUpdated(this.personalInfo);

  @override
  List<Object?> get props => [personalInfo];
}
