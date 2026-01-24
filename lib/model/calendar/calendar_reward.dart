// lib/model/calendar/calendar_reward.dart
class CalendarReward {
  final bool awarded;
  final String localDate; // "YYYY-MM-DD"
  final int? giftId;
  final String? giftName;
  final DateTime? awardedAt;

  CalendarReward({
    required this.awarded,
    required this.localDate,
    this.giftId,
    this.giftName,
    this.awardedAt,
  });

  factory CalendarReward.fromJson(Map<String, dynamic> j) {
    // 서버가 두 가지 형태를 줄 수 있음:
    // A) {"awarded": true, "giftName": "...", "localDate": "...", ...}
    // B) {"rewardType":"GIFT","received":true, ...}  // 스웨거 캡쳐 형태
    final rawDate = (j['localDate'] ?? j['date'] ?? '').toString().trim();
    final normDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

    final bool awarded =
        (j['awarded'] == true) || (j['received'] == true); // 둘 다 지원

    return CalendarReward(
      awarded: awarded,
      localDate: normDate, // 없으면 빈 문자열로
      giftId: j['giftId'] as int?, // 없으면 null
      giftName: (j['giftName'] ?? j['name']) as String?, // 없으면 null
      awardedAt:
          j['awardedAt'] != null ? DateTime.tryParse(j['awardedAt']) : null,
    );
  }

  CalendarReward copyWith({
    bool? awarded,
    String? localDate,
    int? giftId,
    String? giftName,
    DateTime? awardedAt,
  }) {
    return CalendarReward(
      awarded: awarded ?? this.awarded,
      localDate: localDate ?? this.localDate,
      giftId: giftId ?? this.giftId,
      giftName: giftName ?? this.giftName,
      awardedAt: awardedAt ?? this.awardedAt,
    );
  }
}
