import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/bloc/health/health_bloc.dart';
import '../../../presentation/bloc/health/health_event.dart';
import '../../../presentation/bloc/health/health_state.dart';
import '../../../data/models/health/health_summary_model.dart';
import 'widget/grafik_tren_section.dart' show BloodPressureChartPainter;

class DetailGrafikTrenPage extends StatefulWidget {
  const DetailGrafikTrenPage({super.key});

  @override
  State<DetailGrafikTrenPage> createState() => _DetailGrafikTrenPageState();
}

class _DetailGrafikTrenPageState extends State<DetailGrafikTrenPage> {
  String _selectedTimeRange = '7Days';

  @override
  void initState() {
    super.initState();
    // Fetch health history when page is initialized
    _fetchData();
  }

  void _fetchData() {
    context.read<HealthBloc>().add(FetchHealthHistoryEvent(timeRange: _selectedTimeRange));
  }

  void _onTimeRangeChanged(String newRange) {
    if (_selectedTimeRange != newRange) {
      setState(() {
        _selectedTimeRange = newRange;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Grafik Tren Kesehatan',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          if (state is HealthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HealthError) {
            // Check if error is due to empty data
            if (state.message.toLowerCase().contains('tidak ada data')) {
              return Center(
                 child: Text(
                  'Tidak ada Data',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                 ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          TrendCharts? trendCharts;
          if (state is HealthHistoryLoaded && state.summary != null) {
            trendCharts = state.summary!.trendCharts;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Section
                _buildFilterSection(),
                const SizedBox(height: 20),
                
                // Grafik Tekanan Darah
                _buildChartSection(
                  title: 'Grafik Tren - Tekanan Darah',
                  trendCharts: trendCharts,
                  chartType: ChartType.bloodPressure,
                ),
                const SizedBox(height: 16),
                // Grafik Gula Darah
                _buildChartSection(
                  title: 'Grafik Tren - Gula Darah',
                  trendCharts: trendCharts,
                  chartType: ChartType.bloodSugar,
                ),
                const SizedBox(height: 16),
                // Grafik Berat Badan
                _buildChartSection(
                  title: 'Grafik Tren - Berat Badan',
                  trendCharts: trendCharts,
                  chartType: ChartType.weight,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton('7 Hari', '7Days'),
          _buildFilterButton('30 Hari', '1Month'),
          _buildFilterButton('3 Bulan', '3Months'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final bool isSelected = _selectedTimeRange == value;
    return GestureDetector(
      onTap: () => _onTimeRangeChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required TrendCharts? trendCharts,
    required ChartType chartType,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(chartType),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildChart(trendCharts, chartType),
          ),
          const SizedBox(height: 16),
          _buildNormalRangeText(chartType),
        ],
      ),
    );
  }

  Widget _buildLegend(ChartType chartType) {
    switch (chartType) {
      case ChartType.bloodPressure:
        return Row(
          children: [
            _buildLegendItem(
              color: const Color(0xFF2E7D32),
              label: 'Sistolik',
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: const Color(0xFF0288D1),
              label: 'Diastolik',
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: Colors.grey[300]!,
              label: 'Range Normal',
            ),
          ],
        );
      case ChartType.bloodSugar:
        return Row(
          children: [
            _buildLegendItem(
              color: const Color(0xFFE91E63),
              label: 'Gula Darah',
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: Colors.grey[300]!,
              label: 'Normal Range',
            ),
          ],
        );
      case ChartType.weight:
        return Row(
          children: [
            _buildLegendItem(
              color: const Color(0xFFFF9800),
              label: 'Berat Badan',
            ),
          ],
        );
    }
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(TrendCharts? trendCharts, ChartType chartType) {
    if (trendCharts == null) {
      return Center(
        child: Text(
          'Tidak ada Data',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    switch (chartType) {
      case ChartType.bloodPressure:
        return _buildBloodPressureChart(trendCharts.bloodPressure);
      case ChartType.bloodSugar:
        return _buildBloodSugarChart(trendCharts.bloodSugar);
      case ChartType.weight:
        return _buildWeightChart(trendCharts.weight);
    }
  }

  Widget _buildBloodPressureChart(List<BloodPressureTrend>? data) {
    if (data == null || data.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada Data',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final List<Map<String, double>> chartData = [];
    final List<String> days = [];

    // Sort data if necessary, though usually backend does it. 
    // We assume data is in order or handle it in painter.
    
    for (var item in data) {
      chartData.add({
        'systolic': item.systolic,
        'diastolic': item.diastolic,
      });

      try {
        final date = DateTime.parse(item.date);
        String dayLabel;
        if (_selectedTimeRange == '7Days') {
          dayLabel = DateFormat('EEE', 'id_ID').format(date);
        } else {
           dayLabel = DateFormat('d MMM', 'id_ID').format(date);
        }
        days.add(dayLabel);
      } catch (e) {
        days.add(item.date);
      }
    }

    return Stack(
      children: [
        CustomPaint(
          painter: BloodPressureChartPainter(
            data: chartData,
            days: days,
            normalSystolicMin: 90,
            normalSystolicMax: 120,
            normalDiastolicMin: 60,
            normalDiastolicMax: 80,
          ),
          size: Size.infinite,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildXAxisLabels(days),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodSugarChart(List<BloodSugarTrend>? data) {
    if (data == null || data.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada Data',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final List<double> chartData = [];
    final List<String> days = [];

    for (var item in data) {
      chartData.add(item.avgValue);

      try {
        final date = DateTime.parse(item.date);
        String dayLabel;
        if (_selectedTimeRange == '7Days') {
          dayLabel = DateFormat('EEE', 'id_ID').format(date);
        } else {
           dayLabel = DateFormat('d MMM', 'id_ID').format(date);
        }
        days.add(dayLabel);
      } catch (e) {
        days.add(item.date);
      }
    }

    return Stack(
      children: [
        CustomPaint(
          painter: BloodSugarChartPainter(
            data: chartData,
            days: days,
            normalMin: 70,
            normalMax: 100,
          ),
          size: Size.infinite,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildXAxisLabels(days),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart(List<WeightTrend>? data) {
    if (data == null || data.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada Data',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final List<double> chartData = [];
    final List<String> days = [];

    for (var item in data) {
      chartData.add(item.weight);

      try {
        final date = DateTime.parse(item.date);
        String dayLabel;
        if (_selectedTimeRange == '7Days') {
          dayLabel = DateFormat('EEE', 'id_ID').format(date);
        } else {
           dayLabel = DateFormat('d MMM', 'id_ID').format(date);
        }
        days.add(dayLabel);
      } catch (e) {
        days.add(item.date);
      }
    }

    return Stack(
      children: [
        CustomPaint(
          painter: WeightChartPainter(
            data: chartData,
            days: days,
          ),
          size: Size.infinite,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildXAxisLabels(days),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildXAxisLabels(List<String> days) {
    if (days.isEmpty) return [];
    
    if (days.length <= 7) {
      return days.map((day) => SizedBox(
        width: 40,
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      )).toList();
    }
    
    // For many items, just show first and last to avoid clutter
    return [
      Text(days.first, style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textPrimary)),
      Text("...", style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textPrimary)),
      Text(days.last, style: GoogleFonts.nunitoSans(fontSize: 11, color: AppColors.textPrimary)),
    ];
  }

  Widget _buildNormalRangeText(ChartType chartType) {
    switch (chartType) {
      case ChartType.bloodPressure:
        return Text(
          'Range Normal: 90-120 / 60-80 mmHg',
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        );
      case ChartType.bloodSugar:
        return Text(
          'Range Normal: 70-100 mg/dL',
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        );
      case ChartType.weight:
        return Text(
          'Berat badan ideal bervariasi sesuai tinggi badan',
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        );
    }
  }
}

enum ChartType {
  bloodPressure,
  bloodSugar,
  weight,
}

// Chart Painter for Blood Sugar
class BloodSugarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> days;
  final double normalMin;
  final double normalMax;

  BloodSugarChartPainter({
    required this.data,
    required this.days,
    required this.normalMin,
    required this.normalMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final chartPadding = 20.0;
    final chartWidth = size.width - (chartPadding * 2);
    final chartHeight = size.height - 30;
    
    if (days.isEmpty) return;
    
    final barWidth = chartWidth / days.length;
    final spacing = barWidth * 0.2;

    double maxValue = 200;
    double minValue = 0;
    double range = maxValue - minValue;

    // Draw normal range
    final normalRangeTop = chartHeight - ((normalMax - minValue) / range * chartHeight);
    final normalRangeBottom = chartHeight - ((normalMin - minValue) / range * chartHeight);

    paint.color = Colors.grey[200]!.withOpacity(0.5);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          chartPadding,
          normalRangeTop,
          size.width - chartPadding,
          normalRangeBottom,
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final x = chartPadding + (i * barWidth) + (spacing / 2);
      final barGroupWidth = barWidth - spacing;

      final valueHeight = ((data[i] - minValue) / range) * chartHeight;
      final valueY = chartHeight - valueHeight;

      paint.color = const Color(0xFFE91E63);
      paint.style = PaintingStyle.fill;
      final barWidthFinal = barGroupWidth * 0.6;
      final barX = x + (barGroupWidth - barWidthFinal) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            barX,
            valueY,
            barWidthFinal,
            chartHeight - valueY,
          ),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Chart Painter for Weight
class WeightChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> days;

  WeightChartPainter({
    required this.data,
    required this.days,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final chartPadding = 20.0;
    final chartWidth = size.width - (chartPadding * 2);
    final chartHeight = size.height - 30;
    
    if (days.isEmpty) return;

    final barWidth = chartWidth / days.length;
    final spacing = barWidth * 0.2;

    double maxValue = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) + 10 : 100;
    double minValue = data.isNotEmpty ? data.reduce((a, b) => a < b ? a : b) - 10 : 0;
    if (minValue < 0) minValue = 0;
    double range = maxValue - minValue;
    if (range == 0) range = 1;

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final x = chartPadding + (i * barWidth) + (spacing / 2);
      final barGroupWidth = barWidth - spacing;

      final valueHeight = ((data[i] - minValue) / range) * chartHeight;
      final valueY = chartHeight - valueHeight;

      paint.color = const Color(0xFFFF9800);
      paint.style = PaintingStyle.fill;
      final barWidthFinal = barGroupWidth * 0.6;
      final barX = x + (barGroupWidth - barWidthFinal) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            barX,
            valueY,
            barWidthFinal,
            chartHeight - valueY,
          ),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
