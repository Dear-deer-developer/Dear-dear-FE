class DeardeerUser {
  final int id;
  final String nickname;
  final String providerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 선택값 (로그/표시용)
  final int? zipCode;
  final String? email;

  const DeardeerUser({
    required this.id,
    required this.nickname,
    required this.providerId,
    required this.createdAt,
    required this.updatedAt,
    this.zipCode,
    this.email,
  });

  factory DeardeerUser.fromJson(Map<String, dynamic> j) {
    return DeardeerUser(
      id: j['id'] as int,
      nickname: (j['nickname'] ?? '') as String,
      providerId: (j['providerId'] ?? '') as String,
      email: j['email'] as String?,
      zipCode: j['zipCode'] is int
          ? j['zipCode'] as int
          : int.tryParse(j['zipCode']?.toString() ?? ''),
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'providerId': providerId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'zipCode': zipCode,
        'email': email,
      };
}
// 이전 kakao login user code
// class DeardeerUser {
//   final int id;
//   final String nickname; // 닉네임
//   final int zipCode; // 우편번호
//   final String providerId; // 고유 식별자
//   final DateTime createdAt; // 사용자 가입일
//   final DateTime updatedAt; // 사용자 정보 변경

//   const DeardeerUser({
//     required this.id,
//     required this.nickname,
//     required this.zipCode,
//     required this.providerId,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory DeardeerUser.fromJson(Map<String, dynamic> j) {
//     return DeardeerUser(
//       id: j['id'] as int,
//       nickname: (j['nickname'] ?? '') as String,
//       zipCode: j['zipCode'] is int
//           ? j['zipCode'] as int
//           : int.tryParse(j['zipCode']?.toString() ?? '') ?? 0,
//       providerId: (j['providerId'] ?? '') as String,
//       createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ??
//           DateTime.fromMillisecondsSinceEpoch(0),
//       updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? '') ??
//           DateTime.fromMillisecondsSinceEpoch(0),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'nickname': nickname,
//         'zipCode': zipCode,
//         'providerId': providerId,
//         'createdAt': createdAt.toIso8601String(),
//         'updatedAt': updatedAt.toIso8601String(),
//       };
// }
