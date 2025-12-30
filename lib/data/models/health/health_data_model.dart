import 'package:periksa_kesehatan/domain/entities/health_data.dart';

/// Model untuk health data response (termasuk id, user_id, timestamps)
class HealthDataModel {
  final int? id;
  final int? userId;
  final int? systolic;
  final int? diastolic;
  final int? bloodSugar;
  final double? weight;
  final int? heartRate;
  final String? activity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HealthDataModel({
    this.id,
    this.userId,
    this.systolic,
    this.diastolic,
    this.bloodSugar,
    this.weight,
    this.heartRate,
    this.activity,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON untuk request (hanya field yang diperlukan)
  Map<String, dynamic> toJson() {
    return {
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (bloodSugar != null) 'blood_sugar': bloodSugar,
      if (weight != null) 'weight': weight,
      if (heartRate != null) 'heart_rate': heartRate,
      if (activity != null) 'activity': activity,
      'date': DateTime.now().toIso8601String().split('T')[0], // Format: YYYY-MM-DD
    };
  }

  /// Convert from JSON response
  factory HealthDataModel.fromJson(Map<String, dynamic> json) {
    return HealthDataModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      systolic: json['systolic'] as int?,
      diastolic: json['diastolic'] as int?,
      bloodSugar: json['blood_sugar'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      heartRate: json['heart_rate'] as int?,
      activity: json['activity'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to entity
  HealthData toEntity() {
    return HealthData(
      systolic: systolic,
      diastolic: diastolic,
      bloodSugar: bloodSugar,
      weight: weight,
      heartRate: heartRate,
      activity: activity,
      date: createdAt ?? DateTime.now(),
    );
  }

  /// Create from entity (untuk request)
  factory HealthDataModel.fromEntity(HealthData entity) {
    return HealthDataModel(
      systolic: entity.systolic,
      diastolic: entity.diastolic,
      bloodSugar: entity.bloodSugar,
      weight: entity.weight,
      heartRate: entity.heartRate,
      activity: entity.activity,
    );
  }
}
