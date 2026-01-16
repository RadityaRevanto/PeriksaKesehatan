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
  final double? height;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? recordDate; // The date for which this health data is recorded

  HealthDataModel({
    this.id,
    this.userId,
    this.systolic,
    this.diastolic,
    this.bloodSugar,
    this.weight,
    this.heartRate,
    this.activity,
    this.height,
    this.createdAt,
    this.updatedAt,
    this.recordDate,
  });

  /// Convert to JSON untuk request (hanya field yang diperlukan)
  Map<String, dynamic> toJson() {
    // Use recordDate if available, otherwise use createdAt, otherwise use DateTime.now()
    final dateToUse = recordDate ?? createdAt ?? DateTime.now();
    
    // CRITICAL: Use local date components to avoid timezone conversion issues
    // toIso8601String() converts to UTC which causes date to shift backwards in UTC+ timezones
    final dateStr = '${dateToUse.year.toString().padLeft(4, '0')}-${dateToUse.month.toString().padLeft(2, '0')}-${dateToUse.day.toString().padLeft(2, '0')}';
    
    return {
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (bloodSugar != null) 'blood_sugar': bloodSugar,
      if (weight != null) 'weight': weight,
      if (heartRate != null) 'heart_rate': heartRate,
      if (activity != null) 'activity': activity,
      if (height != null) 'height': height!.round(),
      'record_date': dateStr, // Format: YYYY-MM-DD using local date components
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
      // Try 'height' first, then 'tinggi_badan'
      height: (json['height'] as num?)?.toDouble() ?? (json['tinggi_badan'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      recordDate: json['record_date'] != null
          ? _parseDateOnly(json['record_date'] as String)
          : null,
    );
  }

  /// Parse date-only string (YYYY-MM-DD) to avoid timezone conversion issues
  static DateTime? _parseDateOnly(String dateStr) {
    try {
      // If it's just a date (YYYY-MM-DD), parse components manually
      if (dateStr.length == 10 && dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[0]), // year
            int.parse(parts[1]), // month
            int.parse(parts[2]), // day
            12, // Set to noon to avoid timezone edge cases
          );
        }
      }
      // Fallback to DateTime.parse for full ISO8601 strings
      return DateTime.parse(dateStr);
    } catch (e) {
      print('Error parsing date: $dateStr - $e');
      return null;
    }
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
      height: height,
      date: recordDate ?? createdAt ?? DateTime.now(),
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
      height: entity.height,
      recordDate: entity.date, // CRITICAL: Preserve the original date from entity
    );
  }
}
