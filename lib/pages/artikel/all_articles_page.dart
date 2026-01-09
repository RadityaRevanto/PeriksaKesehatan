import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/article/article_model.dart';
import '../../../data/datasources/dummy_article_data.dart';
import 'widget/article_card.dart';

class AllArticlesPage extends StatefulWidget {
  const AllArticlesPage({super.key});

  @override
  State<AllArticlesPage> createState() => _AllArticlesPageState();
}

class _AllArticlesPageState extends State<AllArticlesPage> {
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    // Get unique categories from dummy data
    final Set<String> categoriesSet = {'Semua'};
    for (var article in dummyArticles) {
      categoriesSet.add(article.category);
    }
    final List<String> categories = categoriesSet.toList();

    // Filter articles
    final filteredArticles = _selectedCategory == 'Semua'
        ? dummyArticles
        : dummyArticles.where((article) => article.category == _selectedCategory).toList();

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
          'Semua Artikel',
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
          // Category Filter
          SingleChildScrollView(
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
          ),

          // Article List
          Expanded(
            child: filteredArticles.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada artikel ditemukan',
                      style: GoogleFonts.nunitoSans(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filteredArticles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return ArticleCard(article: filteredArticles[index]);
                    },
                  ),
          ),
        ],
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
}
