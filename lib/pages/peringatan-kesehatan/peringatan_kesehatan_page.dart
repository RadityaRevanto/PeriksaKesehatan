import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/warning_card.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/info_card.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/action_card.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/puskesmas_card.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/tips_section.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/video_section.dart';
import 'package:periksa_kesehatan/services/maps_service.dart';

class PeringatanKesehatanPage extends StatefulWidget {
  const PeringatanKesehatanPage({super.key});

  @override
  State<PeringatanKesehatanPage> createState() => _PeringatanKesehatanPageState();
}

class _PeringatanKesehatanPageState extends State<PeringatanKesehatanPage> {
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Kartu 1: Tekanan Darah Tinggi
          WarningCard(
            icon: Icons.warning,
            iconColor: const Color(0xFFFF9800),
            title: 'Perhatian!',
            chipText: 'Tinggi',
            chipColor: const Color(0xFFFF9800),
            dateTime: '15 Januari 2025, 14:30',
            label: 'Tekanan Darah Anda',
            value: '160 / 100',
            unit: 'mmHg',
            valueColor: const Color(0xFFFF9800),
            statusText: 'Status: Tekanan Darah Tinggi (Hipertensi)',
            backgroundColor: const Color(0xFFFFF8E1),
            statusBgColor: const Color(0xFFFFF3C4),
          ),
          const SizedBox(height: 16),
          
          // Kartu 2: Gula Darah Rendah
          WarningCard(
            icon: Icons.error_outline,
            iconColor: const Color(0xFFE53935),
            title: 'Gula Darah Rendah',
            chipText: 'Kritis',
            chipColor: const Color(0xFFE53935),
            dateTime: '15 Januari 2025, 09:15',
            label: 'Gula Darah Anda',
            value: '65',
            unit: 'mg/dL',
            valueColor: const Color(0xFFE53935),
            statusText: 'Status: Hipoglikemia (Gula Darah Rendah)',
            backgroundColor: const Color(0xFFFFEBEE),
            statusBgColor: const Color(0xFFFFCDD2),
          ),
          const SizedBox(height: 16),
          
          // Kartu 3: Penurunan Berat Badan
          WarningCard(
            icon: Icons.trending_down,
            iconColor: const Color(0xFF2196F3),
            title: 'Penurunan Berat Badan',
            chipText: 'Sedang',
            chipColor: const Color(0xFF2196F3),
            dateTime: '14 Januari 2025, 07:00',
            label: 'Berat Badan Anda',
            value: '62',
            unit: 'kg',
            valueColor: const Color(0xFF2196F3),
            statusText: 'Status: Penurunan Berat Badan Signifikan',
            backgroundColor: const Color(0xFFE3F2FD),
            statusBgColor: const Color(0xFFBBDEFB),
            additionalInfo: '↓ 5 kg dalam 2 minggu',
          ),
          const SizedBox(height: 16),
          
          // Kartu Informasi: Apa Artinya?
          InfoCard(
            title: 'Apa Artinya?',
            content:
                'Tekanan darah Anda berada di atas batas normal (140/90 mmHg). Kondisi ini menunjukkan jantung Anda bekerja lebih keras untuk memompa darah ke seluruh tubuh. Jika tidak ditangani, dapat meningkatkan risiko penyakit jantung dan stroke.',
            iconColor: const Color(0xFF4CAF50),
            icon: Icons.info,
          ),
          const SizedBox(height: 16),
          
          // Kartu Tindakan: Tindakan Segera
          ActionCard(
            title: 'Tindakan Segera',
            iconColor: const Color(0xFFE53935),
            icon: Icons.warning,
            actions: [
              'Duduk atau berbaring dengan tenang selama 10-15 menit',
              'Tarik napas dalam-dalam dan coba rileks',
              'Hindari makanan asin dan kafein hari ini',
              'Ukur kembali tekanan darah dalam 30 menit',
            ],
          ),
          const SizedBox(height: 16),
          
          // Kartu Puskesmas: Kapan Harus ke Puskesmas?
          PuskesmasCard(
            title: 'Kapan Harus ke Puskesmas?',
            introText: 'Segera kunjungi puskesmas jika:',
            conditions: [
              'Tekanan darah tetap tinggi setelah 1 jam istirahat',
              'Mengalami sakit kepala parah atau pusing',
              'Sesak napas atau nyeri dada',
              'Pandangan kabur atau mual',
              'Gula darah di bawah 70 mg/dL atau di atas 250 mg/dL',
              'Penurunan berat badan lebih dari 5% dalam sebulan tanpa sebab jelas',
            ],
            buttonText: 'Cari Puskesmas Terdekat',
            onButtonTap: () async {
              try {
                await MapsService.openMapsSearch('puskesmas terdekat');
              } catch (e) {
                if (mounted) {
                  final errorMessage = e.toString().replaceAll('Exception: ', '');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Section Tips Pengelolaan
          const TipsSection(),
          const SizedBox(height: 16),
          
          // Section Video Edukasi Kesehatan
          const VideoSection(),
          const SizedBox(height: 16),
          
          // Section Tombol Aksi
          // Tombol Bagikan Data dengan Dokter
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implementasi share data dengan dokter
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bagikan Data dengan Dokter',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Dua tombol di bawah
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implementasi ingatkan nanti
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Ingatkan Nanti',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F5E9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}