import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(
          'Syarat & Ketentuan',
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
                    Icons.info_outline,
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
              'Selamat datang di aplikasi Periksa Kesehatan. Dengan menggunakan aplikasi ini, Anda setuju untuk terikat dengan syarat dan ketentuan berikut. Harap baca dengan saksama sebelum menggunakan layanan kami.',
            ),

            const SizedBox(height: 20),

            // 1. Penggunaan Aplikasi
            _buildSectionTitle('1. Penggunaan Aplikasi'),
            _buildParagraph(
              'Aplikasi Periksa Kesehatan dirancang untuk membantu Anda memantau dan mengelola data kesehatan pribadi Anda. Dengan menggunakan aplikasi ini, Anda menyetujui bahwa:',
            ),
            _buildBulletPoint('Anda berusia minimal 17 tahun atau memiliki izin dari orang tua/wali'),
            _buildBulletPoint('Informasi yang Anda berikan adalah akurat dan terkini'),
            _buildBulletPoint('Anda bertanggung jawab atas keamanan akun Anda'),
            _buildBulletPoint('Anda tidak akan menggunakan aplikasi untuk tujuan ilegal'),

            const SizedBox(height: 20),

            // 2. Akun Pengguna
            _buildSectionTitle('2. Akun Pengguna'),
            _buildParagraph(
              'Untuk menggunakan fitur lengkap aplikasi, Anda perlu membuat akun dengan memberikan informasi yang valid. Anda bertanggung jawab untuk:',
            ),
            _buildBulletPoint('Menjaga kerahasiaan password Anda'),
            _buildBulletPoint('Semua aktivitas yang terjadi di bawah akun Anda'),
            _buildBulletPoint('Memberitahu kami segera jika terjadi penggunaan tidak sah'),

            const SizedBox(height: 20),

            // 3. Data Kesehatan
            _buildSectionTitle('3. Data Kesehatan'),
            _buildParagraph(
              'Aplikasi ini memungkinkan Anda untuk memasukkan dan menyimpan data kesehatan pribadi. Harap diperhatikan:',
            ),
            _buildBulletPoint('Data kesehatan Anda disimpan secara aman dan terenkripsi'),
            _buildBulletPoint('Anda memiliki kontrol penuh atas data Anda'),
            _buildBulletPoint('Aplikasi ini BUKAN pengganti konsultasi medis profesional'),
            _buildBulletPoint('Selalu konsultasikan dengan tenaga medis untuk diagnosis dan perawatan'),

            const SizedBox(height: 20),

            // 4. Privasi dan Keamanan
            _buildSectionTitle('4. Privasi dan Keamanan'),
            _buildParagraph(
              'Kami berkomitmen untuk melindungi privasi Anda. Data pribadi dan kesehatan Anda:',
            ),
            _buildBulletPoint('Tidak akan dibagikan kepada pihak ketiga tanpa izin Anda'),
            _buildBulletPoint('Disimpan dengan standar keamanan tinggi'),
            _buildBulletPoint('Dapat dihapus kapan saja atas permintaan Anda'),

            const SizedBox(height: 20),

            // 5. Batasan Tanggung Jawab
            _buildSectionTitle('5. Batasan Tanggung Jawab'),
            _buildParagraph(
              'Aplikasi Periksa Kesehatan disediakan "sebagaimana adanya". Kami tidak bertanggung jawab atas:',
            ),
            _buildBulletPoint('Keputusan medis yang dibuat berdasarkan data dari aplikasi'),
            _buildBulletPoint('Kerugian yang timbul dari penggunaan atau ketidakmampuan menggunakan aplikasi'),
            _buildBulletPoint('Gangguan teknis atau kehilangan data'),

            const SizedBox(height: 20),

            // 6. Perubahan Layanan
            _buildSectionTitle('6. Perubahan Layanan'),
            _buildParagraph(
              'Kami berhak untuk:',
            ),
            _buildBulletPoint('Mengubah atau menghentikan layanan kapan saja'),
            _buildBulletPoint('Memperbarui syarat dan ketentuan ini'),
            _buildBulletPoint('Menambah atau mengurangi fitur aplikasi'),

            const SizedBox(height: 20),

            // 7. Hak Kekayaan Intelektual
            _buildSectionTitle('7. Hak Kekayaan Intelektual'),
            _buildParagraph(
              'Semua konten, fitur, dan fungsi aplikasi ini adalah milik Periksa Kesehatan dan dilindungi oleh hak cipta dan hukum kekayaan intelektual lainnya.',
            ),

            const SizedBox(height: 20),

            // 8. Penghentian Akun
            _buildSectionTitle('8. Penghentian Akun'),
            _buildParagraph(
              'Kami berhak untuk menangguhkan atau menghentikan akun Anda jika:',
            ),
            _buildBulletPoint('Anda melanggar syarat dan ketentuan ini'),
            _buildBulletPoint('Anda menggunakan aplikasi untuk tujuan yang merugikan'),
            _buildBulletPoint('Atas permintaan Anda sendiri'),

            const SizedBox(height: 20),

            // 9. Hukum yang Berlaku
            _buildSectionTitle('9. Hukum yang Berlaku'),
            _buildParagraph(
              'Syarat dan ketentuan ini diatur oleh dan ditafsirkan sesuai dengan hukum yang berlaku di Republik Indonesia.',
            ),

            const SizedBox(height: 20),

            // 10. Hubungi Kami
            _buildSectionTitle('10. Hubungi Kami'),
            _buildParagraph(
              'Jika Anda memiliki pertanyaan tentang Syarat & Ketentuan ini, silakan hubungi kami melalui:',
            ),
            _buildBulletPoint('Email: support@periksekesehatan.com'),
            _buildBulletPoint('Telepon: +62 21 1234 5678'),

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
              child: Text(
                'Dengan menggunakan aplikasi Periksa Kesehatan, Anda menyatakan bahwa Anda telah membaca, memahami, dan menyetujui Syarat & Ketentuan ini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  color: const Color(0xFF666666),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
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
