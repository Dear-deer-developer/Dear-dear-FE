class Letter {
  final int receiverId;
  final String content;
  final String? imageUrl;

  Letter({
    required this.receiverId,
    required this.content,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        "receiverId": receiverId,
        "content": content,
        "imageUrl": imageUrl,
      };
}
