import 'package:equatable/equatable.dart';

/// Entity untuk health alert
class HealthAlert extends Equatable {
  final String alertType;
  final String category;
  final String value;
  final String label;
  final String status;
  final DateTime recordedAt;
  final String explanation;
  final List<String> immediateActions;
  final List<String> medicalAttention;
  final List<String> managementTips;
  final List<String> educationVideos;

  const HealthAlert({
    required this.alertType,
    required this.category,
    required this.value,
    required this.label,
    required this.status,
    required this.recordedAt,
    required this.explanation,
    required this.immediateActions,
    required this.medicalAttention,
    required this.managementTips,
    required this.educationVideos,
  });

  @override
  List<Object?> get props => [
        alertType,
        category,
        value,
        label,
        status,
        recordedAt,
        explanation,
        immediateActions,
        medicalAttention,
        managementTips,
        educationVideos,
      ];
}

/// Entity untuk response health alerts
class HealthAlerts extends Equatable {
  final List<HealthAlert> alerts;

  const HealthAlerts({
    required this.alerts,
  });

  @override
  List<Object?> get props => [alerts];
}
