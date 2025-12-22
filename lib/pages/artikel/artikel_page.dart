import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';

class ArtikelPage extends StatefulWidget {
  const ArtikelPage({super.key});

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  bool isBookmarked = false;

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
          'Artikel',
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
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.share,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Share.share(
                '10 Makanan Sehat untuk Penderita Diabetes yang Aman Dikonsumsi',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8E6B8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Diabetes',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                '10 Makanan Sehat untuk Penderita Diabetes yang Aman Dikonsumsi',
                style: GoogleFonts.nunitoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                  height: 1.3,
                ),
              ),
            ),

            // Author Info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  // Profile Picture
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Author Name and Metadata
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Author Name
                        Text(
                          'Dr. Sarah Wijaya',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        // Date
                        Text(
                          '15 Januari 2024',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        // Dot Separator
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        // Reading Time
                        Text(
                          '8 menit baca',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main Image
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image,
                size: 80,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // Article Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diabetes merupakan kondisi kronis yang memerlukan pengelolaan pola makan yang tepat. Memilih makanan yang tepat sangat penting untuk menjaga kadar gula darah tetap stabil dan mencegah komplikasi jangka panjang.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Berikut adalah 10 makanan sehat yang aman dan direkomendasikan untuk penderita diabetes:',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 1
                  Text(
                    '1. Sayuran Hijau',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sayuran hijau seperti bayam, kangkung, dan brokoli kaya akan serat dan nutrisi penting. Mereka memiliki indeks glikemik rendah dan membantu mengontrol kadar gula darah. Selain itu, sayuran hijau juga mengandung antioksidan yang baik untuk kesehatan secara keseluruhan.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 2
                  Text(
                    '2. Ikan Berlemak',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ikan seperti salmon, tuna, dan sarden kaya akan asam lemak omega-3 yang baik untuk kesehatan jantung. Protein dalam ikan juga membantu menjaga rasa kenyang dan mengontrol gula darah.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 3
                  Text(
                    '3. Kacang-kacangan',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kacang-kacangan seperti almond, kenari, dan kacang tanah mengandung serat, protein, dan lemak sehat. Mereka memiliki indeks glikemik rendah dan dapat membantu mengontrol kadar gula darah.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 4
                  Text(
                    '4. Oatmeal',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Oatmeal adalah sumber karbohidrat kompleks yang baik untuk penderita diabetes. Pilih oatmeal tanpa tambahan gula dan konsumsi dengan protein untuk membantu menstabilkan gula darah.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 5
                  Text(
                    '5. Buah Beri',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buah beri seperti stroberi, blueberry, dan raspberry kaya akan antioksidan dan serat. Mereka memiliki indeks glikemik rendah dibandingkan buah-buahan lainnya.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 6
                  Text(
                    '6. Yoghurt Yunani',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yoghurt yunani tanpa pemanis adalah sumber protein yang baik dan memiliki karbohidrat rendah. Probiotik dalam yoghurt juga baik untuk kesehatan pencernaan.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 7
                  Text(
                    '7. Telur',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Telur adalah sumber protein berkualitas tinggi yang dapat membantu mengontrol nafsu makan dan gula darah. Konsumsi telur dalam jumlah yang wajar sangat baik untuk penderita diabetes.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 8
                  Text(
                    '8. Bawang Putih',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bawang putih memiliki sifat anti-inflamasi dan dapat membantu menurunkan kadar gula darah. Tambahkan bawang putih ke dalam masakan untuk mendapatkan manfaatnya.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 9
                  Text(
                    '9. Ubi Jalar',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ubi jalar memiliki indeks glikemik lebih rendah dibandingkan kentang biasa. Kaya akan serat dan vitamin A, ubi jalar adalah pilihan karbohidrat yang baik untuk penderita diabetes.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List Item 10
                  Text(
                    '10. Cuka Apel',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuka apel dapat membantu meningkatkan sensitivitas insulin dan menurunkan kadar gula darah setelah makan. Gunakan sebagai dressing salad atau tambahkan ke dalam minuman.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Closing Paragraph
                  Text(
                    'Penting untuk diingat bahwa setiap penderita diabetes memiliki kebutuhan yang berbeda. Konsultasikan dengan dokter atau ahli gizi untuk membuat rencana makan yang sesuai dengan kondisi Anda. Kombinasikan makanan sehat ini dengan olahraga teratur dan pengobatan yang tepat untuk mengelola diabetes dengan baik.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Kesimpulan Section
                  Text(
                    'Kesimpulan',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mengelola diabetes memerlukan pendekatan holistik yang mencakup pola makan sehat, aktivitas fisik teratur, dan konsultasi medis yang tepat. Dengan memilih makanan yang tepat dan mengikuti saran dari tenaga kesehatan profesional, penderita diabetes dapat menjaga kualitas hidup yang baik dan mencegah komplikasi jangka panjang.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingatlah bahwa setiap individu memiliki kebutuhan yang unik. Oleh karena itu, penting untuk bekerja sama dengan tim medis Anda dalam merancang rencana perawatan yang personal dan efektif. Dengan komitmen dan disiplin, diabetes dapat dikelola dengan baik.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Divider
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                  ),
                  const SizedBox(height: 24),
                  
                  // Author Information Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Author Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. Sarah Wijaya',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dokter Spesialis Penyakit Dalam dengan fokus pada pengelolaan diabetes dan metabolisme.',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Artikel Terkait Section
                  Text(
                    'Artikel Terkait',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Related Article Card 1
                  _buildRelatedArticleCard(
                    title: 'Cara Menurunkan Tekanan Darah Secara Alami',
                    category: 'Hipertensi',
                    categoryColor: AppColors.success.withOpacity(0.2),
                    categoryTextColor: AppColors.success,
                    readingTime: '7 menit baca',
                    imageColor: const Color(0xFFE8F5E9),
                  ),
                  const SizedBox(height: 16),
                  
                  // Related Article Card 2
                  _buildRelatedArticleCard(
                    title: 'Tanda-tanda Penyakit Jantung yang Harus Diwaspadai',
                    category: 'Jantung',
                    categoryColor: AppColors.bloodSugarBg,
                    categoryTextColor: AppColors.bloodSugar,
                    readingTime: '6 menit baca',
                    imageColor: const Color(0xFFE3F2FD),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedArticleCard({
    required String title,
    required String category,
    required Color categoryColor,
    required Color categoryTextColor,
    required String readingTime,
    required Color imageColor,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigasi ke artikel terkait
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
                color: imageColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.article,
                color: imageColor.withOpacity(0.5),
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
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
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
                    title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
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
                        readingTime,
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