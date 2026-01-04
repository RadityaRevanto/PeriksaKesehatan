/// Entity untuk health warning/alert
class HealthWarning {
  final int id;
  final String title;
  final String message;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final String metricType; // 'tekanan_darah', 'gula_darah', 'berat_badan', 'aktivitas', 'detak_jantung'
  final String? value;
  final String? unit;
  final DateTime dateTime;
  final String statusText;
  final String? additionalInfo;

  const HealthWarning({
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
}

