import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(
          'Kebijakan Privasi',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.authPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.authPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.authPrimary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.authPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Terakhir diperbarui: 15 Januari 2026',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: AppColors.authPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Introduction
            _buildSectionTitle('Pendahuluan'),
            _buildParagraph(
              'Periksa Kesehatan sangat menghargai privasi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi informasi pribadi Anda saat menggunakan aplikasi kami.',
            ),

            const SizedBox(height: 20),

            // 1. Informasi yang Kami Kumpulkan
            _buildSectionTitle('1. Informasi yang Kami Kumpulkan'),
            _buildParagraph(
              'Kami mengumpulkan beberapa jenis informasi untuk memberikan layanan terbaik kepada Anda:',
            ),
            
            _buildSubsectionTitle('a. Informasi Pribadi'),
            _buildBulletPoint('Nama lengkap'),
            _buildBulletPoint('Alamat email'),
            _buildBulletPoint('Tanggal lahir'),
            _buildBulletPoint('Jenis kelamin'),
            _buildBulletPoint('Nomor telepon (opsional)'),

            const SizedBox(height: 12),

            _buildSubsectionTitle('b. Data Kesehatan'),
            _buildBulletPoint('Tekanan darah'),
            _buildBulletPoint('Detak jantung'),
            _buildBulletPoint('Kadar gula darah'),
            _buildBulletPoint('Berat badan dan tinggi badan'),
            _buildBulletPoint('Riwayat kesehatan yang Anda input'),

            const SizedBox(height: 12),

            _buildSubsectionTitle('c. Informasi Teknis'),
            _buildBulletPoint('Alamat IP'),
            _buildBulletPoint('Jenis perangkat dan sistem operasi'),
            _buildBulletPoint('Waktu dan tanggal penggunaan aplikasi'),
            _buildBulletPoint('Log aktivitas aplikasi'),

            const SizedBox(height: 20),

            // 2. Bagaimana Kami Menggunakan Informasi
            _buildSectionTitle('2. Bagaimana Kami Menggunakan Informasi'),
            _buildParagraph(
              'Informasi yang kami kumpulkan digunakan untuk:',
            ),
            _buildBulletPoint('Menyediakan dan memelihara layanan aplikasi'),
            _buildBulletPoint('Memproses dan menyimpan data kesehatan Anda'),
            _buildBulletPoint('Mengirimkan notifikasi dan pengingat kesehatan'),
            _buildBulletPoint('Meningkatkan pengalaman pengguna'),
            _buildBulletPoint('Menganalisis penggunaan aplikasi untuk perbaikan'),
            _buildBulletPoint('Mendeteksi dan mencegah aktivitas penipuan'),

            const SizedBox(height: 20),

            // 3. Penyimpanan Data
            _buildSectionTitle('3. Penyimpanan Data'),
            _buildParagraph(
              'Keamanan data Anda adalah prioritas utama kami:',
            ),
            _buildBulletPoint('Data disimpan di server yang aman dan terenkripsi'),
            _buildBulletPoint('Kami menggunakan enkripsi SSL/TLS untuk transmisi data'),
            _buildBulletPoint('Data kesehatan Anda juga disimpan secara lokal di perangkat Anda'),
            _buildBulletPoint('Backup data dilakukan secara berkala'),
            _buildBulletPoint('Akses ke data dibatasi hanya untuk personel yang berwenang'),

            const SizedBox(height: 20),

            // 4. Berbagi Informasi
            _buildSectionTitle('4. Berbagi Informasi'),
            _buildParagraph(
              'Kami TIDAK akan menjual, menyewakan, atau membagikan informasi pribadi Anda kepada pihak ketiga, kecuali:',
            ),
            _buildBulletPoint('Dengan persetujuan eksplisit dari Anda'),
            _buildBulletPoint('Untuk mematuhi kewajiban hukum'),
            _buildBulletPoint('Untuk melindungi hak dan keamanan kami atau pengguna lain'),
            _buildBulletPoint('Dengan penyedia layanan yang membantu operasional aplikasi (dengan perjanjian kerahasiaan)'),

            const SizedBox(height: 20),

            // 5. Hak Anda
            _buildSectionTitle('5. Hak Anda'),
            _buildParagraph(
              'Anda memiliki hak untuk:',
            ),
            _buildBulletPoint('Mengakses data pribadi Anda kapan saja'),
            _buildBulletPoint('Memperbarui atau mengoreksi informasi Anda'),
            _buildBulletPoint('Menghapus akun dan semua data Anda'),
            _buildBulletPoint('Mengekspor data kesehatan Anda'),
            _buildBulletPoint('Menarik persetujuan penggunaan data'),
            _buildBulletPoint('Mengajukan keluhan terkait privasi'),

            const SizedBox(height: 20),

            // 6. Mode Offline
            _buildSectionTitle('6. Mode Offline'),
            _buildParagraph(
              'Aplikasi kami mendukung mode offline:',
            ),
            _buildBulletPoint('Data disimpan secara lokal di perangkat Anda saat offline'),
            _buildBulletPoint('Sinkronisasi otomatis dilakukan saat koneksi tersedia'),
            _buildBulletPoint('Anda tetap memiliki kontrol penuh atas data lokal'),

            const SizedBox(height: 20),

            // 7. Cookies dan Teknologi Pelacakan
            _buildSectionTitle('7. Cookies dan Teknologi Pelacakan'),
            _buildParagraph(
              'Kami menggunakan cookies dan teknologi serupa untuk:',
            ),
            _buildBulletPoint('Mengingat preferensi Anda'),
            _buildBulletPoint('Menjaga sesi login Anda'),
            _buildBulletPoint('Menganalisis penggunaan aplikasi'),
            _buildBulletPoint('Meningkatkan performa aplikasi'),

            const SizedBox(height: 20),

            // 8. Keamanan Data
            _buildSectionTitle('8. Keamanan Data'),
            _buildParagraph(
              'Kami menerapkan langkah-langkah keamanan yang ketat:',
            ),
            _buildBulletPoint('Enkripsi end-to-end untuk data sensitif'),
            _buildBulletPoint('Autentikasi dua faktor (opsional)'),
            _buildBulletPoint('Pemantauan keamanan 24/7'),
            _buildBulletPoint('Audit keamanan berkala'),
            _buildBulletPoint('Pelatihan keamanan untuk tim kami'),

            const SizedBox(height: 20),

            // 9. Privasi Anak-anak
            _buildSectionTitle('9. Privasi Anak-anak'),
            _buildParagraph(
              'Aplikasi ini tidak ditujukan untuk anak-anak di bawah usia 17 tahun. Kami tidak dengan sengaja mengumpulkan informasi pribadi dari anak-anak. Jika Anda adalah orang tua dan mengetahui bahwa anak Anda telah memberikan informasi pribadi kepada kami, silakan hubungi kami.',
            ),

            const SizedBox(height: 20),

            // 10. Perubahan Kebijakan
            _buildSectionTitle('10. Perubahan Kebijakan Privasi'),
            _buildParagraph(
              'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Perubahan akan:',
            ),
            _buildBulletPoint('Diumumkan melalui aplikasi'),
            _buildBulletPoint('Dikirimkan melalui email (untuk perubahan signifikan)'),
            _buildBulletPoint('Berlaku setelah dipublikasikan'),

            const SizedBox(height: 20),

            // 11. Retensi Data
            _buildSectionTitle('11. Retensi Data'),
            _buildParagraph(
              'Kami menyimpan data Anda selama:',
            ),
            _buildBulletPoint('Akun Anda aktif'),
            _buildBulletPoint('Diperlukan untuk menyediakan layanan'),
            _buildBulletPoint('Diwajibkan oleh hukum'),
            _buildBulletPoint('Setelah penghapusan akun, data akan dihapus dalam 30 hari'),

            const SizedBox(height: 20),

            // 12. Hubungi Kami
            _buildSectionTitle('12. Hubungi Kami'),
            _buildParagraph(
              'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini atau ingin menggunakan hak privasi Anda, silakan hubungi kami:',
            ),
            _buildBulletPoint('Email: privacy@periksekesehatan.com'),
            _buildBulletPoint('Telepon: +62 21 1234 5678'),
            _buildBulletPoint('Alamat: Jakarta, Indonesia'),

            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.authPrimary,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Privasi Anda adalah Prioritas Kami',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.authPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami berkomitmen untuk melindungi data kesehatan dan informasi pribadi Anda dengan standar keamanan tertinggi.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      color: const Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF444444),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.nunitoSans(
          fontSize: 14,
          color: const Color(0xFF555555),
          height: 1.6,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: AppColors.authPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: const Color(0xFF555555),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
