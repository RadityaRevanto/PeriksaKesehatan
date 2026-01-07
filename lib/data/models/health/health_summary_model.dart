/// Model untuk health summary statistics dari API
class HealthSummaryModel {
  final BloodPressureSummary? bloodPressure;
  final BloodSugarSummary? bloodSugar;
  final WeightSummary? weight;
  final ActivitySummary? activity;
  final TrendCharts? trendCharts;
  final List<ReadingHistory>? readingHistory;

  HealthSummaryModel({
    this.bloodPressure,
    this.bloodSugar,
    this.weight,
    this.activity,
    this.trendCharts,
    this.readingHistory,
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
      trendCharts: json['trend_charts'] != null
          ? TrendCharts.fromJson(json['trend_charts'] as Map<String, dynamic>)
          : null,
      readingHistory: json['reading_history'] != null
          ? (json['reading_history'] as List)
              .map((e) => ReadingHistory.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bloodPressure != null) 'blood_pressure': bloodPressure!.toJson(),
      if (bloodSugar != null) 'blood_sugar': bloodSugar!.toJson(),
      if (weight != null) 'weight': weight!.toJson(),
      if (activity != null) 'activity': activity!.toJson(),
      if (trendCharts != null) 'trend_charts': trendCharts!.toJson(),
      if (readingHistory != null)
        'reading_history': readingHistory!.map((e) => e.toJson()).toList(),
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

/// Model untuk trend charts data
class TrendCharts {
  final List<BloodPressureTrend>? bloodPressure;
  final List<BloodSugarTrend>? bloodSugar;
  final List<WeightTrend>? weight;
  final List<ActivityTrend>? activity;

  TrendCharts({
    this.bloodPressure,
    this.bloodSugar,
    this.weight,
    this.activity,
  });

  factory TrendCharts.fromJson(Map<String, dynamic> json) {
    return TrendCharts(
      bloodPressure: json['blood_pressure'] != null
          ? (json['blood_pressure'] as List)
              .map((e) => BloodPressureTrend.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      bloodSugar: json['blood_sugar'] != null
          ? (json['blood_sugar'] as List)
              .map((e) => BloodSugarTrend.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      weight: json['weight'] != null
          ? (json['weight'] as List)
              .map((e) => WeightTrend.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      activity: json['activity'] != null
          ? (json['activity'] as List)
              .map((e) => ActivityTrend.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bloodPressure != null)
        'blood_pressure': bloodPressure!.map((e) => e.toJson()).toList(),
      if (bloodSugar != null)
        'blood_sugar': bloodSugar!.map((e) => e.toJson()).toList(),
      if (weight != null) 'weight': weight!.map((e) => e.toJson()).toList(),
      if (activity != null)
        'activity': activity!.map((e) => e.toJson()).toList(),
    };
  }
}

class BloodPressureTrend {
  final String date;
  final double systolic;
  final double diastolic;

  BloodPressureTrend({
    required this.date,
    required this.systolic,
    required this.diastolic,
  });

  factory BloodPressureTrend.fromJson(Map<String, dynamic> json) {
    return BloodPressureTrend(
      date: json['date'] as String,
      systolic: (json['systolic'] as num).toDouble(),
      diastolic: (json['diastolic'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'systolic': systolic,
      'diastolic': diastolic,
    };
  }
}

class BloodSugarTrend {
  final String date;
  final double avgValue;

  BloodSugarTrend({
    required this.date,
    required this.avgValue,
  });

  factory BloodSugarTrend.fromJson(Map<String, dynamic> json) {
    return BloodSugarTrend(
      date: json['date'] as String,
      avgValue: (json['avg_value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'avg_value': avgValue,
    };
  }
}

class WeightTrend {
  final String date;
  final double weight;

  WeightTrend({
    required this.date,
    required this.weight,
  });

  factory WeightTrend.fromJson(Map<String, dynamic> json) {
    return WeightTrend(
      date: json['date'] as String,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'weight': weight,
    };
  }
}

class ActivityTrend {
  final String date;
  final int steps;
  final int calories;

  ActivityTrend({
    required this.date,
    required this.steps,
    required this.calories,
  });

  factory ActivityTrend.fromJson(Map<String, dynamic> json) {
    return ActivityTrend(
      date: json['date'] as String,
      steps: json['steps'] as int,
      calories: json['calories'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'steps': steps,
      'calories': calories,
    };
  }
}

/// Model untuk reading history data
class ReadingHistory {
  final int id;
  final DateTime dateTime;
  final String metricType;
  final String value;
  final String? context;
  final String status;
  final String? notes;

  ReadingHistory({
    required this.id,
    required this.dateTime,
    required this.metricType,
    required this.value,
    this.context,
    required this.status,
    this.notes,
  });

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      id: json['id'] as int,
      dateTime: DateTime.parse(json['date_time'] as String),
      metricType: json['metric_type'] as String,
      value: json['value'] as String,
      context: json['context'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_time': dateTime.toIso8601String(),
      'metric_type': metricType,
      'value': value,
      if (context != null) 'context': context,
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }
}

