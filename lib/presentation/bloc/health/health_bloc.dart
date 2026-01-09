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
    on<FetchHealthHistoryEvent>(_onFetchHealthHistory);
    on<FetchHealthAlertsEvent>(_onFetchHealthAlerts);
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

  /// Handle fetch health history event
  Future<void> _onFetchHealthHistory(
    FetchHealthHistoryEvent event,
    Emitter<HealthState> emit,
  ) async {
    emit(const HealthLoading());
    
    try {
      final result = await _healthRepository.getHealthHistory(timeRange: event.timeRange);

      result.fold(
        (failure) => emit(HealthError(message: failure.message)),
        (summary) => emit(HealthHistoryLoaded(summary: summary)),
      );
    } catch (e) {
      emit(HealthError(message: e.toString()));
    }
  }

  /// Handle fetch health alerts event
  Future<void> _onFetchHealthAlerts(
    FetchHealthAlertsEvent event,
    Emitter<HealthState> emit,
  ) async {
    // Don't emit loading if we already have health data loaded
    // This prevents the UI from showing dashes while fetching alerts
    if (state is! HealthDataLoaded) {
      emit(const HealthLoading());
    }
    
    try {
      final result = await _healthRepository.checkHealthAlerts();

      result.fold(
        (failure) {
          // If we have existing health data, preserve it
          if (state is HealthDataLoaded) {
            // Keep the current state, just log the error
            print('Error fetching alerts: ${failure.message}');
          } else {
            emit(HealthError(message: failure.message));
          }
        },
        (alerts) {
          // If we already have health data loaded, update it with alerts
          if (state is HealthDataLoaded) {
            final currentState = state as HealthDataLoaded;
            emit(currentState.copyWith(alerts: alerts));
          } else {
            // If no health data yet, just emit alerts loaded
            emit(HealthAlertsLoaded(alerts: alerts));
          }
        },
      );
    } catch (e) {
      // If we have existing health data, preserve it
      if (state is HealthDataLoaded) {
        print('Error fetching alerts: ${e.toString()}');
      } else {
        emit(HealthError(message: e.toString()));
      }
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
