/// Model untuk health summary statistics dari API
class HealthSummaryModel {
  final BloodPressureSummary? bloodPressure;
  final BloodSugarSummary? bloodSugar;
  final WeightSummary? weight;
  final ActivitySummary? activity;

  HealthSummaryModel({
    this.bloodPressure,
    this.bloodSugar,
    this.weight,
    this.activity,
  });

  factory HealthSummaryModel.fromJson(Map<String, dynamic> json) {
    return HealthSummaryModel(
      bloodPressure: json['blood_pressure'] != null
          ? BloodPressureSummary.fromJson(json['blood_pressure'] as Map<String, dynamic>)
          : null,
      bloodSugar: json['blood_sugar'] != null
          ? BloodSugarSummary.fromJson(json['blood_sugar'] as Map<String, dynamic>)
          : null,
      weight: json['weight'] != null
          ? WeightSummary.fromJson(json['weight'] as Map<String, dynamic>)
          : null,
      activity: json['activity'] != null
          ? ActivitySummary.fromJson(json['activity'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bloodPressure != null) 'blood_pressure': bloodPressure!.toJson(),
      if (bloodSugar != null) 'blood_sugar': bloodSugar!.toJson(),
      if (weight != null) 'weight': weight!.toJson(),
      if (activity != null) 'activity': activity!.toJson(),
    };
  }
}

class BloodPressureSummary {
  final double avgSystolic;
  final double avgDiastolic;
  final double changePercent;
  final String systolicStatus;
  final String diastolicStatus;
  final String normalRange;

  BloodPressureSummary({
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.changePercent,
    required this.systolicStatus,
    required this.diastolicStatus,
    required this.normalRange,
  });

  factory BloodPressureSummary.fromJson(Map<String, dynamic> json) {
    return BloodPressureSummary(
      avgSystolic: (json['avg_systolic'] as num).toDouble(),
      avgDiastolic: (json['avg_diastolic'] as num).toDouble(),
      changePercent: (json['change_percent'] as num).toDouble(),
      systolicStatus: json['systolic_status'] as String,
      diastolicStatus: json['diastolic_status'] as String,
      normalRange: json['normal_range'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avg_systolic': avgSystolic,
      'avg_diastolic': avgDiastolic,
      'change_percent': changePercent,
      'systolic_status': systolicStatus,
      'diastolic_status': diastolicStatus,
      'normal_range': normalRange,
    };
  }
}

class BloodSugarSummary {
  final double avgValue;
  final double changePercent;
  final String status;
  final String normalRange;

  BloodSugarSummary({
    required this.avgValue,
    required this.changePercent,
    required this.status,
    required this.normalRange,
  });

  factory BloodSugarSummary.fromJson(Map<String, dynamic> json) {
    return BloodSugarSummary(
      avgValue: (json['avg_value'] as num).toDouble(),
      changePercent: (json['change_percent'] as num).toDouble(),
      status: json['status'] as String,
      normalRange: json['normal_range'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avg_value': avgValue,
      'change_percent': changePercent,
      'status': status,
      'normal_range': normalRange,
    };
  }
}

class WeightSummary {
  final double avgWeight;
  final String trend;
  final double changePercent;

  WeightSummary({
    required this.avgWeight,
    required this.trend,
    required this.changePercent,
  });

  factory WeightSummary.fromJson(Map<String, dynamic> json) {
    return WeightSummary(
      avgWeight: (json['avg_weight'] as num).toDouble(),
      trend: json['trend'] as String,
      changePercent: (json['change_percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avg_weight': avgWeight,
      'trend': trend,
      'change_percent': changePercent,
    };
  }
}

class ActivitySummary {
  final int totalSteps;
  final int totalCalories;
  final double changePercent;

  ActivitySummary({
    required this.totalSteps,
    required this.totalCalories,
    required this.changePercent,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      totalSteps: json['total_steps'] as int,
      totalCalories: json['total_calories'] as int,
      changePercent: (json['change_percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_steps': totalSteps,
      'total_calories': totalCalories,
      'change_percent': changePercent,
    };
  }
}

