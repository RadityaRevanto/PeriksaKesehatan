import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class RingkasanStatistikSection extends StatelessWidget {
  final String timeRangeLabel;

  const RingkasanStatistikSection({
    super.key,
    required this.timeRangeLabel,
  });

  @override
  Widget build(BuildContext context) {
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
                timeRangeLabel,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatisticCard(
                  title: 'Tekanan Darah',
                  icon: Icons.favorite,
                  iconColor: AppColors.heartRate,
                  iconBgColor: AppColors.heartRateBg,
                  value: '122/79',
                  description: 'Rata-rata',
                  trend: '↓ 2% lebih rendah',
                  trendColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatisticCard(
                  title: 'Gula Darah',
                  icon: Icons.water_drop,
                  iconColor: AppColors.bloodSugar,
                  iconBgColor: AppColors.bloodSugarBg,
                  value: '108',
                  description: 'mg/dL rata-rata',
                  trend: '↑ 5% lebih tinggi',
                  trendColor: AppColors.warning,
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
                  value: '65.2',
                  description: 'kg (BMI: 23.4)',
                  trend: '⊝ Stabil',
                  trendColor: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatisticCard(
                  title: 'Aktivitas',
                  icon: Icons.directions_walk,
                  iconColor: AppColors.activity,
                  iconBgColor: AppColors.activityBg,
                  value: '8,542',
                  description: 'langkah/hari',
                  trend: '↑ 12% lebih tinggi',
                  trendColor: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
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

  const _StatisticCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.description,
    required this.trend,
    required this.trendColor,
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
}
