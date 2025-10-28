class ContentItem {
  final String id;
  final String title;
  final String subtitle;
  final String author;
  final int views;
  final int scraps;
  final String thumbnailUrl;

  ContentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.views,
    required this.scraps,
    required this.thumbnailUrl,
  });

  // 서버 연동 대비: JSON 파싱
  factory ContentItem.fromJson(Map<String, dynamic> j) => ContentItem(
        id: j['id']?.toString() ?? '',
        title: j['title'] ?? '',
        subtitle: j['subtitle'] ?? '',
        author: j['author'] ?? '',
        views: j['views'] ?? 0,
        scraps: j['scraps'] ?? 0,
        thumbnailUrl: j['thumbnailUrl'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'author': author,
        'views': views,
        'scraps': scraps,
        'thumbnailUrl': thumbnailUrl,
      };
}
