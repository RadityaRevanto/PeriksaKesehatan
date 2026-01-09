import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';

class SyaratKetentuanPage extends StatelessWidget {
  const SyaratKetentuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Syarat & Ketentuan',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(),
            const SizedBox(height: 20),
            _buildContentCard([
              _buildSection(
                '1. Pendahuluan',
                'Selamat datang di aplikasi Periksa Kesehatan. Dengan menggunakan aplikasi ini, Anda setuju untuk terikat oleh syarat dan ketentuan berikut. Jika Anda tidak setuju dengan bagian mana pun dari syarat ini, mohon untuk tidak menggunakan aplikasi kami.',
              ),
              _buildDivider(),
              _buildSection(
                '2. Penggunaan Aplikasi',
                'Aplikasi ini dirancang untuk membantu Anda memantau kesehatan pribadi. Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun Anda, termasuk kata sandi, dan untuk semua aktivitas yang terjadi di bawah akun Anda.',
              ),
              _buildDivider(),
              _buildSection(
                '3. Informasi Kesehatan',
                'Informasi yang disediakan dalam aplikasi ini hanya untuk tujuan informasi umum dan tidak dimaksudkan sebagai pengganti saran medis profesional, diagnosis, atau perawatan. Selalu konsultasikan dengan dokter atau penyedia layanan kesehatan profesional Anda untuk pertanyaan medis.',
              ),
              _buildDivider(),
              _buildSection(
                '4. Privasi Data',
                'Kami sangat menghargai privasi Anda. Pengumpulan dan penggunaan data pribadi Anda diatur oleh Kebijakan Privasi kami. Dengan menggunakan aplikasi, Anda menyetujui pengumpulan dan penggunaan informasi tersebut sesuai dengan Kebijakan Privasi.',
              ),
              _buildDivider(),
              _buildSection(
                '5. Hak Kekayaan Intelektual',
                'Layanan dan konten aslinya, fitur, dan fungsionalitas adalah dan akan tetap menjadi milik eksklusif Periksa Kesehatan dan pemberi lisensinya. Layanan ini dilindungi oleh hak cipta, merek dagang, dan hukum negara lainnya.',
              ),
              _buildDivider(),
              _buildSection(
                '6. Batasan Tanggung Jawab',
                'Dalam hal apa pun, Periksa Kesehatan, direktur, karyawan, mitra, agen, pemasok, atau afiliasinya, tidak bertanggung jawab atas kerusakan tidak langsung, insidental, khusus, konsekuensial, atau hukuman, termasuk namun tidak terbatas pada, hilangnya keuntungan, data, penggunaan, goodwill, atau kerugian tidak berwujud lainnya.',
              ),
              _buildDivider(),
              _buildSection(
                '7. Perubahan Syarat',
                'Kami berhak, atas kebijakan kami sendiri, untuk mengubah atau mengganti Syarat ini kapan saja. Jika revisi tersebut material, kami akan mencoba memberikan pemberitahuan setidaknya 30 hari sebelum syarat baru berlaku. Apa yang merupakan perubahan material akan ditentukan atas kebijakan kami sendiri.',
              ),
              _buildDivider(),
              _buildSection(
                '8. Kontak Kami',
                'Jika Anda memiliki pertanyaan tentang Syarat & Ketentuan ini, silakan hubungi kami melalui fitur Bantuan & Dukungan di dalam aplikasi.',
              ),
            ]),
            const SizedBox(height: 30),
            _buildAcceptButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Terakhir diperbarui: 09 Januari 2026',
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF5F5F5),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Saya Mengerti',
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
