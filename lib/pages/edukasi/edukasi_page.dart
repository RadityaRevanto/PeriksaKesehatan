import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../peringatan-kesehatan/widgets/video_card.dart';

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          'Edukasi Kesehatan',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Implementasi search
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter Category Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('Semua'),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Diabetes'),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Hipertensi'),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Jantung'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Video Edukasi Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Video Edukasi',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                InkWell(
                  onTap: () {
                    // TODO: Navigasi ke semua video
                  },
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Video Cards List
            _buildVideoList(),
            
            const SizedBox(height: 32),
            
            // Artikel Kesehatan Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Artikel Kesehatan',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                InkWell(
                  onTap: () {
                    // TODO: Navigasi ke semua artikel
                  },
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Artikel Cards List
            _buildArticleList(),
            
            const SizedBox(height: 20), // Extra spacing at bottom
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoList() {
    // Sample video data
    final List<Map<String, dynamic>> videos = [
      {
        'title': 'Mengenal Hipertensi dan Cara Mengatasinya',
        'language': 'Bahasa Indonesia',
        'doctor': 'Dr. Siti Nurhaliza',
        'duration': '5:32',
        'views': '2.4k',
        'likes': '156',
        'playButtonColor': const Color(0xFF4CAF50),
        'category': 'Hipertensi',
      },
      {
        'title': 'Diabetes: Gejala, Penyebab, dan Pencegahan',
        'language': 'Bahasa Jawa',
        'doctor': 'Dr. Budi Santoso',
        'duration': '7:15',
        'views': '1.8k',
        'likes': '98',
        'playButtonColor': const Color(0xFFFF7043),
        'category': 'Diabetes',
      },
      {
        'title': 'Menjaga Kesehatan Jantung dengan Pola Hidup Sehat',
        'language': 'Bahasa Indonesia',
        'doctor': 'Dr. Ahmad Fauzi',
        'duration': '6:45',
        'views': '3.2k',
        'likes': '245',
        'playButtonColor': const Color(0xFFE53935),
        'category': 'Jantung',
      },
      {
        'title': 'Menjaga Berat Badan Ideal untuk Kesehatan',
        'language': 'Bahasa Sunda',
        'doctor': 'Dr. Rina Melati',
        'duration': '4:48',
        'views': '3.1k',
        'likes': '203',
        'playButtonColor': const Color(0xFF2196F3),
        'category': 'Semua',
      },
      {
        'title': 'Panduan Diet untuk Penderita Diabetes',
        'language': 'Bahasa Indonesia',
        'doctor': 'Dr. Maya Sari',
        'duration': '8:20',
        'views': '1.5k',
        'likes': '112',
        'playButtonColor': const Color(0xFFFF7043),
        'category': 'Diabetes',
      },
      {
        'title': 'Mengontrol Tekanan Darah Tinggi',
        'language': 'Bahasa Jawa',
        'doctor': 'Dr. Supriyadi',
        'duration': '5:10',
        'views': '2.1k',
        'likes': '178',
        'playButtonColor': const Color(0xFF4CAF50),
        'category': 'Hipertensi',
      },
    ];

    // Filter videos berdasarkan category
    final filteredVideos = _selectedCategory == 'Semua'
        ? videos
        : videos.where((video) => video['category'] == _selectedCategory).toList();

    return Column(
      children: filteredVideos.map((video) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VideoCard(
            title: video['title'] as String,
            language: video['language'] as String,
            doctor: video['doctor'] as String,
            duration: video['duration'] as String,
            views: video['views'] as String,
            likes: video['likes'] as String,
            playButtonColor: video['playButtonColor'] as Color,
            onTap: () {
              // TODO: Implementasi navigasi ke video player
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildArticleList() {
    // Sample article data
    final List<Map<String, dynamic>> articles = [
      {
        'title': '10 Makanan Sehat untuk Penderita Diabetes',
        'category': 'Diabetes',
        'categoryColor': AppColors.success.withOpacity(0.2),
        'categoryTextColor': AppColors.success,
        'readingTime': '5 menit baca',
        'imageColor': const Color(0xFFE8F5E9),
      },
      {
        'title': 'Cara Menurunkan Tekanan Darah Secara Alami',
        'category': 'Hipertensi',
        'categoryColor': AppColors.success.withOpacity(0.2),
        'categoryTextColor': AppColors.success,
        'readingTime': '7 menit baca',
        'imageColor': const Color(0xFFE8F5E9),
      },
      {
        'title': 'Tanda-tanda Penyakit Jantung yang Harus Diwaspadai',
        'category': 'Jantung',
        'categoryColor': AppColors.bloodSugarBg,
        'categoryTextColor': AppColors.bloodSugar,
        'readingTime': '6 menit baca',
        'imageColor': const Color(0xFFE3F2FD),
      },
      {
        'title': 'Mengelola Stres untuk Kesehatan yang Lebih Baik',
        'category': 'Mental',
        'categoryColor': AppColors.warningBg,
        'categoryTextColor': AppColors.warning,
        'readingTime': '8 menit baca',
        'imageColor': const Color(0xFFFFF8E1),
      },
    ];

    // Filter articles berdasarkan category
    final filteredArticles = _selectedCategory == 'Semua'
        ? articles
        : articles.where((article) => article['category'] == _selectedCategory).toList();

    return Column(
      children: filteredArticles.map((article) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildArticleCard(article),
        );
      }).toList(),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigasi ke detail artikel
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: article['imageColor'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.article,
                color: (article['imageColor'] as Color).withOpacity(0.5),
                size: 40,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: article['categoryColor'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article['category'] as String,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: article['categoryTextColor'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    article['title'] as String,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Reading Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article['readingTime'] as String,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}