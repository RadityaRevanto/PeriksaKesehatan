import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/domain/entities/health_alert.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/info_card.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/action_card.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/puskesmas_card.dart';
import 'package:periksa_kesehatan/services/maps_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
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
            fontSize: 18,
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateTime,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 13,
                              color: Colors.grey[600],
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
                          fontSize: 13,
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
                        widget.alert.label,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.alert.value,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 32,
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
          
          // Bottom Actions
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implementasi share data dengan dokter
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bagikan dengan Dokter',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.alert.educationVideos.isNotEmpty)
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
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Video Edukasi Kesehatan',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tonton video berikut untuk memahami lebih lanjut tentang kondisi Anda',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                // Debug: Print education videos
                Builder(
                  builder: (context) {
                    print('=== DEBUG EDUCATION VIDEOS ===');
                    print('Total videos: ${widget.alert.educationVideos.length}');
                    for (var i = 0; i < widget.alert.educationVideos.length; i++) {
                      print('Video $i: ${widget.alert.educationVideos[i]}');
                    }
                    print('==============================');
                    return const SizedBox.shrink();
                  },
                ),
                ...widget.alert.educationVideos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final video = entry.value;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < widget.alert.educationVideos.length - 1 ? 12 : 0),
                    child: InkWell(
                      onTap: () async {
                        try {
                          final Uri videoUri = Uri.parse(video);
                          if (await canLaunchUrl(videoUri)) {
                            await launchUrl(
                              videoUri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tidak dapat membuka video: $video'),
                                  backgroundColor: AppColors.error,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error membuka video: ${e.toString()}'),
                                backgroundColor: AppColors.error,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail section
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  // YouTube Thumbnail
                                  _getYouTubeThumbnail(video) != null
                                      ? Image.network(
                                          _getYouTubeThumbnail(video)!,
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            // Fallback if thumbnail fails to load
                                            return Container(
                                              width: double.infinity,
                                              height: 180,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.play_circle_outline,
                                                  size: 64,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: 180,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                              Icons.play_circle_outline,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                  
                                  // Play button overlay
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Duration badge (optional - you can remove if not needed)
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.play_circle_filled,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'YouTube',
                                            style: GoogleFonts.nunitoSans(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Video info section
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Video Edukasi ${index + 1}',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _extractYouTubeVideoId(video) != null
                                              ? 'Tonton video untuk informasi lebih lanjut'
                                              : video,
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    Icons.videocam_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada video edukasi',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video edukasi akan ditampilkan di sini jika tersedia',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.grey[500],
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
  
  /// Extract YouTube video ID from various YouTube URL formats
  String? _extractYouTubeVideoId(String url) {
    try {
      print('Extracting video ID from: $url');
      
      // Remove any whitespace
      url = url.trim();
      
      final uri = Uri.parse(url);
      
      // Format: https://youtu.be/VIDEO_ID or https://youtu.be/VIDEO_ID?si=...
      if (uri.host.contains('youtu.be')) {
        final videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        print('Extracted from youtu.be: $videoId');
        return videoId;
      }
      
      // Format: https://www.youtube.com/watch?v=VIDEO_ID
      // Format: https://youtube.com/watch?v=VIDEO_ID
      if (uri.host.contains('youtube.com')) {
        final videoId = uri.queryParameters['v'];
        print('Extracted from youtube.com: $videoId');
        return videoId;
      }
      
      // Format: https://m.youtube.com/watch?v=VIDEO_ID (mobile)
      if (uri.host.contains('m.youtube.com')) {
        final videoId = uri.queryParameters['v'];
        print('Extracted from m.youtube.com: $videoId');
        return videoId;
      }
      
      print('Could not extract video ID - unsupported format');
      return null;
    } catch (e) {
      print('Error extracting video ID: $e');
      return null;
    }
  }
  
  /// Get YouTube thumbnail URL from video URL
  /// Returns high quality thumbnail (hqdefault.jpg)
  String? _getYouTubeThumbnail(String videoUrl) {
    final videoId = _extractYouTubeVideoId(videoUrl);
    if (videoId != null) {
      // YouTube thumbnail formats:
      // - maxresdefault.jpg (1920x1080) - not always available
      // - sddefault.jpg (640x480)
      // - hqdefault.jpg (480x360) - reliable
      // - mqdefault.jpg (320x180)
      // - default.jpg (120x90)
      final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      print('Generated thumbnail URL: $thumbnailUrl');
      return thumbnailUrl;
    }
    print('Cannot generate thumbnail - video ID is null');
    return null;
  }
  
  Color _getColorByStatus(String status) {
    switch (status.toUpperCase()) {
      case 'TINGGI':
      case 'SANGAT TINGGI':
        return const Color(0xFFFF9800);
      case 'RENDAH':
      case 'SANGAT RENDAH':
        return const Color(0xFF2196F3);
      case 'KRITIS':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF4CAF50);
    }
  }
  
  Color _getBgColorByStatus(String status) {
    switch (status.toUpperCase()) {
      case 'TINGGI':
      case 'SANGAT TINGGI':
        return const Color(0xFFFFF8E1);
      case 'RENDAH':
      case 'SANGAT RENDAH':
        return const Color(0xFFE3F2FD);
      case 'KRITIS':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFE8F5E9);
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
