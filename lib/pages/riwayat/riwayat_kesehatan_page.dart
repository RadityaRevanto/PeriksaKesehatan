import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/pdf_report_service.dart';
import 'widget/filter_data_section.dart';
import 'widget/ringkasan_statistik_section.dart';
import 'widget/grafik_tren_section.dart';
import 'widget/catatan_pembacaan_section.dart';
import 'widget/informasi_medis_section.dart';

class RiwayatKesehatanPage extends StatefulWidget {
  const RiwayatKesehatanPage({super.key});

  @override
  State<RiwayatKesehatanPage> createState() => _RiwayatKesehatanPageState();
}

class _RiwayatKesehatanPageState extends State<RiwayatKesehatanPage> {
  String? _selectedTimeRange = '7 Hari';
  String? _selectedMetricType = 'Tekanan Darah';

  void _resetFilters() {
    setState(() {
      _selectedTimeRange = '7 Hari';
      _selectedMetricType = 'Tekanan Darah';
    });
  }

  String _getTimeRangeLabel() {
    switch (_selectedTimeRange) {
      case '7 Hari':
        return '7 hari terakhir';
      case '30 Hari':
        return '30 hari terakhir';
      case '3 Bulan':
        return '3 bulan terakhir';
      case 'Custom':
        return 'Periode kustom';
      default:
        return '7 hari terakhir';
    }
  }

  List<Map<String, dynamic>> _getReadingNotes() {
    return [
      {
        'date': 'Sabtu, 13 Jan 2025',
        'time': '11:20 AM',
        'status': 'Abnormal',
        'statusColor': AppColors.error,
        'statusBgColor': AppColors.error.withOpacity(0.1),
        'metrics': [
          {'label': 'Tekanan Darah', 'value': '145/92'},
          {'label': 'Detak Jantung', 'value': '88 bpm'},
        ],
        'note': 'Tekanan darah tinggi. Segera konsultasi dengan tenaga medis.',
        'noteIcon': Icons.error_outline,
        'noteColor': AppColors.error,
        'noteBgColor': AppColors.error.withOpacity(0.1),
        'hasBorder': true,
        'borderColor': AppColors.error.withOpacity(0.3),
        'hasNote': true,
      },
      {
        'date': 'Sabtu, 13 Jan 2025',
        'time': '07:45 AM',
        'status': 'Normal',
        'statusColor': AppColors.success,
        'statusBgColor': AppColors.success.withOpacity(0.1),
        'metrics': [
          {'label': 'Gula Darah', 'value': '98 mg/dL'},
          {'label': 'Puasa', 'value': '8 jam'},
        ],
        'hasBorder': true,
        'borderColor': AppColors.success.withOpacity(0.3),
        'hasNote': false,
      },
      {
        'date': 'Jumat, 12 Jan 2025',
        'time': '10:30 AM',
        'status': 'Normal',
        'statusColor': AppColors.success,
        'statusBgColor': AppColors.success.withOpacity(0.1),
        'metrics': [
          {'label': 'Berat Badan', 'value': '65.2 kg'},
          {'label': 'BMI', 'value': '23.4'},
        ],
        'hasBorder': true,
        'borderColor': AppColors.success.withOpacity(0.3),
        'hasNote': false,
      },
      {
        'date': 'Kamis, 11 Jan 2025',
        'time': '06:00 PM',
        'status': 'Normal',
        'statusColor': AppColors.success,
        'statusBgColor': AppColors.success.withOpacity(0.1),
        'metrics': [
          {'label': 'Aktivitas', 'value': '9,234 langkah'},
          {'label': 'Kalori', 'value': '412 kcal'},
        ],
        'note': 'Jalan sore di taman selama 45 menit.',
        'noteIcon': Icons.directions_walk,
        'noteColor': AppColors.textSecondary,
        'noteBgColor': AppColors.success.withOpacity(0.1),
        'hasBorder': true,
        'borderColor': AppColors.success.withOpacity(0.3),
        'hasNote': true,
      },
      {
        'date': 'Senin, 15 Jan 2025',
        'time': '08:30 AM',
        'status': 'Normal',
        'statusColor': AppColors.success,
        'statusBgColor': AppColors.success.withOpacity(0.1),
        'metrics': [
          {'label': 'Tekanan Darah', 'value': '120/80'},
          {'label': 'Detak Jantung', 'value': '72 bpm'},
        ],
        'note': 'Pengukuran pagi setelah bangun tidur. Kondisi tubuh rileks.',
        'noteIcon': Icons.monitor_heart_outlined,
        'noteColor': AppColors.textSecondary,
        'noteBgColor': Colors.grey[100]!,
        'hasBorder': true,
        'borderColor': AppColors.success.withOpacity(0.3),
        'hasNote': true,
      },
      {
        'date': 'Senin, 15 Jan 2025',
        'time': '03:45 PM',
        'status': 'Perhatian',
        'statusColor': AppColors.warning,
        'statusBgColor': AppColors.warning.withOpacity(0.1),
        'metrics': [
          {'label': 'Gula Darah', 'value': '145 mg/dL'},
          {'label': 'Setelah Makan', 'value': '2 jam'},
        ],
        'note': 'Kadar gula sedikit tinggi. Disarankan konsultasi dengan dokter.',
        'noteIcon': Icons.warning_amber_rounded,
        'noteColor': AppColors.warning,
        'noteBgColor': AppColors.warning.withOpacity(0.1),
        'hasBorder': false,
        'hasNote': true,
      },
      {
        'date': 'Minggu, 14 Jan 2025',
        'time': '09:15 AM',
        'status': 'Normal',
        'statusColor': AppColors.success,
        'statusBgColor': AppColors.success.withOpacity(0.1),
        'metrics': [
          {'label': 'Tekanan Darah', 'value': '118/78'},
          {'label': 'Detak Jantung', 'value': '68 bpm'},
        ],
        'note': 'Pengukuran rutin pagi hari. Semua nilai dalam batas normal.',
        'noteIcon': Icons.monitor_heart_outlined,
        'noteColor': AppColors.textSecondary,
        'noteBgColor': Colors.grey[100]!,
        'hasBorder': true,
        'borderColor': AppColors.success.withOpacity(0.3),
        'hasNote': true,
      },
    ];
  }

