import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/education/education_model.dart';
import '../../presentation/bloc/education/education_bloc.dart';
import '../../presentation/bloc/education/education_event.dart';
import '../../presentation/bloc/education/education_state.dart';
import '../peringatan-kesehatan/widgets/video_card.dart';
import '../artikel/artikel_page.dart';
import 'video_player_page.dart';

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  String _selectedCategory = 'Semua';
  List<EducationCategoryModel> _allCategories = [];

  @override
  void initState() {
    super.initState();
    // Fetch data saat halaman dimuat
    context.read<EducationBloc>().add(const FetchEducationalVideosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: BlocConsumer<EducationBloc, EducationState>(
        listener: (context, state) {
          if (state is EducationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EducationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is EducationDataEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada video edukasi',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is EducationDataLoaded) {
            _allCategories = state.categories;
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter Category Buttons
                _buildCategoryChips(),
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
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    // Build category chips from API data
    List<String> categories = ['Semua'];
    if (_allCategories.isNotEmpty) {
      categories.addAll(_allCategories.map((cat) => cat.kategori).toList());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildCategoryChip(category),
          );
        }).toList(),
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
    if (_allCategories.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada video tersedia',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Filter videos berdasarkan category
    List<VideoModel> videos = [];
    if (_selectedCategory == 'Semua') {
      // Ambil semua video dari semua kategori
      for (var category in _allCategories) {
        videos.addAll(category.videos);
      }
    } else {
      // Ambil video dari kategori yang dipilih
      final selectedCat = _allCategories.firstWhere(
        (cat) => cat.kategori == _selectedCategory,
        orElse: () => EducationCategoryModel(id: 0, kategori: '', videos: []),
      );
      videos = selectedCat.videos;
    }

    if (videos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Belum ada video untuk kategori $_selectedCategory',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: videos.asMap().entries.map((entry) {
        final video = entry.value;
        final index = entry.key;
        
        // Color variations for play buttons
        final colors = [
          const Color(0xFF4CAF50),
          const Color(0xFFFF7043),
          const Color(0xFFE53935),
          const Color(0xFF2196F3),
        ];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VideoCard(
            title: video.title,
            language: 'Bahasa Indonesia', // Default, bisa disesuaikan
            doctor: 'Tim Edukasi', // Default, bisa disesuaikan
            duration: '5:00', // Default, bisa disesuaikan
            views: '1.2k', // Default, bisa disesuaikan
            likes: '100', // Default, bisa disesuaikan
            playButtonColor: colors[index % colors.length],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(
                    videoUrl: video.url,
                    title: video.title,
                    language: 'Bahasa Indonesia',
                    doctor: 'Tim Edukasi',
                    duration: '5:00',
                    views: '1.2k',
                    likes: '100',
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildArticleList() {
    // Sample article data (tetap menggunakan data dummy untuk artikel)
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

    if (filteredArticles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Belum ada artikel untuk kategori $_selectedCategory',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ArtikelPage(),
          ),
        );
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