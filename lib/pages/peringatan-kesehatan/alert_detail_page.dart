import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/domain/entities/health_alert.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/info_card.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/action_card.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/puskesmas_card.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/video_card.dart';
import 'package:periksa_kesehatan/services/maps_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:periksa_kesehatan/core/di/injection_container.dart' as di;
import 'package:periksa_kesehatan/presentation/bloc/education/education_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/education/education_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/education/education_state.dart';
import 'package:periksa_kesehatan/data/models/education/education_model.dart';
import 'package:periksa_kesehatan/pages/edukasi/video_player_page.dart';

class AlertDetailPage extends StatefulWidget {
  final HealthAlert alert;
  
  const AlertDetailPage({
    super.key,
    required this.alert,
  });

  @override
  State<AlertDetailPage> createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late EducationBloc _educationBloc;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _educationBloc = di.sl<EducationBloc>();
    _educationBloc.add(const FetchEducationalVideosEvent());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _educationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorByStatus(widget.alert.status);
    final bgColor = _getBgColorByStatus(widget.alert.status);
    final icon = _getIconByStatus(widget.alert.status);
    final dateTime = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(widget.alert.recordedAt);
    
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
          'Detail Peringatan',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                        widget.alert.alertType,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF212121),
                        ),
                      ),
                          const SizedBox(height: 4),
                          Text(
                            dateTime,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 13,
                    ),
                    ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                       child: Text(
                      widget.alert.status,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.alert.label, // Retained original content, applied new style
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          color: const Color(0xFF616161),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                      widget.alert.value,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppColors.primary,
              labelStyle: GoogleFonts.nunitoSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.nunitoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: const [
                Tab(text: 'Penjelasan'),
                Tab(text: 'Tindakan'),
                Tab(text: 'Kapan ke RS'),
                Tab(text: 'Tips'),
                Tab(text: 'Video'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Penjelasan
                _buildExplanationTab(),
                
                // Tab 2: Tindakan Segera
                _buildImmediateActionsTab(),
                
                // Tab 3: Kapan Harus ke Puskesmas
                _buildMedicalAttentionTab(),
                
                // Tab 4: Tips Pengelolaan
                _buildManagementTipsTab(),
                
                // Tab 5: Video Edukasi
                _buildVideoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExplanationTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        InfoCard(
          title: 'Apa Artinya?',
          content: widget.alert.explanation,
          iconColor: _getColorByStatus(widget.alert.status),
          icon: Icons.info,
        ),
      ],
    );
  }
  
  Widget _buildImmediateActionsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.alert.immediateActions.isNotEmpty)
          ActionCard(
            title: 'Tindakan Segera',
            iconColor: const Color(0xFFE53935),
            icon: Icons.warning,
            actions: widget.alert.immediateActions,
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada tindakan segera yang diperlukan',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildMedicalAttentionTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.alert.medicalAttention.isNotEmpty)
          PuskesmasCard(
            title: 'Kapan Harus ke Puskesmas/RS?',
            introText: 'Segera kunjungi fasilitas kesehatan jika:',
            conditions: widget.alert.medicalAttention,
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
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada kondisi khusus yang memerlukan perhatian medis segera',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildManagementTipsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.alert.managementTips.isNotEmpty)
          Container(
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tips Pengelolaan',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...widget.alert.managementTips.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tip = entry.value;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < widget.alert.managementTips.length - 1 ? 16 : 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada tips pengelolaan khusus',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildVideoTab() {
    return BlocBuilder<EducationBloc, EducationState>(
      bloc: _educationBloc,
      builder: (context, state) {
        if (state is EducationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<VideoModel> displayVideos = [];

        if (state is EducationDataLoaded) {
          // 1. Cari kategori exact match dengan alert.category
          var matchingCat = state.categories.firstWhere(
            (c) => c.kategori.toLowerCase() == widget.alert.category.toLowerCase(),
            orElse: () => EducationCategoryModel(id: -1, kategori: '', videos: []),
          );

          if (matchingCat.id != -1) {
            displayVideos = matchingCat.videos;
          } else {
            // 2. Fallback: cari kategori yang mengandung kata dari alert.alertType
            matchingCat = state.categories.firstWhere(
              (c) => c.kategori.toLowerCase().contains(widget.alert.alertType.toLowerCase()),
              orElse: () => EducationCategoryModel(id: -1, kategori: '', videos: []),
            );
            if (matchingCat.id != -1) {
              displayVideos = matchingCat.videos;
            }
          }
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
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
                    'Pelajari lebih lanjut tentang kondisi kesehatan Anda melalui video berikut',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (displayVideos.isEmpty && state is! EducationLoading)
                     Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.videocam_off_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada video terkait peringatan ini',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                     )
                  else
                    ...displayVideos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final video = entry.value;
                      final color = _getColorByStatus(widget.alert.status);
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < displayVideos.length - 1 ? 16 : 0),
                        child: VideoCard(
                          title: video.title,
                          language: 'Bahasa Indonesia', // Default fallback
                          doctor: 'Tim Edukasi',         // Default fallback
                          duration: video.duration ?? '05:00',
                          playButtonColor: color,
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
                                    duration: video.duration ?? '05:00',
                                  ),
                                ),
                              );
                          },
                        ),
                      );
                    }).toList(),
                  
                  const SizedBox(height: 16),
                  
                  if (displayVideos.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                           // Navigasi ke halaman Edukasi utama jika diperlukan user
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
                            const Icon(
                              Icons.video_library_outlined,
                              color: Color(0xFF4CAF50),
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
            ),
          ],
        );
      },
    );
  }
  

  
  Color _getColorByStatus(String status) {
    switch (status.toUpperCase()) {
      case 'TINGGI':
      case 'SANGAT TINGGI':
        return const Color(0xFFD68910); // Softer orange
      case 'RENDAH':
      case 'SANGAT RENDAH':
        return const Color(0xFF1976D2); // Deeper blue
      case 'KRITIS':
        return const Color(0xFFC62828); // Deeper red
      default:
        return const Color(0xFF388E3C); // Deeper green
    }
  }
  
  Color _getBgColorByStatus(String status) {
    switch (status.toUpperCase()) {
      case 'TINGGI':
      case 'SANGAT TINGGI':
        return const Color(0xFFFFF4E0); // Warmer beige
      case 'RENDAH':
      case 'SANGAT RENDAH':
        return const Color(0xFFE1F5FE); // Lighter blue
      case 'KRITIS':
        return const Color(0xFFFFEBEE); // Keep soft pink
      default:
        return const Color(0xFFE8F5E9); // Keep soft green
    }
  }
  
  IconData _getIconByStatus(String status) {
    switch (status.toUpperCase()) {
      case 'TINGGI':
      case 'SANGAT TINGGI':
        return Icons.warning;
      case 'RENDAH':
      case 'SANGAT RENDAH':
        return Icons.trending_down;
      case 'KRITIS':
        return Icons.error_outline;
      default:
        return Icons.check_circle_outline;
    }
  }
}
