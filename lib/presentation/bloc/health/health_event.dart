import 'package:equatable/equatable.dart';
import 'package:periksa_kesehatan/domain/entities/health_data.dart';

/// Base class untuk health events
abstract class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk menyimpan data kesehatan
class SaveHealthDataEvent extends HealthEvent {
  final HealthData healthData;

  const SaveHealthDataEvent({required this.healthData});

  @override
  List<Object?> get props => [healthData];
}

/// Event untuk fetch data kesehatan
class FetchHealthDataEvent extends HealthEvent {
  const FetchHealthDataEvent();
}

/// Event untuk reset state
class ResetHealthStateEvent extends HealthEvent {
  const ResetHealthStateEvent();
}

/// Event untuk fetch health history summary
class FetchHealthHistoryEvent extends HealthEvent {
  final String timeRange;
  
  const FetchHealthHistoryEvent({this.timeRange = '7Days'});
  
  @override
  List<Object?> get props => [timeRange];
}

/// Event untuk fetch health alerts
class FetchHealthAlertsEvent extends HealthEvent {
  const FetchHealthAlertsEvent();
}
