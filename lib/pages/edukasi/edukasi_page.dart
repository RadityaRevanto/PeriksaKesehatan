import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/education/education_model.dart';
import '../../data/datasources/dummy_article_data.dart';
import '../../presentation/bloc/education/education_bloc.dart';
import '../../presentation/bloc/education/education_event.dart';
import '../../presentation/bloc/education/education_state.dart';
import '../peringatan-kesehatan/widgets/video_card.dart';
import '../artikel/all_articles_page.dart';
import '../artikel/widget/article_card.dart';
import 'video_player_page.dart';
import 'all_videos_page.dart';

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  String _selectedCategory = 'Semua';
  List<EducationCategoryModel> _allCategories = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<EducationBloc>().add(const FetchEducationalVideosEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari topik kesehatan...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.nunitoSans(
                    color: AppColors.textSecondary,
                  ),
                ),
                style: GoogleFonts.nunitoSans(
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Text(
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
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EducationDataLoaded) {
            _allCategories = state.categories;
          }

          if (_allCategories.isEmpty && state is! EducationLoading) {
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
                    'Belum ada data edukasi',
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

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isSearching) ...[
                   _buildCategoryChips(),
                   const SizedBox(height: 24),
                ],

                // Videos Section
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
                    if (!_isSearching)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllVideosPage(
                                initialCategories: _allCategories,
                              ),
                            ),
                          );
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
                _buildVideoList(),

                const SizedBox(height: 32),

                // Articles Section
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
                    if (!_isSearching)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllArticlesPage(),
                            ),
                          );
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
                _buildArticleList(),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
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
    List<VideoModel> videos = [];

    // 1. Gather all potential videos based on category selection (or all if searching)
    if (_isSearching) {
       for (var category in _allCategories) {
        videos.addAll(category.videos);
      }
    } else {
       if (_selectedCategory == 'Semua') {
        for (var category in _allCategories) {
          videos.addAll(category.videos);
        }
      } else {
        final selectedCat = _allCategories.firstWhere(
          (cat) => cat.kategori == _selectedCategory,
          orElse: () => EducationCategoryModel(id: 0, kategori: '', videos: []),
        );
        videos = selectedCat.videos;
      }
    }

    // 2. Apply Search Filter if active
    if (_isSearching && _searchQuery.isNotEmpty) {
       videos = videos.where((video) => video.title.toLowerCase().contains(_searchQuery)).toList();
    }

    if (videos.isEmpty) {
       return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _isSearching ? 'Tidak ada video yang cocok dengan pencarian' : 'Belum ada video untuk kategori $_selectedCategory',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

     // 3. Apply Limits (only if NOT searching)
    if (!_isSearching && _selectedCategory == 'Semua') {
      videos = videos.take(5).toList();
    }

    return Column(
      children: videos.asMap().entries.map((entry) {
        final video = entry.value;
        final index = entry.key;
        
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
            language: 'Bahasa Indonesia',
            doctor: 'Tim Edukasi',
            duration: video.duration ?? '5:00',

            playButtonColor: colors[index % colors.length],
            videoUrl: video.url,
            thumbnailUrl: video.thumbnailUrl,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(
                    videoUrl: video.url,
                    title: video.title,
                    language: 'Bahasa Indonesia',
                    doctor: 'Tim Edukasi',
                    duration: video.duration ?? '5:00',

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
    // 1. Filter based on category or gather all
    var filteredArticles = _isSearching || _selectedCategory == 'Semua'
        ? dummyArticles
        : dummyArticles.where((article) => article.category == _selectedCategory).toList();

    // 2. Apply Search Filter
    if (_isSearching && _searchQuery.isNotEmpty) {
       filteredArticles = filteredArticles.where((article) => 
          article.title.toLowerCase().contains(_searchQuery) ||
          article.content.toLowerCase().contains(_searchQuery)
       ).toList();
    }

    if (filteredArticles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _isSearching ? 'Tidak ada artikel yang cocok dengan pencarian' : 'Belum ada artikel untuk kategori $_selectedCategory',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 3. Limit to 4 articles IF NOT searching (main page view)
    if (!_isSearching) {
       filteredArticles = filteredArticles.take(4).toList();
    }

    return Column(
      children: filteredArticles.map((article) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ArticleCard(article: article),
        );
      }).toList(),
    );
  }
}