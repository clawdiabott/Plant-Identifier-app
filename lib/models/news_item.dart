class NewsItem {
  const NewsItem({
    required this.title,
    required this.summary,
    required this.link,
    this.publishedAt,
  });

  final String title;
  final String summary;
  final String link;
  final DateTime? publishedAt;
}
