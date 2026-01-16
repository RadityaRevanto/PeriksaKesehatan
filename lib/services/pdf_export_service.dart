import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:periksa_kesehatan/data/models/health/health_summary_model.dart';

class PdfExportService {
  /// Generate PDF dari data riwayat kesehatan
  Future<File> generateHealthReportPdf({
    required HealthSummaryModel? summary,
    required String timeRange,
    required String userName,
  }) async {
    final pdf = pw.Document();

    // Format tanggal
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');

    // Tentukan judul berdasarkan time range
    String title = '';
    if (timeRange == '7Days') {
      title = 'Laporan Kesehatan 7 Hari Terakhir';
    } else if (timeRange == '1Month' || timeRange == '30Days') {
      title = 'Laporan Kesehatan 30 Hari Terakhir';
    } else {
      title = 'Laporan Kesehatan 3 Bulan Terakhir';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN KESEHATAN',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  title,
                  style: const pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Divider(thickness: 2, color: PdfColors.green700),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Info Pasien
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Informasi Pasien',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                _buildInfoRow('Nama', userName),
                _buildInfoRow('Tanggal Cetak', dateFormat.format(now)),
                _buildInfoRow('Waktu Cetak', timeFormat.format(now)),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Ringkasan Kesehatan
          if (summary != null) ...[
            pw.Text(
              'Ringkasan Kesehatan',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),

            // Tekanan Darah
            if (summary.bloodPressure != null)
              _buildMetricSection(
                'Tekanan Darah',
                [
                  'Rata-rata Sistolik: ${summary.bloodPressure!.avgSystolic.toStringAsFixed(1)} mmHg',
                  'Rata-rata Diastolik: ${summary.bloodPressure!.avgDiastolic.toStringAsFixed(1)} mmHg',
                  'Status: ${summary.bloodPressure!.systolicStatus}',
                  'Rentang Normal: ${summary.bloodPressure!.normalRange}',
                ],
              ),

            pw.SizedBox(height: 16),

            // Gula Darah
            if (summary.bloodSugar != null)
              _buildMetricSection(
                'Gula Darah',
                [
                  'Rata-rata: ${summary.bloodSugar!.avgValue.toStringAsFixed(1)} mg/dL',
                  'Status: ${summary.bloodSugar!.status}',
                  'Rentang Normal: ${summary.bloodSugar!.normalRange}',
                ],
              ),

            pw.SizedBox(height: 16),

            // Berat Badan
            if (summary.weight != null)
              _buildMetricSection(
                'Berat Badan',
                [
                  'Rata-rata: ${summary.weight!.avgWeight.toStringAsFixed(1)} kg',
                  'Tren: ${summary.weight!.trend}',
                ],
              ),

            pw.SizedBox(height: 24),

            // Riwayat Pembacaan
            if (summary.readingHistory != null && summary.readingHistory!.isNotEmpty) ...[
              pw.Text(
                'Riwayat Pembacaan Detail',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              // Tabel riwayat
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Tanggal', isHeader: true),
                      _buildTableCell('Metrik', isHeader: true),
                      _buildTableCell('Nilai', isHeader: true),
                      _buildTableCell('Status', isHeader: true),
                    ],
                  ),
                  // Data rows
                  ...summary.readingHistory!.take(20).map((reading) {
                    final date = DateFormat('dd/MM/yyyy HH:mm').format(reading.dateTime);
                    return pw.TableRow(
                      children: [
                        _buildTableCell(date),
                        _buildTableCell(_getMetricName(reading.metricType)),
                        _buildTableCell(reading.value),
                        _buildTableCell(reading.status),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ],

          // Footer
          pw.SizedBox(height: 32),
          pw.Divider(thickness: 1, color: PdfColors.grey400),
          pw.SizedBox(height: 8),
          pw.Text(
            'Dokumen ini dibuat secara otomatis oleh Aplikasi Periksa Kesehatan',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    // Simpan PDF
    final output = await getTemporaryDirectory();
    final fileName = 'Laporan_Kesehatan_${timeRange}_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Build info row untuk informasi pasien
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(': $value'),
        ],
      ),
    );
  }

  /// Build section untuk setiap metrik kesehatan
  pw.Widget _buildMetricSection(String title, List<String> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 8),
          ...items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text('• $item', style: const pw.TextStyle(fontSize: 12)),
              )),
        ],
      ),
    );
  }

  /// Build cell untuk tabel
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Konversi metric type ke nama yang lebih readable
  String _getMetricName(String metricType) {
    switch (metricType) {
      case 'tekanan_darah':
        return 'Tekanan Darah';
      case 'gula_darah':
        return 'Gula Darah';
      case 'berat_badan':
        return 'Berat Badan';
      case 'detak_jantung':
        return 'Detak Jantung';
      case 'aktivitas':
        return 'Aktivitas';
      default:
        return metricType;
    }
  }

  /// Share atau print PDF
  Future<void> sharePdf(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }

  /// Print PDF langsung
  Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (format) async => await pdfFile.readAsBytes(),
    );
  }
}
