import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/constants/app_colors.dart';
import '../../services/offline_video_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String language;
  final String doctor;
  final String duration;


  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.language,
    required this.doctor,
    required this.duration,

  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String? _statusMessage;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.videoUrl.isEmpty) {
        throw Exception('URL video tidak valid');
      }

      // 1. Cek jika ini adalah Asset Lokal (bukan URL internet)
      if (widget.videoUrl.startsWith('assets/')) {
        _videoPlayerController = VideoPlayerController.asset(widget.videoUrl);
      } 
      // 2. Jika URL Internet, gunakan logika Offline-First (Download)
      else {
        final offlineService = OfflineVideoService();
        String? localPath = await offlineService.getLocalVideoPath(widget.videoUrl);

        if (localPath == null) {
          if (mounted) {
            setState(() {
              _isDownloading = true;
              _statusMessage = 'Mengunduh video...';
              _errorMessage = '';
            });
          }

          localPath = await offlineService.downloadVideo(
            widget.videoUrl,
            (received, total) {
              if (total != -1) {
                if (mounted) {
                  setState(() {
                    _downloadProgress = received / total;
                  });
                }
              }
            },
          );
        }

        if (localPath == null) throw Exception('Gagal mendapatkan video');
        _videoPlayerController = VideoPlayerController.file(File(localPath));
      }

      // Initialize Controller (sama untuk keduanya)
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _statusMessage = 'Memuat player...';
        });
      }

      await _videoPlayerController.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        fullScreenByDefault: true,
        aspectRatio: 16 / 9,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: Colors.grey[300]!,
          bufferedColor: Colors.grey[200]!,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error memuat video',
                  style: GoogleFonts.nunitoSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: GoogleFonts.nunitoSans(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isDownloading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    // Reset orientation to portrait when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Video Edukasi',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isDownloading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mengunduh Video: ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.nunitoSans(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            )
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat video',
                        style: GoogleFonts.nunitoSans(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _errorMessage.isNotEmpty ? _errorMessage : 'Pastikan koneksi internet Anda stabil',
                          style: GoogleFonts.nunitoSans(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _hasError = false;
                          });
                          _initializeVideo();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Coba Lagi',
                          style: GoogleFonts.nunitoSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _chewieController == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Video Player
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Chewie(
                              controller: _chewieController!,
                            ),
                          ),
                          // Video Info
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  widget.title,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Doctor and Language
                                Text(
                                  '${widget.language} • ${widget.doctor}',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Engagement Metrics
                                Row(
                                  children: [

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.duration,
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
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

