import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfReportService {
  /// Generate dan download laporan medis dalam format PDF
  /// 
  /// [patientName] - Nama pasien
  /// [patientAge] - Umur pasien
  /// [patientGender] - Jenis kelamin pasien
  /// [healthRecords] - List data kesehatan
  /// [startDate] - Tanggal mulai periode laporan
  /// [endDate] - Tanggal akhir periode laporan
  static Future<void> generateAndDownloadReport({
    required String patientName,
    required int patientAge,
    required String patientGender,
    required List<Map<String, dynamic>> healthRecords,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Generate PDF document
      final pdf = await _generatePdfDocument(
        patientName: patientName,
        patientAge: patientAge,
        patientGender: patientGender,
        healthRecords: healthRecords,
        startDate: startDate,
        endDate: endDate,
      );

      // Save PDF to file
      final file = await _savePdfToFile(pdf, patientName);

      // Share/Download PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Laporan Medis - $patientName',
        subject: 'Laporan Kesehatan',
      );
    } catch (e) {
      throw Exception('Gagal membuat laporan PDF: $e');
    }
  }

  /// Generate PDF document dengan konten laporan medis
  static Future<pw.Document> _generatePdfDocument({
    required String patientName,
    required int patientAge,
    required String patientGender,
    required List<Map<String, dynamic>> healthRecords,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(patientName, patientAge, patientGender),
            
            pw.SizedBox(height: 20),
            
            // Periode Laporan
            _buildReportPeriod(startDate, endDate),
            
            pw.SizedBox(height: 20),
            
            // Ringkasan Statistik
            _buildSummaryStatistics(healthRecords),
            
            pw.SizedBox(height: 20),
            
            // Detail Catatan Kesehatan
            _buildHealthRecordsDetail(healthRecords),
            
            pw.SizedBox(height: 20),
            
            // Footer
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Format tanggal ke format Indonesia
  static String _formatDateIndonesian(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Build header PDF
  static pw.Widget _buildHeader(
    String patientName,
    int patientAge,
    String patientGender,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN MEDIS',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Periksa Kesehatan',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Text(
              _formatDateIndonesian(DateTime.now()),
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.Divider(color: PdfColors.green700, thickness: 2),
        pw.SizedBox(height: 16),
        pw.Text(
          'INFORMASI PASIEN',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Text(
              'Nama: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(patientName),
            pw.SizedBox(width: 20),
            pw.Text(
              'Umur: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('$patientAge tahun'),
            pw.SizedBox(width: 20),
            pw.Text(
              'Jenis Kelamin: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(patientGender),
          ],
        ),
      ],
    );
  }

  /// Build periode laporan
  static pw.Widget _buildReportPeriod(
    DateTime startDate,
    DateTime endDate,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.green300),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'Periode Laporan: ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.Text(
            '${_formatDateIndonesian(startDate)} - ${_formatDateIndonesian(endDate)}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Build ringkasan statistik
  static pw.Widget _buildSummaryStatistics(
    List<Map<String, dynamic>> healthRecords,
  ) {
    // Hitung statistik
    int totalRecords = healthRecords.length;
    int normalCount = healthRecords.where((r) => r['status'] == 'Normal').length;
    int abnormalCount = healthRecords.where((r) => r['status'] == 'Abnormal').length;
    int warningCount = healthRecords.where((r) => r['status'] == 'Perhatian').length;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RINGKASAN STATISTIK',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('Total Catatan', totalRecords.toString(), PdfColors.blue700),
            _buildStatCard('Normal', normalCount.toString(), PdfColors.green700),
            _buildStatCard('Abnormal', abnormalCount.toString(), PdfColors.red700),
            _buildStatCard('Perhatian', warningCount.toString(), PdfColors.orange700),
          ],
        ),
      ],
    );
  }

  /// Build statistik card
  static pw.Widget _buildStatCard(String label, String value, PdfColor color) {
    // Use predefined light colors for background
    PdfColor lightColor;
    PdfColor borderColor;
    
    if (color == PdfColors.blue700) {
      lightColor = PdfColors.blue50;
      borderColor = PdfColors.blue300;
    } else if (color == PdfColors.green700) {
      lightColor = PdfColors.green50;
      borderColor = PdfColors.green300;
    } else if (color == PdfColors.red700) {
      lightColor = PdfColors.red50;
      borderColor = PdfColors.red300;
    } else if (color == PdfColors.orange700) {
      lightColor = PdfColors.orange50;
      borderColor = PdfColors.orange300;
    } else {
      lightColor = PdfColors.grey100;
      borderColor = PdfColors.grey300;
    }
    
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: borderColor),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build detail catatan kesehatan
  static pw.Widget _buildHealthRecordsDetail(
    List<Map<String, dynamic>> healthRecords,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETAIL CATATAN KESEHATAN',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 12),
        ...healthRecords.map((record) => _buildRecordItem(record)),
      ],
    );
  }

  /// Build item catatan kesehatan
  static pw.Widget _buildRecordItem(
    Map<String, dynamic> record,
  ) {
    final status = record['status'] as String? ?? 'Unknown';
    final statusColor = _getStatusColor(status);
    final date = record['date'] as String? ?? '';
    final time = record['time'] as String? ?? '';
    final metrics = record['metrics'] as List<dynamic>? ?? [];
    final note = record['note'] as String?;
    final hasNote = record['hasNote'] as bool? ?? false;

    // Get border color based on status
    PdfColor borderColor = PdfColors.grey300;
    if (record['hasBorder'] == true) {
      if (status == 'Normal') {
        borderColor = PdfColors.green300;
      } else if (status == 'Abnormal') {
        borderColor = PdfColors.red300;
      } else if (status == 'Perhatian') {
        borderColor = PdfColors.orange300;
      }
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: borderColor,
          width: record['hasBorder'] == true ? 2 : 0,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header dengan tanggal, waktu, dan status
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    date,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.Text(
                    time,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _getStatusBackgroundColor(status),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  status,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          
          // Metrics
          ...metrics.map((metric) {
            final label = metric['label'] as String? ?? '';
            final value = metric['value'] as String? ?? '';
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Text(
                    '$label: ',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    value,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            );
          }),
          
          // Note jika ada
          if (hasNote && note != null && note.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.yellow50,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                note,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get warna status
  static PdfColor _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return PdfColors.green700;
      case 'Abnormal':
        return PdfColors.red700;
      case 'Perhatian':
        return PdfColors.orange700;
      default:
        return PdfColors.grey700;
    }
  }

  /// Get background color untuk status badge
  static PdfColor _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Normal':
        return PdfColors.green50;
      case 'Abnormal':
        return PdfColors.red50;
      case 'Perhatian':
        return PdfColors.orange50;
      default:
        return PdfColors.grey100;
    }
  }

  /// Build footer
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 12),
        pw.Text(
          'Laporan ini dibuat secara otomatis oleh aplikasi Periksa Kesehatan.',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
            fontStyle: pw.FontStyle.italic,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Untuk informasi lebih lanjut, silakan konsultasi dengan tenaga medis profesional.',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
            fontStyle: pw.FontStyle.italic,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// Save PDF ke file
  static Future<File> _savePdfToFile(pw.Document pdf, String patientName) async {
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final fileName = 'Laporan_Medis_${patientName.replaceAll(' ', '_')}_$timestamp.pdf';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Preview PDF sebelum download
  static Future<void> previewPdf({
    required String patientName,
    required int patientAge,
    required String patientGender,
    required List<Map<String, dynamic>> healthRecords,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final pdf = await _generatePdfDocument(
        patientName: patientName,
        patientAge: patientAge,
        patientGender: patientGender,
        healthRecords: healthRecords,
        startDate: startDate,
        endDate: endDate,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      throw Exception('Gagal menampilkan preview PDF: $e');
    }
  }
}

