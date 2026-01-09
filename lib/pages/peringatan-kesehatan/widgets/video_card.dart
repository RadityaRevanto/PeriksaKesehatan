import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String language;
  final String doctor;
  final String duration;

  final Color playButtonColor;
  final VoidCallback? onTap;
  final String? videoUrl; // Add video URL parameter
  final String? thumbnailUrl;

  const VideoCard({
    super.key,
    required this.title,
    required this.language,
    required this.doctor,
    required this.duration,
    this.playButtonColor = const Color(0xFF4CAF50),
    this.onTap,
    this.videoUrl, // Optional video URL
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Area
            Stack(
              children: [
                // YouTube Thumbnail or Placeholder
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: _buildThumbnail(),
                ),
                
                // Play Button Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
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
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: playButtonColor,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Duration Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      duration,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Video Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$language • $doctor',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Extract YouTube video ID from URL
  String? _extractYouTubeVideoId(String url) {
    try {
      url = url.trim();
      final uri = Uri.parse(url);
      
      // Format: https://youtu.be/VIDEO_ID
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      }
      
      // Format: https://www.youtube.com/watch?v=VIDEO_ID
      if (uri.host.contains('youtube.com') || uri.host.contains('m.youtube.com')) {
        return uri.queryParameters['v'];
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Get YouTube thumbnail URL
  String? _getYouTubeThumbnail(String videoUrl) {
    final videoId = _extractYouTubeVideoId(videoUrl);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return null;
  }
  
  /// Build thumbnail widget
  Widget _buildThumbnail() {
    // 1. Explicit Thumbnail (highest priority)
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      if (thumbnailUrl!.startsWith('assets/')) {
        return Image.asset(
          thumbnailUrl!,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } else {
         return Image.network(
          thumbnailUrl!,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 180,
              color: const Color(0xFFE8F5E9),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: playButtonColor,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    // 2. Derive from YouTube Video URL
    if (videoUrl != null && videoUrl!.isNotEmpty) {
      final ytThumbnailUrl = _getYouTubeThumbnail(videoUrl!);
      
      if (ytThumbnailUrl != null) {
        return Image.network(
          ytThumbnailUrl,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 180,
              color: const Color(0xFFE8F5E9),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: playButtonColor,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback to placeholder if thumbnail fails to load
            return _buildPlaceholder();
          },
        );
      }
    }
    
    // Default placeholder
    return _buildPlaceholder();
  }
  
  /// Build placeholder thumbnail
  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      color: const Color(0xFFE8F5E9),
    );
  }
}
