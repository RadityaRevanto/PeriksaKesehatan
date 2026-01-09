import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/education/education_model.dart';
import '../../presentation/bloc/education/education_bloc.dart';
import '../../presentation/bloc/education/education_event.dart';
import '../../presentation/bloc/education/education_state.dart';
import '../peringatan-kesehatan/widgets/video_card.dart';
import 'video_player_page.dart';

class AllVideosPage extends StatefulWidget {
  final List<EducationCategoryModel> initialCategories;

  const AllVideosPage({
    super.key,
    this.initialCategories = const [],
  });

  @override
  State<AllVideosPage> createState() => _AllVideosPageState();
}

class _AllVideosPageState extends State<AllVideosPage> {
  String _selectedCategory = 'Semua';
  List<EducationCategoryModel> _allCategories = [];

  @override
  void initState() {
    super.initState();
    _allCategories = widget.initialCategories;
    // If categories are empty, try fetching. But typically we pass them.
    if (_allCategories.isEmpty) {
       context.read<EducationBloc>().add(const FetchEducationalVideosEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Semua Video',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
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
          // If loading and we have no data yet
          if (state is EducationLoading && _allCategories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // If loaded, update local state
          if (state is EducationDataLoaded) {
             _allCategories = state.categories;
          }

          if (_allCategories.isEmpty) {
             return Center(
              child: Text(
                'Belum ada data video',
                 style: GoogleFonts.nunitoSans(
                  color: AppColors.textSecondary,
                 ),
              ),
            );
          }

          return Column(
            children: [
               // Category Chips
               _buildCategoryChips(),

               // Video List
               Expanded(child: _buildVideoList()),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
     // Filter videos based on category
    List<VideoModel> videos = [];
    if (_selectedCategory == 'Semua') {
      // Get all videos
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

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: videos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final video = videos[index];
        
         // Color variations for play buttons
        final colors = [
          const Color(0xFF4CAF50),
          const Color(0xFFFF7043),
          const Color(0xFFE53935),
          const Color(0xFF2196F3),
        ];

        return VideoCard(
            title: video.title,
            language: 'Bahasa Indonesia',
            doctor: 'Tim Edukasi',
            duration: video.duration ?? '5:00',
            views: '1.2k',
            likes: '100',
            playButtonColor: colors[index % colors.length],
            videoUrl: video.url,
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
                    views: '1.2k',
                    likes: '100',
                  ),
                ),
              );
            },
          );
      },
    );
  }
}
