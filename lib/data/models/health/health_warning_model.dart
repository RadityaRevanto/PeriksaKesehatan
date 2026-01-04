import 'package:periksa_kesehatan/domain/entities/health_warning.dart';

/// Model untuk health warning response
class HealthWarningModel {
  final int id;
  final String title;
  final String message;
  final String severity;
  final String metricType;
  final String? value;
  final String? unit;
  final DateTime dateTime;
  final String statusText;
  final String? additionalInfo;

  HealthWarningModel({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.metricType,
    this.value,
    this.unit,
    required this.dateTime,
    required this.statusText,
    this.additionalInfo,
  });

  /// Convert from JSON response
  factory HealthWarningModel.fromJson(Map<String, dynamic> json) {
    return HealthWarningModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Peringatan',
      message: json['message'] as String,
      severity: json['severity'] as String? ?? 'medium',
      metricType: json['metric_type'] as String? ?? json['metricType'] as String? ?? '',
      value: json['value'] as String?,
      unit: json['unit'] as String?,
      dateTime: json['date_time'] != null
          ? DateTime.parse(json['date_time'] as String)
          : (json['dateTime'] != null
              ? DateTime.parse(json['dateTime'] as String)
              : DateTime.now()),
      statusText: json['status_text'] as String? ?? json['statusText'] as String? ?? '',
      additionalInfo: json['additional_info'] as String? ?? json['additionalInfo'] as String?,
    );
  }

  /// Convert to entity
  HealthWarning toEntity() {
    return HealthWarning(
      id: id,
      title: title,
      message: message,
      severity: severity,
      metricType: metricType,
      value: value,
      unit: unit,
      dateTime: dateTime,
      statusText: statusText,
      additionalInfo: additionalInfo,
    );
  }
}

