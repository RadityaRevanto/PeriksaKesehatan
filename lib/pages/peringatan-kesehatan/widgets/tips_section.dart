import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/pages/peringatan-kesehatan/widgets/tips_card.dart';

class TipsSection extends StatelessWidget {
  const TipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Header
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
                  Icons.health_and_safety,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tips Pengelolaan',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tips Cards
          TipsCard(
            icon: Icons.restaurant,
            iconColor: const Color(0xFF4CAF50),
            title: 'Diet Rendah Garam',
            description: 'Batasi konsumsi garam maksimal 1 sendok teh per hari',
          ),
          const SizedBox(height: 12),
          TipsCard(
            icon: Icons.directions_walk,
            iconColor: const Color(0xFF66BB6A),
            title: 'Olahraga Teratur',
            description: 'Jalan kaki 30 menit setiap hari dapat membantu menurunkan tekanan darah',
          ),
          const SizedBox(height: 12),
          TipsCard(
            icon: Icons.self_improvement,
            iconColor: const Color(0xFF66BB6A),
            title: 'Kelola Stress',
            description: 'Praktikkan teknik relaksasi dan pastikan tidur cukup 7-8 jam',
          ),
        ],
      ),
    );
  }
}
