import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class BantuanDukunganPage extends StatefulWidget {
  const BantuanDukunganPage({super.key});

  @override
  State<BantuanDukunganPage> createState() => _BantuanDukunganPageState();
}

class _BantuanDukunganPageState extends State<BantuanDukunganPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _faqList = [
    {
      'question': 'Bagaimana cara mengubah profil saya?',
      'answer': 'Anda dapat mengubah profil Anda dengan masuk ke halaman Profil, kemudian ketuk ikon edit atau pilih menu "Ubah Profil" jika tersedia. Pastikan untuk menyimpan perubahan setelah selesai.'
    },
    {
      'question': 'Bagaimana cara melihat riwayat kesehatan?',
      'answer': 'Riwayat kesehatan dapat dilihat pada menu "Riwayat" di navigasi bawah. Di sana Anda dapat melihat grafik dan daftar pemeriksaan kesehatan yang telah Anda lakukan.'
    },
    {
      'question': 'Apakah data kesehatan saya aman?',
      'answer': 'Ya, kami memprioritaskan keamanan data Anda. Semua data kesehatan disimpan dengan enkripsi dan hanya dapat diakses oleh Anda. Kami tidak membagikan data Anda kepada pihak ketiga tanpa persetujuan Anda.'
    },
    {
      'question': 'Bagaimana cara menghubungi dokter?',
      'answer': 'Saat ini fitur konsultasi langsung dengan dokter sedang dalam pengembangan. Anda dapat menggunakan fitur "Edukasi" untuk mendapatkan informasi kesehatan umum atau pergi ke fasilitas kesehatan terdekat jika membutuhkan bantuan medis segera.'
    },
    {
      'question': 'Lupa kata sandi, apa yang harus dilakukan?',
      'answer': 'Jika Anda lupa kata sandi, silakan kembali ke halaman Login dan pilih opsi "Lupa Kata Sandi". Ikuti instruksi yang diberikan untuk mengatur ulang kata sandi Anda melalui email yang terdaftar.'
    },
  ];

  List<Map<String, String>> _filteredFaqList = [];

  @override
  void initState() {
    super.initState();
    _filteredFaqList = _faqList;
    _searchController.addListener(_filterFaq);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaq() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaqList = _faqList.where((faq) {
        return faq['question']!.toLowerCase().contains(query) ||
            faq['answer']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka tautan: $urlString'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

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
          'Bantuan & Dukungan',
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
        child: Column(
          children: [
            _buildHeaderSearch(),
            const SizedBox(height: 20),
            _buildContactSupport(),
            const SizedBox(height: 20),
            _buildFaqSection(),
            const SizedBox(height: 30),
            _buildFooterInfo(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSearch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bagaimana kami bisa membantu?',
            style: GoogleFonts.nunitoSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cari topik bantuan atau hubungi kami langsung.',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan...',
                hintStyle: GoogleFonts.nunitoSans(color: Colors.grey),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
              ),
              style: GoogleFonts.nunitoSans(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupport() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hubungi Kami',
            style: GoogleFonts.nunitoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildContactCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Chat Support',
                  subtitle: 'Respon cepat',
                  color: const Color(0xFF25D366), // WhatsApp Color
                  onTap: () {
                    // Example: Open WhatsApp
                    // _launchUrl('https://wa.me/6281234567890');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membuka WhatsApp Support...')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildContactCard(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'Kirim pesan',
                  color: const Color(0xFFEA4335), // Gmail Color
                  onTap: () {
                     // _launchUrl('mailto:support@periksakesehatan.com');
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membuka Email...')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pertanyaan Umum',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _filteredFaqList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Tidak ada hasil ditemukan',
                        style: GoogleFonts.nunitoSans(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: _filteredFaqList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final faq = entry.value;
                      final isLast = index == _filteredFaqList.length - 1;

                      return Column(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              childrenPadding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              title: Text(
                                faq['question']!,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              iconColor: AppColors.primary,
                              collapsedIconColor: Colors.grey,
                              children: [
                                Text(
                                  faq['answer']!,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            const Divider(
                              height: 1,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Color(0xFFF0F0F0),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        Text(
          'Versi Aplikasi 1.0.5',
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2025 Periksa Kesehatan. All rights reserved.',
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
