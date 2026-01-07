import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/data/models/health/health_alert_model.dart';
import 'package:periksa_kesehatan/domain/entities/health_alert.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/alert_detail_page.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_state.dart';

class PeringatanKesehatanPage extends StatefulWidget {
  const PeringatanKesehatanPage({super.key});

  @override
  State<PeringatanKesehatanPage> createState() => _PeringatanKesehatanPageState();
}

class _PeringatanKesehatanPageState extends State<PeringatanKesehatanPage> {
  @override
  void initState() {
    super.initState();
    context.read<HealthBloc>().add(const FetchHealthAlertsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Peringatan Kesehatan',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              context.read<HealthBloc>().add(const FetchHealthAlertsEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          // Loading state
          if (state is HealthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          // Error state
          if (state is HealthError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat peringatan kesehatan',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HealthBloc>().add(const FetchHealthAlertsEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Coba Lagi',
                        style: GoogleFonts.nunitoSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Get alerts from state
          HealthAlertsModel? alertsModel;
          
          if (state is HealthAlertsLoaded) {
            alertsModel = state.alerts;
          } else if (state is HealthDataLoaded) {
            alertsModel = state.alerts;
          }
          
          // No alerts state
          if (alertsModel == null || alertsModel.alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak Ada Peringatan',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semua indikator kesehatan Anda\ndalam kondisi baik',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Display alerts list
          final alerts = alertsModel.alerts;
          
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3C4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFFF9800),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anda memiliki ${alerts.length} peringatan kesehatan. Tap untuk melihat detail.',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13,
                          color: const Color(0xFF5D4037),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Alert cards
              ...alerts.asMap().entries.map((entry) {
                final index = entry.key;
                final alert = entry.value;
                
                return Column(
                  children: [
                    _buildAlertCard(alert),
                    if (index < alerts.length - 1) const SizedBox(height: 12),
                  ],
                );
              }).toList(),
              
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildAlertCard(HealthAlert alert) {
    final color = _getColorByStatus(alert.status);
    final bgColor = _getBgColorByStatus(alert.status);
    final icon = _getIconByStatus(alert.status);
    
    // Format date time
    final dateTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(alert.recordedAt);
    
    return InkWell(
      onTap: () {
        // Navigate to detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlertDetailPage(alert: alert),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
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
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.alertType,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateTime,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    alert.status,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    alert.label,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    alert.value,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              alert.explanation,
              style: GoogleFonts.nunitoSans(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Lihat detail & tindakan',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getColorByStatus(String status) {
    switch (status.toUpperCase()) {
      case 'TINGGI':
      case 'SANGAT TINGGI':
        return const Color(0xFFFF9800);
      case 'RENDAH':
      case 'SANGAT RENDAH':
        return const Color(0xFF2196F3);
      case 'KRITIS':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF4CAF50);
    }
  }
  
  Color _getBgColorByStatus(String status) {
    switch (status.toUpperCase()) {
      case 'TINGGI':
      case 'SANGAT TINGGI':
        return const Color(0xFFFFF8E1);
      case 'RENDAH':
      case 'SANGAT RENDAH':
        return const Color(0xFFE3F2FD);
      case 'KRITIS':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFE8F5E9);
    }
  }
  
  IconData _getIconByStatus(String status) {
    switch (status.toUpperCase()) {
      case 'TINGGI':
      case 'SANGAT TINGGI':
        return Icons.warning;
      case 'RENDAH':
      case 'SANGAT RENDAH':
        return Icons.trending_down;
      case 'KRITIS':
        return Icons.error_outline;
      default:
        return Icons.check_circle_outline;
    }
  }
}