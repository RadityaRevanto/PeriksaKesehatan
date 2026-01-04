import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/health/health_summary_model.dart';
import '../../../presentation/bloc/health/health_bloc.dart';
import '../../../presentation/bloc/health/health_event.dart';
import '../../../presentation/bloc/health/health_state.dart';

class RingkasanStatistikSection extends StatefulWidget {
  final String timeRangeLabel;

  const RingkasanStatistikSection({
    super.key,
    required this.timeRangeLabel,
  });

  @override
  State<RingkasanStatistikSection> createState() => _RingkasanStatistikSectionState();
}

class _RingkasanStatistikSectionState extends State<RingkasanStatistikSection> {
  @override
  void initState() {
    super.initState();
    // Fetch health history when widget is initialized
    context.read<HealthBloc>().add(const FetchHealthHistoryEvent());
  }

  String _formatChangePercent(double changePercent) {
    if (changePercent == 0) {
      return '⊝ Stabil';
    } else if (changePercent > 0) {
      return '↑ ${changePercent.toStringAsFixed(0)}% lebih tinggi';
    } else {
      return '↓ ${changePercent.abs().toStringAsFixed(0)}% lebih rendah';
    }
  }

  Color _getTrendColor(double changePercent) {
    if (changePercent == 0) {
      return AppColors.textSecondary;
    } else if (changePercent > 0) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (context, state) {
        HealthSummaryModel? summary;
        
        if (state is HealthHistoryLoaded) {
          summary = state.summary;
        }

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
                  Text(
                    'Ringkasan Statistik',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.timeRangeLabel,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (state is HealthLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state is HealthError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      state.message,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (summary != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _StatisticCard(
                        title: 'Tekanan Darah',
                        icon: Icons.favorite,
                        iconColor: AppColors.heartRate,
                        iconBgColor: AppColors.heartRateBg,
                        value: summary.bloodPressure != null
                            ? '${summary.bloodPressure!.avgSystolic.toStringAsFixed(0)}/${summary.bloodPressure!.avgDiastolic.toStringAsFixed(0)}'
                            : '-',
                        description: summary.bloodPressure != null
                            ? summary.bloodPressure!.normalRange
                            : 'Tidak ada data',
                        trend: summary.bloodPressure != null
                            ? _formatChangePercent(summary.bloodPressure!.changePercent)
                            : '-',
                        trendColor: summary.bloodPressure != null
                            ? _getTrendColor(summary.bloodPressure!.changePercent)
                            : AppColors.textSecondary,
                        status: summary.bloodPressure?.systolicStatus,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatisticCard(
                        title: 'Gula Darah',
                        icon: Icons.water_drop,
                        iconColor: AppColors.bloodSugar,
                        iconBgColor: AppColors.bloodSugarBg,
                        value: summary.bloodSugar != null
                            ? summary.bloodSugar!.avgValue.toStringAsFixed(0)
                            : '-',
                        description: summary.bloodSugar != null
                            ? '${summary.bloodSugar!.normalRange} rata-rata'
                            : 'Tidak ada data',
                        trend: summary.bloodSugar != null
                            ? _formatChangePercent(summary.bloodSugar!.changePercent)
                            : '-',
                        trendColor: summary.bloodSugar != null
                            ? _getTrendColor(summary.bloodSugar!.changePercent)
                            : AppColors.textSecondary,
                        status: summary.bloodSugar?.status,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatisticCard(
                        title: 'Berat Badan',
                        icon: Icons.monitor_weight,
                        iconColor: AppColors.weight,
                        iconBgColor: AppColors.weightBg,
                        value: summary.weight != null
                            ? summary.weight!.avgWeight.toStringAsFixed(1)
                            : '-',
                        description: summary.weight != null
                            ? 'kg rata-rata'
                            : 'Tidak ada data',
                        trend: summary.weight != null
                            ? summary.weight!.trend
                            : '-',
                        trendColor: summary.weight != null
                            ? _getTrendColor(summary.weight!.changePercent)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatisticCard(
                        title: 'Aktivitas',
                        icon: Icons.directions_walk,
                        iconColor: AppColors.activity,
                        iconBgColor: AppColors.activityBg,
                        value: summary.activity != null
                            ? _formatNumber(summary.activity!.totalSteps)
                            : '-',
                        description: summary.activity != null
                            ? '${summary.activity!.totalCalories} kalori'
                            : 'Tidak ada data',
                        trend: summary.activity != null
                            ? _formatChangePercent(summary.activity!.changePercent)
                            : '-',
                        trendColor: summary.activity != null
                            ? _getTrendColor(summary.activity!.changePercent)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Tidak ada data statistik',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String value;
  final String description;
  final String trend;
  final Color trendColor;
  final String? status;

  const _StatisticCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.description,
    required this.trend,
    required this.trendColor,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconBgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.nunitoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (status != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status!,
                style: GoogleFonts.nunitoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(status!),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            trend,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return AppColors.success;
      case 'perhatian':
        return AppColors.warning;
      case 'abnormal':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
