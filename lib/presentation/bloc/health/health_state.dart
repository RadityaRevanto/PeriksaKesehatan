import 'package:equatable/equatable.dart';
import 'package:periksa_kesehatan/data/models/health/health_summary_model.dart';
import 'package:periksa_kesehatan/data/models/health/health_alert_model.dart';
import 'package:periksa_kesehatan/domain/entities/health_data.dart';

/// Base class untuk health states
abstract class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HealthInitial extends HealthState {
  const HealthInitial();
}

/// Loading state
class HealthLoading extends HealthState {
  const HealthLoading();
}

/// Success state ketika data berhasil disimpan
class HealthSaveSuccess extends HealthState {
  final HealthData healthData;
  final String message;

  const HealthSaveSuccess({
    required this.healthData,
    this.message = 'Data kesehatan berhasil disimpan',
  });

  @override
  List<Object?> get props => [healthData, message];
}

/// Success state ketika data berhasil di-fetch
class HealthDataLoaded extends HealthState {
  final HealthData? healthData;
  final HealthAlertsModel? alerts;

  const HealthDataLoaded({
    required this.healthData,
    this.alerts,
  });

  @override
  List<Object?> get props => [healthData, alerts];
  
  /// Copy with method untuk update alerts tanpa mengubah healthData
  HealthDataLoaded copyWith({
    HealthData? healthData,
    HealthAlertsModel? alerts,
  }) {
    return HealthDataLoaded(
      healthData: healthData ?? this.healthData,
      alerts: alerts ?? this.alerts,
    );
  }
}

/// Empty state ketika tidak ada data
class HealthDataEmpty extends HealthState {
  const HealthDataEmpty();
}

/// Success state ketika health history summary berhasil di-fetch
class HealthHistoryLoaded extends HealthState {
  final HealthSummaryModel? summary;

  const HealthHistoryLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

/// Success state ketika health alerts berhasil di-fetch
class HealthAlertsLoaded extends HealthState {
  final HealthAlertsModel? alerts;

  const HealthAlertsLoaded({required this.alerts});

  @override
  List<Object?> get props => [alerts];
}

/// Error state
class HealthError extends HealthState {
  final String message;

  const HealthError({required this.message});

  @override
  List<Object?> get props => [message];
}
