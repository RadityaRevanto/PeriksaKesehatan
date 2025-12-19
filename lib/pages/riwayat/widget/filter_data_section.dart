import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class FilterDataSection extends StatelessWidget {
  final String? selectedTimeRange;
  final String? selectedMetricType;
  final Function(String) onTimeRangeChanged;
  final Function(String) onMetricTypeChanged;
  final VoidCallback onReset;
  final Function() onCustomDatePicker;

  const FilterDataSection({
    super.key,
    required this.selectedTimeRange,
    required this.selectedMetricType,
    required this.onTimeRangeChanged,
    required this.onMetricTypeChanged,
    required this.onReset,
    required this.onCustomDatePicker,
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
                'Filter Data',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: onReset,
                child: Text(
                  'Reset',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Rentang Waktu',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTimeRangeChip('7 Hari'),
              _buildTimeRangeChip('30 Hari'),
              _buildTimeRangeChip('3 Bulan'),
              _buildTimeRangeChip('Custom'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Jenis Metrik',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricChip(
                'Tekanan Darah',
                Icons.favorite,
                AppColors.heartRate,
              ),
              _buildMetricChip(
                'Gula Darah',
                Icons.water_drop,
                AppColors.bloodSugar,
              ),
              _buildMetricChip(
                'Berat Badan',
                Icons.monitor_weight,
                AppColors.weight,
              ),
              _buildMetricChip(
                'Aktivitas',
                Icons.directions_walk,
                AppColors.activity,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeChip(String label) {
    final isSelected = selectedTimeRange == label;
    return InkWell(
      onTap: () {
        if (label == 'Custom') {
          onCustomDatePicker();
        } else {
          onTimeRangeChanged(label);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, IconData icon, Color iconColor) {
    final isSelected = selectedMetricType == label;
    return InkWell(
      onTap: () => onMetricTypeChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : iconColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
