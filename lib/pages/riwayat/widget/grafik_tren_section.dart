import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/bloc/health/health_bloc.dart';
import '../../../presentation/bloc/health/health_event.dart';
import '../../../presentation/bloc/health/health_state.dart';
import '../../../data/models/health/health_summary_model.dart';
import '../detail_grafik_tren_page.dart';

class GrafikTrenSection extends StatefulWidget {
  const GrafikTrenSection({super.key});

  @override
  State<GrafikTrenSection> createState() => _GrafikTrenSectionState();
}

class _GrafikTrenSectionState extends State<GrafikTrenSection> {
  @override
  void initState() {
    super.initState();
    // Fetch health history when widget is initialized
    context.read<HealthBloc>().add(const FetchHealthHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (context, state) {
        if (state is HealthLoading) {
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is HealthError) {
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
            child: Center(
              child: Text(
                'Error: ${state.message}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }

        TrendCharts? trendCharts;
        if (state is HealthHistoryLoaded && state.summary != null) {
          trendCharts = state.summary!.trendCharts;
        }

        // Get blood pressure data from trend charts
        final List<Map<String, double>> bloodPressureData = [];
        final List<String> days = [];
        
        if (trendCharts?.bloodPressure != null && trendCharts!.bloodPressure!.isNotEmpty) {
          for (var item in trendCharts.bloodPressure!) {
            bloodPressureData.add({
              'systolic': item.systolic,
              'diastolic': item.diastolic,
            });
            
            // Parse date and format as day name
            try {
              final date = DateTime.parse(item.date);
              final dayName = DateFormat('EEE', 'id_ID').format(date);
              days.add(dayName.substring(0, 3)); // Get first 3 chars (Sen, Sel, etc.)
            } catch (e) {
              days.add(item.date);
            }
          }
        }

        // If no data, show empty state
        if (bloodPressureData.isEmpty) {
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
            child: Center(
              child: Text(
                'Tidak ada data tren tekanan darah',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
    
        // Normal range
        final double normalSystolicMin = 90;
        final double normalSystolicMax = 120;
        final double normalDiastolicMin = 60;
        final double normalDiastolicMax = 80;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Grafik Tren - Tekanan Darah',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // Navigate to detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailGrafikTrenPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selengkapnya',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
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
                label: 'Normal Range',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                CustomPaint(
                  painter: BloodPressureChartPainter(
                    data: bloodPressureData,
                    days: days,
                    normalSystolicMin: normalSystolicMin,
                    normalSystolicMax: normalSystolicMax,
                    normalDiastolicMin: normalDiastolicMin,
                    normalDiastolicMax: normalDiastolicMax,
                  ),
                  size: Size.infinite,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: days.map((day) {
                      return SizedBox(
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
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Range Normal: 90-120 / 60-80 mmHg',
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
      },
    );
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
}

class BloodPressureChartPainter extends CustomPainter {
  final List<Map<String, double>> data;
  final List<String> days;
  final double normalSystolicMin;
  final double normalSystolicMax;
  final double normalDiastolicMin;
  final double normalDiastolicMax;

  BloodPressureChartPainter({
    required this.data,
    required this.days,
    required this.normalSystolicMin,
    required this.normalSystolicMax,
    required this.normalDiastolicMin,
    required this.normalDiastolicMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final chartPadding = 20.0;
    final chartWidth = size.width - (chartPadding * 2);
    final chartHeight = size.height - 30;
    final barWidth = chartWidth / days.length;
    final spacing = barWidth * 0.2;

    double maxValue = 180;
    double minValue = 40;
    double range = maxValue - minValue;

    final normalRangeTop = chartHeight - ((normalSystolicMax - minValue) / range * chartHeight);
    final normalRangeBottom = chartHeight - ((normalDiastolicMin - minValue) / range * chartHeight);
    
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

    for (int i = 0; i < data.length; i++) {
      final x = chartPadding + (i * barWidth) + (spacing / 2);
      final barGroupWidth = barWidth - spacing;
      
      final systolicHeight = ((data[i]['systolic']! - minValue) / range) * chartHeight;
      final diastolicHeight = ((data[i]['diastolic']! - minValue) / range) * chartHeight;
      
      final systolicY = chartHeight - systolicHeight;
      final diastolicY = chartHeight - diastolicHeight;

      paint.color = const Color(0xFF0288D1);
      paint.style = PaintingStyle.fill;
      final diastolicBarWidth = barGroupWidth * 0.6;
      final diastolicBarX = x + (barGroupWidth - diastolicBarWidth) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            diastolicBarX,
            diastolicY,
            diastolicBarWidth,
            systolicY - diastolicY,
          ),
          const Radius.circular(4),
        ),
        paint,
      );

      paint.color = const Color(0xFF2E7D32);
      paint.style = PaintingStyle.fill;
      final systolicBarWidth = barGroupWidth * 0.8;
      final systolicBarX = x + (barGroupWidth - systolicBarWidth) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            systolicBarX,
            systolicY,
            systolicBarWidth,
            chartHeight - systolicY,
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
