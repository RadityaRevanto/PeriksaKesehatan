import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/widgets/cards/health_metric_card.dart';
import 'package:periksa_kesehatan/pages/input/input_data_kesehatan_page.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/peringatan_kesehatan_page.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_state.dart';
import 'package:periksa_kesehatan/domain/entities/health_data.dart';
import 'package:periksa_kesehatan/data/models/health/health_alert_model.dart';
import 'package:periksa_kesehatan/data/models/health/health_summary_model.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _currentTime;
  late Timer _timer;
  bool _isManualDate = false;
  HealthData? _latestHealthData;
  HealthSummaryModel? _healthHistory;
  HealthAlertsModel? _healthAlerts;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Update setiap detik untuk:
    // 1. Update tanggal/waktu di header (jika tidak manual date)
    // 2. Update "X menit/jam lalu" secara real-time
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (!_isManualDate) {
          _currentTime = DateTime.now();
        }
        // setState akan trigger rebuild untuk update "X jam lalu"
      });
    });
    
    // Fetch health data saat page load
    _fetchHealthData();
  }

  void _fetchHealthData() {
    // Fetch latest health data
    context.read<HealthBloc>().add(const FetchHealthDataEvent());
    
    // Fetch health history (for date filtering)
    context.read<HealthBloc>().add(const FetchHealthHistoryEvent());
    
    // Fetch health alerts
    context.read<HealthBloc>().add(const FetchHealthAlertsEvent());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = _currentTime.hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  String _getFormattedDate() {
    // Format: Senin, 15 Januari 2025
    final dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final dayName = dayNames[_currentTime.weekday - 1];
    final day = _currentTime.day;
    final monthName = monthNames[_currentTime.month - 1];
    final year = _currentTime.year;
    
    return '$dayName, $day $monthName $year';
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _currentTime = picked;
        _isManualDate = true; // Set flag bahwa tanggal dipilih manual
      });
      
      // Fetch data dengan filter tanggal
      _fetchHealthData();
      
      // Show snackbar dengan tanggal yang dipilih
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Menampilkan data: ${_getFormattedDate()}',
              style: GoogleFonts.nunitoSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Kembali ke Hari Ini',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _currentTime = DateTime.now();
                  _isManualDate = false; // Kembali ke mode real-time
                });
                // Refresh data untuk hari ini
                _fetchHealthData();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.nunitoSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                String name = 'Pengguna'; // Default name
                                if (state is AuthAuthenticated) {
                                  name = state.name;
                                }
                                return Text(
                                  name,
                                  style: GoogleFonts.nunitoSans(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _showDatePicker,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              // Badge indicator untuk manual date
                              if (_isManualDate)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getFormattedDate(),
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Health metrics grid with BLoC
                    BlocConsumer<HealthBloc, HealthState>(
                      listener: (context, state) {
                        // Store data from different states
                        if (state is HealthDataLoaded) {
                          setState(() {
                            _latestHealthData = state.healthData;
                            // Only update alerts if they are present in the state
                            if (state.alerts != null) {
                              _healthAlerts = state.alerts;
                            }
                          });
                        } else if (state is HealthHistoryLoaded) {
                          setState(() {
                            _healthHistory = state.summary;
                          });
                        } else if (state is HealthAlertsLoaded) {
                          // Explicitly handle HealthAlertsLoaded state
                          setState(() {
                            if (state.alerts != null) {
                              _healthAlerts = state.alerts;
                            }
                          });
                        }
                      },
                      builder: (context, state) {
                        if (state is HealthLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } 
                        
                        // If manual date is selected, use history data
                        if (_isManualDate) {
                          return _buildHealthMetricsFromHistoryData();
                        }
                        
                        // Show latest data if not filtering by date
                        if (_latestHealthData != null) {
                          return _buildHealthMetrics(_latestHealthData);
                        }
                        
                        // Handle empty data state (new users or no data for selected date)
                        if (state is HealthDataEmpty) {
                          return Column(
                            children: [
                              _buildHealthMetrics(null),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isManualDate
                                          ? 'Tidak ada data untuk tanggal ${_getFormattedDate()}'
                                          : 'Belum ada data kesehatan',
                                      style: GoogleFonts.nunitoSans(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isManualDate
                                          ? 'Pilih tanggal lain atau tambah data baru'
                                          : 'Mulai tambahkan data kesehatan Anda',
                                      style: GoogleFonts.nunitoSans(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } 
                        
                        // Handle error state - but only show error UI for actual errors
                        // (not for "no data" scenarios which are now handled as HealthDataEmpty)
                        if (state is HealthError) {
                          // If error is about missing data and we're not in manual date mode,
                          // show empty state instead of error
                          if (!_isManualDate && state.message.toLowerCase().contains('tidak ada data')) {
                            return Column(
                              children: [
                                _buildHealthMetrics(null),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Belum ada data kesehatan',
                                        style: GoogleFonts.nunitoSans(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Mulai tambahkan data kesehatan Anda',
                                        style: GoogleFonts.nunitoSans(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          
                          // Show actual error UI for real errors
                          return Center(
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  style: GoogleFonts.nunitoSans(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchHealthData,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        // Initial or other states - show empty metrics
                        return _buildHealthMetrics(null);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Warning banner - Using cached _healthAlerts
                    if (_healthAlerts != null && _healthAlerts!.alerts.isNotEmpty)
                      Builder(
                        builder: (context) {
                          // Get the first alert
                          final alert = _healthAlerts!.alerts.first;
                          
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PeringatanKesehatanPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: const Border(
                                      left: BorderSide(color: AppColors.warning, width: 4),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.warning,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Peringatan',
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF5D4037),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              alert.explanation,
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 14,
                                                color: Colors.grey[800],
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),

                    // Tambah Pembacaan Baru Section
                    Container(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Tambah Pembacaan Baru',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              Icon(
                                Icons.favorite,
                                color: AppColors.heartRate,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Catat metrik kesehatan Anda untuk melacak kemajuan',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Grid 2x2 untuk tombol tambah pembacaan
                          Row(
                            children: [
                              Expanded(
                                child: _buildAddReadingButton(
                                  icon: Icons.favorite,
                                  label: 'Tekanan Darah',
                                  color: AppColors.heartRate,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InputDataKesehatanPage(),
                                      ),
                                    );
                                    // Refresh data setelah kembali
                                    _fetchHealthData();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAddReadingButton(
                                  icon: Icons.water_drop,
                                  label: 'Gula Darah',
                                  color: AppColors.bloodSugar,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InputDataKesehatanPage(),
                                      ),
                                    );
                                    _fetchHealthData();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildAddReadingButton(
                                  icon: Icons.monitor_weight,
                                  label: 'Berat Badan',
                                  color: AppColors.weight,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InputDataKesehatanPage(),
                                      ),
                                    );
                                    _fetchHealthData();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAddReadingButton(
                                  icon: Icons.directions_walk,
                                  label: 'Aktivitas',
                                  color: AppColors.activity,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InputDataKesehatanPage(),
                                      ),
                                    );
                                    _fetchHealthData();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),


                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InputDataKesehatanPage(),
            ),
          );
          _fetchHealthData();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Build health metrics from history data based on selected date
  Widget _buildHealthMetricsFromHistoryData() {
    if (_healthHistory == null || _healthHistory!.readingHistory == null) {
      return Column(
        children: [
          _buildHealthMetrics(null),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tidak ada data untuk tanggal ${_getFormattedDate()}',
                  style: GoogleFonts.nunitoSans(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    // Filter reading history by selected date
    final selectedDate = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
    );
    
    final readings = _healthHistory!.readingHistory!.where((reading) {
      final readingDate = DateTime(
        reading.dateTime.year,
        reading.dateTime.month,
        reading.dateTime.day,
      );
      return readingDate.isAtSameMomentAs(selectedDate);
    }).toList();
    
    if (readings.isEmpty) {
      return Column(
        children: [
          _buildHealthMetrics(null),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tidak ada data untuk tanggal ${_getFormattedDate()}',
                  style: GoogleFonts.nunitoSans(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    // Extract data from readings
    int? systolic;
    int? diastolic;
    int? bloodSugar;
    double? weight;
    double? height;
    String? activity;
    DateTime? latestDate;
    
    for (var reading in readings) {
      if (reading.metricType == 'tekanan_darah') {
        // Parse "130/80 mmHg" format
        final parts = reading.value.split('/');
        if (parts.length == 2) {
          systolic = int.tryParse(parts[0].trim());
          diastolic = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
        }
        latestDate = reading.dateTime;
      } else if (reading.metricType == 'gula_darah') {
        // Parse "85 mg/dL" format
        bloodSugar = int.tryParse(reading.value.replaceAll(RegExp(r'[^0-9]'), ''));
        latestDate ??= reading.dateTime;
      } else if (reading.metricType == 'berat_badan') {
        // Parse "90.50 kg" format
        weight = double.tryParse(reading.value.replaceAll(RegExp(r'[^0-9.]'), ''));
        latestDate ??= reading.dateTime;
      } else if (reading.metricType == 'tinggi_badan' || reading.metricType == 'height') {
        // Parse "170 cm" format
        height = double.tryParse(reading.value.replaceAll(RegExp(r'[^0-9.]'), ''));
        latestDate ??= reading.dateTime;
      } else if (reading.metricType == 'aktivitas' || reading.metricType == 'detak_jantung') {
        // For now, just show the value
        activity = reading.value;
        latestDate ??= reading.dateTime;
      }
    }
    
    // Create a HealthData object from the extracted values
    final healthData = latestDate != null ? HealthData(
      date: latestDate,
      systolic: systolic,
      diastolic: diastolic,
      bloodSugar: bloodSugar,
      weight: weight,
      height: height,
      activity: activity,
    ) : null;
    
    return _buildHealthMetrics(healthData);
  }

  Widget _buildAddReadingButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetrics(HealthData? data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HealthMetricCard(
                icon: Icons.favorite,
                iconColor: AppColors.heartRate,
                iconBgColor: AppColors.heartRateBg,
                title: 'Tekanan Darah',
                value: data?.systolic?.toString() ?? '--',
                unit: data?.diastolic != null ? '/${data!.diastolic}' : '',
                subtitle: data != null ? _getTimeAgo(data.date) : 'Belum ada data',
                statusText: _getBloodPressureStatus(data?.systolic, data?.diastolic),
                statusColor: _getBloodPressureColor(data?.systolic, data?.diastolic),
                changeIndicator: '',
                changeColor: AppColors.heartRate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HealthMetricCard(
                icon: Icons.water_drop,
                iconColor: AppColors.bloodSugar,
                iconBgColor: AppColors.bloodSugarBg,
                title: 'Gula Darah',
                value: data?.bloodSugar?.toString() ?? '--',
                unit: data?.bloodSugar != null ? 'mg/dL' : '',
                subtitle: data != null ? _getTimeAgo(data.date) : 'Belum ada data',
                statusText: _getBloodSugarStatus(data?.bloodSugar),
                statusColor: _getBloodSugarColor(data?.bloodSugar),
                changeIndicator: '',
                changeColor: AppColors.bloodSugar,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: HealthMetricCard(
                icon: Icons.monitor_weight,
                iconColor: AppColors.weight,
                iconBgColor: AppColors.weightBg,
                title: 'Berat Badan',
                value: data?.weight?.toStringAsFixed(1) ?? '--',
                unit: data?.weight != null ? 'kg' : '',
                subtitle: data != null ? _getTimeAgo(data.date) : 'Belum ada data',
                statusText: _getWeightStatus(data?.weight, data?.height),
                statusColor: _getWeightStatusColor(data?.weight, data?.height),
                changeIndicator: '',
                changeColor: AppColors.weight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HealthMetricCard(
                icon: Icons.directions_walk,
                iconColor: AppColors.activity,
                iconBgColor: AppColors.activityBg,
                title: 'Aktivitas',
                value: data?.activity ?? '--',
                unit: '',
                subtitle: data != null ? _getTimeAgo(data.date) : 'Belum ada data',
                statusText: data?.activity != null ? 'Tercatat' : 'Belum ada',
                statusColor: data?.activity != null ? AppColors.success : Colors.grey,
                changeIndicator: '',
                changeColor: AppColors.activity,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes menit lalu';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }

  String _getBloodPressureStatus(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) return 'N/A';
    if (systolic < 90 || diastolic < 60) return 'Rendah';
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 140 || diastolic < 90) return 'Tinggi';
    return 'Sangat Tinggi';
  }

  Color _getBloodPressureColor(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) return Colors.grey;
    if (systolic < 90 || diastolic < 60) return Colors.blue; // Rendah
    if (systolic < 120 && diastolic < 80) return AppColors.success; // Normal
    if (systolic < 140 || diastolic < 90) return AppColors.warning; // Tinggi
    return Colors.red; // Sangat Tinggi
  }

  String _getBloodSugarStatus(int? bloodSugar) {
    if (bloodSugar == null) return 'N/A';
    if (bloodSugar < 70) return 'Rendah';
    if (bloodSugar <= 140) return 'Normal';
    return 'Tinggi';
  }

  Color _getBloodSugarColor(int? bloodSugar) {
    if (bloodSugar == null) return Colors.grey;
    if (bloodSugar < 70) return Colors.blue; // Rendah
    if (bloodSugar <= 140) return AppColors.success; // Normal
    return Colors.red; // Tinggi
  }

  String _getWeightStatus(double? weight, double? height) {
    if (weight == null) return 'N/A';
    // Gunakan 'Masukan tinggi badan' jika tinggi belum diinputkan
    if (height == null || height <= 0) return 'Masukan tinggi badan';
    
    // Hitung BMI
    // BMI = weight (kg) / (height (m))^2
    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);
    
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Gemuk';
    return 'Obesitas';
  }

  Color _getWeightStatusColor(double? weight, double? height) {
    if (weight == null) return Colors.grey;
    if (height == null || height <= 0) return AppColors.warning; // Alert untuk input tinggi
    
    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);
    
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25.0) return AppColors.success;
    if (bmi < 30.0) return AppColors.warning;
    return Colors.red;
  }
}