  Future<void> _downloadMedicalReport(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get health records
      final healthRecords = _getReadingNotes();
      
      // Calculate date range based on selected time range
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      switch (_selectedTimeRange) {
        case '7 Hari':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case '30 Hari':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case '3 Bulan':
          startDate = now.subtract(const Duration(days: 90));
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      // Generate and download PDF
      await PdfReportService.generateAndDownloadReport(
        patientName: 'Pasien', // TODO: Get from user profile
        patientAge: 30, // TODO: Get from user profile
        patientGender: 'Laki-laki', // TODO: Get from user profile
        healthRecords: healthRecords,
        startDate: startDate,
        endDate: endDate,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan medis berhasil diunduh'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh laporan: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showCustomDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    ).then((dateRange) {
      if (dateRange != null) {
        setState(() {
          _selectedTimeRange = 'Custom';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        title: Text(
          'Riwayat Kesehatan',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          // Download Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Implementasi download
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          // Share Button
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Implementasi share
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FilterDataSection(
              selectedTimeRange: _selectedTimeRange,
              selectedMetricType: _selectedMetricType,
              onTimeRangeChanged: (value) {
                setState(() {
                  _selectedTimeRange = value;
                });
              },
              onMetricTypeChanged: (value) {
                setState(() {
                  _selectedMetricType = value;
                });
              },
              onReset: _resetFilters,
              onCustomDatePicker: _showCustomDatePicker,
            ),
            const SizedBox(height: 20),
            
            RingkasanStatistikSection(
              timeRangeLabel: _getTimeRangeLabel(),
            ),
            const SizedBox(height: 20),
            
            const GrafikTrenSection(),
            const SizedBox(height: 20),
            
            CatatanPembacaanSection(
              readingNotes: _getReadingNotes(),
              onFilterTap: () {
                // TODO: Implementasi filter
              },
            ),
            const SizedBox(height: 20),
            
            InformasiMedisSection(
              onDownloadTap: () => _downloadMedicalReport(context),
            ),
            
            const SizedBox(height: 20), // Extra spacing at bottom
          ],
        ),
      ),
    );
  }
}