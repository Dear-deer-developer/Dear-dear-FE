class Letter {
  final String content;
  final int receiverId;
  final int paperId;
  final String? imageUrl;

  Letter({
    required this.content,
    required this.receiverId,
    required this.paperId,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'receiverId': receiverId,
      'paperId': paperId,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
