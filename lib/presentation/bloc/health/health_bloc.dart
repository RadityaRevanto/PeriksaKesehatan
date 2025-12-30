import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:periksa_kesehatan/data/repositories/health_repository.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_state.dart';

/// BLoC untuk mengelola health data state
class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final HealthRepository _healthRepository;

  HealthBloc({required HealthRepository healthRepository})
      : _healthRepository = healthRepository,
        super(const HealthInitial()) {
    on<SaveHealthDataEvent>(_onSaveHealthData);
    on<FetchHealthDataEvent>(_onFetchHealthData);
    on<ResetHealthStateEvent>(_onResetHealthState);
  }

  /// Handle save health data event
  Future<void> _onSaveHealthData(
    SaveHealthDataEvent event,
    Emitter<HealthState> emit,
  ) async {
    emit(const HealthLoading());
    
    try {
      // Validate: at least one field should have value
      if (event.healthData.isEmpty) {
        emit(const HealthError(
          message: 'Minimal satu data kesehatan harus diisi',
        ));
        return;
      }

      final result = await _healthRepository.saveHealthData(event.healthData);

      result.fold(
        (failure) => emit(HealthError(message: failure.message)),
        (healthData) => emit(
          HealthSaveSuccess(
            healthData: healthData,
            message: 'Data kesehatan berhasil disimpan',
          ),
        ),
      );
    } catch (e) {
      emit(HealthError(message: e.toString()));
    }
  }

  /// Handle fetch health data event
  Future<void> _onFetchHealthData(
    FetchHealthDataEvent event,
    Emitter<HealthState> emit,
  ) async {
    emit(const HealthLoading());
    
    try {
      // Backend selalu return data terbaru
      final result = await _healthRepository.getHealthData();

      result.fold(
        (failure) => emit(HealthError(message: failure.message)),
        (healthData) {
          if (healthData == null) {
            emit(const HealthDataEmpty());
          } else {
            emit(HealthDataLoaded(healthData: healthData));
          }
        },
      );
    } catch (e) {
      emit(HealthError(message: e.toString()));
    }
  }

  /// Handle reset state event
  void _onResetHealthState(
    ResetHealthStateEvent event,
    Emitter<HealthState> emit,
  ) {
    emit(const HealthInitial());
  }
}
