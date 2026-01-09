import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/article/article_model.dart';
import '../artikel_page.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;

  const ArticleCard({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    Color categoryColor;
    Color categoryTextColor;

    switch (article.category.toLowerCase()) {
      case 'diabetes':
        categoryColor = AppColors.success.withOpacity(0.2);
        categoryTextColor = AppColors.success;
        break;
      case 'hipertensi':
        categoryColor = AppColors.success.withOpacity(0.2);
        categoryTextColor = AppColors.success;
        break;
      case 'jantung':
        categoryColor = AppColors.bloodSugarBg;
        categoryTextColor = AppColors.bloodSugar;
        break;
      case 'kesehatan mental':
        categoryColor = AppColors.warningBg;
        categoryTextColor = AppColors.warning;
        break;
      default:
        categoryColor = AppColors.primary.withOpacity(0.1);
        categoryTextColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtikelPage(article: article),
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
                color: categoryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: article.imageUrl.startsWith('assets') 
                  ? const Icon(Icons.article, size: 40, color: Colors.white)
                  : Image.network(
                      article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.article,
                        color: Colors.white,
                        size: 40,
                      ),
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
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article.category,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: categoryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    article.title,
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
                        article.readTime,
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
