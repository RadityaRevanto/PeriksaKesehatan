import 'package:equatable/equatable.dart';
import 'package:periksa_kesehatan/data/models/health/health_summary_model.dart';
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

  const HealthDataLoaded({required this.healthData});

  @override
  List<Object?> get props => [healthData];
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

/// Error state
class HealthError extends HealthState {
  final String message;

  const HealthError({required this.message});

  @override
  List<Object?> get props => [message];
}
