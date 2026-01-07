import 'package:periksa_kesehatan/domain/entities/health_alert.dart';

/// Model untuk health alert
class HealthAlertModel extends HealthAlert {
  const HealthAlertModel({
    required super.alertType,
    required super.category,
    required super.value,
    required super.label,
    required super.status,
    required super.recordedAt,
    required super.explanation,
    required super.immediateActions,
    required super.medicalAttention,
    required super.managementTips,
    required super.educationVideos,
  });

  factory HealthAlertModel.fromJson(Map<String, dynamic> json) {
    return HealthAlertModel(
      alertType: json['alert_type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
      status: json['status'] as String? ?? '',
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : DateTime.now(),
      explanation: json['explanation'] as String? ?? '',
      immediateActions: (json['immediate_actions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      medicalAttention: (json['medical_attention'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      managementTips: (json['management_tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      educationVideos: (json['education_videos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alert_type': alertType,
      'category': category,
      'value': value,
      'label': label,
      'status': status,
      'recorded_at': recordedAt.toIso8601String(),
      'explanation': explanation,
      'immediate_actions': immediateActions,
      'medical_attention': medicalAttention,
      'management_tips': managementTips,
      'education_videos': educationVideos,
    };
  }
}

/// Model untuk response health alerts
class HealthAlertsModel extends HealthAlerts {
  const HealthAlertsModel({
    required super.alerts,
  });

  factory HealthAlertsModel.fromJson(Map<String, dynamic> json) {
    final alertsList = (json['alerts'] as List<dynamic>?)
            ?.map((e) => HealthAlertModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return HealthAlertsModel(
      alerts: alertsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alerts': alerts.map((e) => (e as HealthAlertModel).toJson()).toList(),
    };
  }
}
