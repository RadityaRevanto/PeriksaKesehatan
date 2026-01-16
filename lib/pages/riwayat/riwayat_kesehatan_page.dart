import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/auth/auth_state.dart';
import '../../presentation/bloc/health/health_bloc.dart';
import '../../presentation/bloc/health/health_event.dart';
import '../../presentation/bloc/health/health_state.dart';
import '../../data/models/health/health_summary_model.dart';
import '../../data/repositories/health_repository.dart';
import '../../services/health_sync_service.dart';
import '../../services/pdf_export_service.dart';
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
  String? _selectedMetricType = 'Semua'; // Default: show all metrics
  String? _selectedStatus = 'Semua'; // Default: show all statuses
  
  // Connectivity tracking
  bool? _previousConnectivityState;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    
    // Listen to connectivity changes
    _connectivitySubscription = sl<HealthSyncService>().connectivityStream.listen((isOnline) {
      print('🌐 [RIWAYAT] CONNECTIVITY CHANGED: ${isOnline ? "ONLINE" : "OFFLINE"}');
      
      if (_previousConnectivityState != null && _previousConnectivityState != isOnline) {
        print('🔄 [RIWAYAT] Refreshing data due to connectivity change...');
        
        // Refresh data when connectivity changes
        context.read<HealthBloc>().add(FetchHealthHistoryEvent(timeRange: _getTimeRangeForApi()));
      }
      _previousConnectivityState = isOnline;
    });
    
    // Fetch health history on page load with default time range
    context.read<HealthBloc>().add(FetchHealthHistoryEvent(timeRange: _getTimeRangeForApi()));
  }
  
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedTimeRange = '7 Hari';
      _selectedMetricType = 'Semua';
      _selectedStatus = 'Semua';
    });
    // Refetch data with default time range
    context.read<HealthBloc>().add(FetchHealthHistoryEvent(timeRange: _getTimeRangeForApi()));
  }

  String _getTimeRangeLabel() {
    switch (_selectedTimeRange) {
      case '7 Hari':
        return '7 hari terakhir';
      case '30 Hari':
        return '30 hari terakhir';
      case '3 Bulan':
        return '3 bulan terakhir';
      default:
        return '7 hari terakhir';
    }
  }

  /// Convert selected time range to API format
  String _getTimeRangeForApi() {
    switch (_selectedTimeRange) {
      case '7 Hari':
        return '7Days';
      case '30 Hari':
        return '1Month';  // Changed from '30Days' to match API response
      case '3 Bulan':
        return '3Months';  // Changed from '90Days' to match API response
      default:
        return '7Days';
    }
  }

  /// Transform reading history from API to widget format
  List<Map<String, dynamic>> _transformReadingHistory(
    List<ReadingHistory>? readingHistory,
  ) {
    if (readingHistory == null || readingHistory.isEmpty) {
      return [];
    }

    // Group by id and date_time (same id and date_time should be grouped)
    final Map<String, List<ReadingHistory>> grouped = {};
    for (var item in readingHistory) {
      final key = '${item.id}_${item.dateTime.toIso8601String()}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }

    // Sort groups by date_time descending (newest first) before converting
    final sortedGroups = grouped.values.toList();
    sortedGroups.sort((a, b) {
      final dateTimeA = a.first.dateTime;
      final dateTimeB = b.first.dateTime;
      return dateTimeB.compareTo(dateTimeA);
    });

    // Convert to widget format
    final List<Map<String, dynamic>> result = [];
    
    for (var group in sortedGroups) {
      if (group.isEmpty) continue;
      
      final firstItem = group.first;
      final dateTime = firstItem.dateTime.toLocal();
      
      // Format date: "Sabtu, 13 Jan 2025"
      final dayNames = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      // DateTime.weekday returns 1-7 (Monday=1, Sunday=7), so we need to adjust
      final dayIndex = dateTime.weekday == 7 ? 0 : dateTime.weekday;
      final dayName = dayNames[dayIndex];
      final monthName = monthNames[dateTime.month - 1];
      final formattedDate = '$dayName, ${dateTime.day} $monthName ${dateTime.year}';
      
      // Format time: "11:20 AM"
      final formattedTime = DateFormat('hh:mm a', 'en_US').format(dateTime);
      
      // Determine overall status (use the most severe status)
      String overallStatus = 'Normal';
      Color statusColor = AppColors.success;
      Color statusBgColor = AppColors.success.withOpacity(0.1);
      
      for (var item in group) {
        if (item.status == 'Abnormal') {
          overallStatus = 'Abnormal';
          statusColor = AppColors.error;
          statusBgColor = AppColors.error.withOpacity(0.1);
          break;
        } else if (item.status == 'Perhatian' && overallStatus == 'Normal') {
          overallStatus = 'Perhatian';
          statusColor = AppColors.warning;
          statusBgColor = AppColors.warning.withOpacity(0.1);
        }
      }
      
      // Build metrics list
      final List<Map<String, String>> metrics = [];
      for (var item in group) {
        String label = '';
        switch (item.metricType) {
          case 'tekanan_darah':
            label = 'Tekanan Darah';
            break;
          case 'gula_darah':
            label = 'Gula Darah';
            break;
          case 'berat_badan':
            label = 'Berat Badan';
            break;
          case 'aktivitas':
            label = 'Aktivitas';
            break;
          default:
            label = item.metricType.replaceAll('_', ' ').split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' ');
        }
        metrics.add({
          'label': label,
          'value': item.value,
        });
      }
      
      // Get notes (use first non-null note if available)
      String? note;
      IconData? noteIcon;
      Color? noteColor;
      Color? noteBgColor;
      bool hasNote = false;
      
      for (var item in group) {
        if (item.notes != null && item.notes!.isNotEmpty) {
          note = item.notes;
          hasNote = true;
          
          // Set icon and color based on status
          if (item.status == 'Abnormal') {
            noteIcon = Icons.error_outline;
            noteColor = AppColors.error;
            noteBgColor = AppColors.error.withOpacity(0.1);
          } else if (item.status == 'Perhatian') {
            noteIcon = Icons.warning_amber_rounded;
            noteColor = AppColors.warning;
            noteBgColor = AppColors.warning.withOpacity(0.1);
          } else {
            noteIcon = Icons.info_outline;
            noteColor = AppColors.textSecondary;
            noteBgColor = Colors.grey[100]!;
          }
          break;
        }
      }
      
      // Determine border (show border for all statuses)
      final hasBorder = true;
      final borderColor = statusColor.withOpacity(0.3);
      
      result.add({
        'date': formattedDate,
        'time': formattedTime,
        'status': overallStatus,
        'statusColor': statusColor,
        'statusBgColor': statusBgColor,
        'metrics': metrics,
        if (hasNote) 'note': note,
        if (hasNote) 'noteIcon': noteIcon,
        if (hasNote) 'noteColor': noteColor,
        if (hasNote) 'noteBgColor': noteBgColor,
        'hasBorder': hasBorder,
        'borderColor': borderColor,
        'hasNote': hasNote,
      });
    }
    
    return result;
  }

  


  void _showReadingNotesFilterDialog() {
    // Simpan nilai sementara untuk dialog
    String? tempMetricType = _selectedMetricType;
    String? tempStatus = _selectedStatus;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Catatan Pembacaan',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            tempMetricType = 'Semua';
                            tempStatus = 'Semua';
                          });
                        },
                        child: Text(
                          'Reset',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                  _buildMetricFilterChipInDialog(
                    'Semua',
                    Icons.all_inclusive,
                    AppColors.textSecondary,
                    tempMetricType,
                    (value) {
                      setDialogState(() {
                        tempMetricType = value;
                      });
                    },
                  ),
                  _buildMetricFilterChipInDialog(
                    'Tekanan Darah',
                    Icons.favorite,
                    AppColors.heartRate,
                    tempMetricType,
                    (value) {
                      setDialogState(() {
                        tempMetricType = value;
                      });
                    },
                  ),
                  _buildMetricFilterChipInDialog(
                    'Gula Darah',
                    Icons.water_drop,
                    AppColors.bloodSugar,
                    tempMetricType,
                    (value) {
                      setDialogState(() {
                        tempMetricType = value;
                      });
                    },
                  ),
                  _buildMetricFilterChipInDialog(
                    'Berat Badan',
                    Icons.monitor_weight,
                    AppColors.weight,
                    tempMetricType,
                    (value) {
                      setDialogState(() {
                        tempMetricType = value;
                      });
                    },
                  ),
                  _buildMetricFilterChipInDialog(
                    'Aktivitas',
                    Icons.directions_walk,
                    AppColors.activity,
                    tempMetricType,
                    (value) {
                      setDialogState(() {
                        tempMetricType = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Status',
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
                  _buildStatusFilterChipInDialog(
                    'Semua',
                    Icons.all_inclusive,
                    AppColors.textSecondary,
                    tempStatus,
                    (value) {
                      setDialogState(() {
                        tempStatus = value;
                      });
                    },
                  ),
                  _buildStatusFilterChipInDialog(
                    'Normal',
                    Icons.check_circle_outline,
                    AppColors.success,
                    tempStatus,
                    (value) {
                      setDialogState(() {
                        tempStatus = value;
                      });
                    },
                  ),
                  _buildStatusFilterChipInDialog(
                    'Perhatian',
                    Icons.warning_amber_rounded,
                    AppColors.warning,
                    tempStatus,
                    (value) {
                      setDialogState(() {
                        tempStatus = value;
                      });
                    },
                  ),
                  _buildStatusFilterChipInDialog(
                    'Abnormal',
                    Icons.error_outline,
                    AppColors.error,
                    tempStatus,
                    (value) {
                      setDialogState(() {
                        tempStatus = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedMetricType = tempMetricType;
                      _selectedStatus = tempStatus;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Terapkan Filter',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricFilterChipInDialog(
    String label,
    IconData icon,
    Color iconColor,
    String? selectedValue,
    Function(String) onTap,
  ) {
    final isSelected = selectedValue == label;
    return InkWell(
      onTap: () => onTap(label),
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

  Widget _buildStatusFilterChipInDialog(
    String label,
    IconData icon,
    Color iconColor,
    String? selectedValue,
    Function(String) onTap,
  ) {
    final isSelected = selectedValue == label;
    return InkWell(
      onTap: () => onTap(label),
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

  /// Filter reading notes based on selected metric type and status
  List<Map<String, dynamic>> _filterReadingNotesByMetricType(
    List<Map<String, dynamic>> readingNotes,
  ) {
    var filtered = readingNotes;

    // Filter by metric type
    if (_selectedMetricType != null && _selectedMetricType != 'Semua') {
      filtered = filtered.where((note) {
        final metrics = note['metrics'] as List<Map<String, String>>;
        return metrics.any((metric) => metric['label'] == _selectedMetricType);
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != null && _selectedStatus != 'Semua') {
      filtered = filtered.where((note) {
        final status = note['status'] as String;
        return status == _selectedStatus;
      }).toList();
    }

    return filtered;
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
          // Connectivity Status Badge
          StreamBuilder<bool>(
            stream: sl<HealthSyncService>().connectivityStream,
            builder: (context, snapshot) {
              // Only show badge when we have actual data
              if (!snapshot.hasData) {
                return const SizedBox(width: 12); // Placeholder
              }
              
              final isOnline = snapshot.data!;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isOnline 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOnline ? Colors.green : Colors.orange,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.wifi : Icons.wifi_off,
                      color: isOnline ? Colors.green : Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.nunitoSans(
                        color: isOnline ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Download Button
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _downloadMedicalReport(context),
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
        ],
      ),
      body: BlocListener<HealthBloc, HealthState>(
        listener: (context, state) {
          // Show snackbar when there's an error (including no data for period)
          if (state is HealthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FilterDataSection(
                selectedTimeRange: _selectedTimeRange,
                onTimeRangeChanged: (value) {
                  setState(() {
                    _selectedTimeRange = value;
                  });
                  // Fetch new data when time range changes
                  context.read<HealthBloc>().add(FetchHealthHistoryEvent(timeRange: _getTimeRangeForApi()));
                },
                onReset: _resetFilters,
              ),
              const SizedBox(height: 20),
              
              RingkasanStatistikSection(
                timeRangeLabel: _getTimeRangeLabel(),
              ),
              const SizedBox(height: 20),
              
              const GrafikTrenSection(),
              const SizedBox(height: 20),
              
              BlocBuilder<HealthBloc, HealthState>(
                builder: (context, state) {
                  if (state is HealthLoading) {
                    return _buildShimmerSkeleton();
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  List<Map<String, dynamic>> readingNotes = [];
                  if (state is HealthHistoryLoaded && state.summary?.readingHistory != null) {
                    readingNotes = _transformReadingHistory(state.summary!.readingHistory);
                  }
                  
                  // Filter reading notes based on selected metric type and status
                  final filteredReadingNotes = _filterReadingNotesByMetricType(readingNotes);
                  
                  if (filteredReadingNotes.isEmpty) {
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 48,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              readingNotes.isEmpty
                                  ? 'Tidak ada catatan pembacaan untuk ${_getTimeRangeLabel()}'
                                  : 'Tidak ada catatan untuk jenis metrik yang dipilih',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  final hasActiveFilters = 
                      (_selectedMetricType != null && _selectedMetricType != 'Semua') ||
                      (_selectedStatus != null && _selectedStatus != 'Semua');
                  
                  return CatatanPembacaanSection(
                    readingNotes: filteredReadingNotes,
                    onFilterTap: _showReadingNotesFilterDialog,
                    hasActiveFilters: hasActiveFilters,
                  );
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
      ),
    );
  }

  /// Download medical report PDF (works both online and offline)
  Future<void> _downloadMedicalReport(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: _buildLoadingShimmer(),
        ),
      );

      // Get current health state
      final healthState = context.read<HealthBloc>().state;
      final authState = context.read<AuthBloc>().state;
      
      String userName = 'Pengguna';
      if (authState is AuthAuthenticated) {
        userName = authState.name;
      }

      // Try online download first
      try {
        final healthRepository = sl<HealthRepository>();
        final timeRange = _getTimeRangeForApi();
        
        final result = await healthRepository.downloadHealthHistoryPdf(timeRange);
        
        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Handle API result
        await result.fold(
          (failure) async {
            // API failed, fallback to offline generation
            print('PDF API failed: ${failure.message}, generating offline PDF...');
            await _generateOfflinePdf(context, healthState, userName);
          },
          (pdfBytes) async {
            // API success, save and share
            await _savePdfFromBytes(context, pdfBytes, 'API');
          },
        );
      } catch (e) {
        // Network error, generate offline PDF
        print('PDF download error: $e, generating offline PDF...');
        if (mounted) Navigator.pop(context);
        await _generateOfflinePdf(context, healthState, userName);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Generate PDF offline using local data
  Future<void> _generateOfflinePdf(
    BuildContext context,
    HealthState healthState,
    String userName,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: _buildLoadingShimmer(),
        ),
      );

      HealthSummaryModel? summary;
      if (healthState is HealthHistoryLoaded) {
        summary = healthState.summary;
      }

      if (summary == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada data untuk diekspor'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Generate PDF using local service
      final pdfService = PdfExportService();
      final pdfFile = await pdfService.generateHealthReportPdf(
        summary: summary,
        timeRange: _getTimeRangeForApi(),
        userName: userName,
      );

      // Close loading
      if (mounted) Navigator.pop(context);

      // Share PDF
      await pdfService.sharePdf(pdfFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil dibuat (Mode Offline)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Save PDF from bytes and share
  Future<void> _savePdfFromBytes(
    BuildContext context,
    List<int> pdfBytes,
    String source,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
      final fileName = 'Riwayat_Kesehatan_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      // Share PDF
      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Riwayat Kesehatan',
          subject: 'Laporan Kesehatan',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF berhasil diunduh ($source)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Download PDF from AppBar button
  Future<void> _downloadPdfFromAppBar() async {
    await _downloadMedicalReport(context);
  }

  /// Build shimmer skeleton for loading state
  Widget _buildShimmerSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
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
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // List items
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Build loading shimmer for dialogs
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.download_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}