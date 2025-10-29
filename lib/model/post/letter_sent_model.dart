class SentLetter {
  final int id;
  final int receiverId;
  final String content;
  final int? paperId;
  final DateTime? sentAt;

  SentLetter({
    required this.id,
    required this.receiverId,
    required this.content,
    this.paperId,
    this.sentAt,
  });

  factory SentLetter.fromJson(Map<String, dynamic> j) {
    final raw = j['sentAt'] ?? j['createdAt'];
    DateTime? parsed;
    if (raw != null) {
      try {
        parsed = DateTime.parse(raw.toString());
      } catch (_) {}
    }
    return SentLetter(
      id: j['id'],
      receiverId: j['receiverId'],
      content: j['content'] ?? '',
      paperId: j['paperId'],
      sentAt: parsed,
    );
  }
}
