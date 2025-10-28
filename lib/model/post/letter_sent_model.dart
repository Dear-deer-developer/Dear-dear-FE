class SentLetter {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String? imageUrl;
  final String status;
  final DateTime? sentAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SentLetter({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.imageUrl,
    required this.status,
    this.sentAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SentLetter.fromJson(Map<String, dynamic> json) {
    return SentLetter(
      id: json['id'] ?? 0,
      senderId: json['senderId'] ?? 0,
      receiverId: json['receiverId'] ?? 0,
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'] ?? '',
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "senderId": senderId,
        "receiverId": receiverId,
        "content": content,
        "imageUrl": imageUrl,
        "status": status,
        "sentAt": sentAt?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
