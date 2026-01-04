import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:periksa_kesehatan/data/repositories/personal_info_repository.dart';
import 'package:periksa_kesehatan/presentation/bloc/personal_info/personal_info_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/personal_info/personal_info_state.dart';

class PersonalInfoBloc extends Bloc<PersonalInfoEvent, PersonalInfoState> {
  final PersonalInfoRepository repository;

  PersonalInfoBloc(this.repository) : super(PersonalInfoInitial()) {
    on<LoadPersonalInfo>(_onLoadPersonalInfo);
    on<UpdatePersonalInfo>(_onUpdatePersonalInfo);
    on<CreatePersonalInfo>(_onCreatePersonalInfo);
  }

  Future<void> _onLoadPersonalInfo(
    LoadPersonalInfo event,
    Emitter<PersonalInfoState> emit,
  ) async {
    emit(PersonalInfoLoading());
    try {
      final personalInfo = await repository.getPersonalInfo(event.token);
      emit(PersonalInfoLoaded(personalInfo));
    } catch (e) {
      emit(PersonalInfoError(e.toString()));
    }
  }

  Future<void> _onUpdatePersonalInfo(
    UpdatePersonalInfo event,
    Emitter<PersonalInfoState> emit,
  ) async {
    emit(PersonalInfoLoading());
    try {
      final personalInfo = await repository.updatePersonalInfo(
        event.token,
        event.personalInfo,
      );
      emit(PersonalInfoUpdated(personalInfo));
      // Reload after update
      add(LoadPersonalInfo(event.token));
    } catch (e) {
      emit(PersonalInfoError(e.toString()));
    }
  }

  Future<void> _onCreatePersonalInfo(
    CreatePersonalInfo event,
    Emitter<PersonalInfoState> emit,
  ) async {
    emit(PersonalInfoLoading());
    try {
      final personalInfo = await repository.createPersonalInfo(
        event.token,
        event.personalInfo,
      );
      emit(PersonalInfoUpdated(personalInfo));
      // Reload after create
      add(LoadPersonalInfo(event.token));
    } catch (e) {
      emit(PersonalInfoError(e.toString()));
    }
  }
}
