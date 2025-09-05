// lib/model/deardeer_user.dart
class DeardeerUser {
  final int id;
  final String nickname;
  final int zipCode;
  final String providerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeardeerUser({
    required this.id,
    required this.nickname,
    required this.zipCode,
    required this.providerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeardeerUser.fromJson(Map<String, dynamic> j) {
    return DeardeerUser(
      id: j['id'] as int,
      nickname: (j['nickname'] ?? '') as String,
      zipCode: j['zipCode'] is int
          ? j['zipCode'] as int
          : int.tryParse(j['zipCode']?.toString() ?? '') ?? 0,
      providerId: (j['providerId'] ?? '') as String,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'zipCode': zipCode,
        'providerId': providerId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
