import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/video_card.dart';

class VideoSection extends StatelessWidget {
  const VideoSection({super.key});

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
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF81C784),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.video_library,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Video Edukasi Kesehatan',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pelajari lebih lanjut tentang kondisi kesehatan Anda melalui video dalam bahasa lokal',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          
          // Video Cards
          VideoCard(
            title: 'Mengenal Hipertensi dan Cara Mengatasinya',
            language: 'Bahasa Indonesia',
            doctor: 'Dr. Siti Nurhaliza',
            duration: '5:32',

            playButtonColor: const Color(0xFF4CAF50),
            onTap: () {
              // TODO: Implementasi navigasi ke video player
            },
          ),
          const SizedBox(height: 16),
          VideoCard(
            title: 'Diabetes: Gejala, Penyebab, dan Pencegahan',
            language: 'Bahasa Jawa',
            doctor: 'Dr. Budi Santoso',
            duration: '7:15',

            playButtonColor: const Color(0xFFFF7043),
            onTap: () {
              // TODO: Implementasi navigasi ke video player
            },
          ),
          const SizedBox(height: 16),
          VideoCard(
            title: 'Menjaga Berat Badan Ideal untuk Kesehatan',
            language: 'Bahasa Sunda',
            doctor: 'Dr. Rina Melati',
            duration: '4:48',

            playButtonColor: const Color(0xFF2196F3),
            onTap: () {
              // TODO: Implementasi navigasi ke video player
            },
          ),
          const SizedBox(height: 16),
          
          // Tombol Lihat Semua Video
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implementasi navigasi ke halaman semua video
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    color: const Color(0xFF4CAF50),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lihat Semua Video',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
