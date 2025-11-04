class CalendarReward {
  final bool awarded;
  final String localDate; // "YYYY-MM-DD" 로 정규화해서 보관
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
    final raw = (j['localDate'] ?? '').toString().trim();
    final normDate = raw.isEmpty
        ? ''
        : raw.length >= 10
            ? raw.substring(0, 10) // "YYYY-MM-DD"만 사용
            : raw; // 혹시 짧게 오면 그대로
    return CalendarReward(
      awarded: j['awarded'] == true,
      localDate: normDate,
      giftId: j['giftId'] as int?,
      giftName: j['giftName'] as String?,
      awardedAt: j['awardedAt'] != null ? DateTime.parse(j['awardedAt']) : null,
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
