/// Entity untuk health data
class HealthData {
  final int? systolic;
  final int? diastolic;
  final int? bloodSugar;
  final double? weight;
  final int? heartRate;
  final String? activity;
  final DateTime date;

  const HealthData({
    this.systolic,
    this.diastolic,
    this.bloodSugar,
    this.weight,
    this.heartRate,
    this.activity,
    required this.date,
  });

  /// Check if all fields are empty (excluding date)
  bool get isEmpty =>
      systolic == null &&
      diastolic == null &&
      bloodSugar == null &&
      weight == null &&
      heartRate == null &&
      (activity == null || activity!.isEmpty);

  /// Check if at least one field has value
  bool get isNotEmpty => !isEmpty;
}
