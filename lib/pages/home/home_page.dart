import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/widgets/cards/health_metric_card.dart';
import 'package:periksa_kesehatan/pages/input/input_data_kesehatan_page.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/peringatan_kesehatan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                              'Selamat Pagi,',
                              style: GoogleFonts.nunitoSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ibu Siti',
                              style: GoogleFonts.nunitoSans(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Senin, 15 Januari 2025',
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
                    // Health metrics grid
                    Row(
                      children: [
                        Expanded(
                          child: HealthMetricCard(
                            icon: Icons.favorite,
                            iconColor: AppColors.heartRate,
                            iconBgColor: AppColors.heartRateBg,
                            title: 'Tekanan Darah',
                            value: '120',
                            unit: '/80',
                            subtitle: '2 jam lalu',
                            statusText: 'Normal',
                            statusColor: AppColors.success,
                            changeIndicator: '↓ -2%',
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
                            value: '145',
                            unit: 'mg/dL',
                            subtitle: '5 jam lalu',
                            statusText: 'Perhatian',
                            statusColor: AppColors.warning,
                            changeIndicator: '↑ +8%',
                            changeColor: AppColors.warning,
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
                            value: '65',
                            unit: 'kg',
                            subtitle: 'Kemarin',
                            statusText: 'Normal',
                            statusColor: AppColors.success,
                            changeIndicator: '↓ -0.5kg',
                            changeColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HealthMetricCard(
                            icon: Icons.directions_walk,
                            iconColor: AppColors.activity,
                            iconBgColor: AppColors.activityBg,
                            title: 'Aktivitas',
                            value: '3,245',
                            unit: 'langkah',
                            subtitle: 'Hari ini',
                            statusText: 'Bagus',
                            statusColor: AppColors.success,
                            changeIndicator: '↑ +12%',
                            changeColor: AppColors.success,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InputDataKesehatanPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAddReadingButton(
                                  icon: Icons.water_drop,
                                  label: 'Gula Darah',
                                  color: AppColors.bloodSugar,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InputDataKesehatanPage(),
                                      ),
                                    );
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InputDataKesehatanPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAddReadingButton(
                                  icon: Icons.directions_walk,
                                  label: 'Aktivitas',
                                  color: AppColors.activity,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InputDataKesehatanPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PeringatanKesehatanPage()),
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
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gula darah Anda sedikit tinggi. Hindari makanan manis dan segera konsultasi dengan dokter jika terus meningkat.',
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
                    // Warning banner
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InputDataKesehatanPage(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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

}
