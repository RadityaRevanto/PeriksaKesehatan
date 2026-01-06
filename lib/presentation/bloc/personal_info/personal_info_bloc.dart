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
      // Jika error karena profil belum ada (404), coba create dulu
      if (e.toString().contains('Profile not found') || 
          e.toString().contains('404') ||
          e.toString().contains('tidak ditemukan')) {
        try {
          // Fallback: coba create profil baru
          final personalInfo = await repository.createPersonalInfo(
            event.token,
            event.personalInfo,
          );
          emit(PersonalInfoUpdated(personalInfo));
          // Reload after create
          add(LoadPersonalInfo(event.token));
        } catch (createError) {
          emit(PersonalInfoError(createError.toString()));
        }
      } else {
        emit(PersonalInfoError(e.toString()));
      }
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
      // Jika error karena profil sudah ada (409 conflict atau 400 dengan message tertentu), coba update
      if (e.toString().contains('already exists') || 
          e.toString().contains('sudah ada') ||
          e.toString().contains('409') ||
          e.toString().contains('Profile already exists') ||
          e.toString().contains('Profil sudah ada')) {
        try {
          // Fallback: coba update profil yang sudah ada
          final personalInfo = await repository.updatePersonalInfo(
            event.token,
            event.personalInfo,
          );
          emit(PersonalInfoUpdated(personalInfo));
          // Reload after update
          add(LoadPersonalInfo(event.token));
        } catch (updateError) {
          emit(PersonalInfoError(updateError.toString()));
        }
      } else {
        emit(PersonalInfoError(e.toString()));
      }
    }
  }
}
