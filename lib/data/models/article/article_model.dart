class ArticleModel {
  final int id;
  final String title;
  final String category;
  final String author;
  final String date;
  final String readTime;
  final String imageUrl;
  final String content;

  ArticleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.date,
    required this.readTime,
    required this.imageUrl,
    required this.content,
  });
}
