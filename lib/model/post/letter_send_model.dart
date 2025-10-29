// MARK: 편지 전송 모델
class Letter {
  final int receiverId;
  final int paperId;
  final String content;
  final String? imageUrl;

  Letter({
    required this.receiverId,
    required this.paperId,
    required this.content,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'paperId': paperId,
      'content': content,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
    };
  }
}
