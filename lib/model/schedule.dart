enum ScheduleCategory { appointment, popup, ticketing, etc }

// 서버 <-> 앱 카테고리 매핑
ScheduleCategory catFromApi(String v) {
  switch (v) {
    case 'APPOINTMENT':
      return ScheduleCategory.appointment;
    case 'POPUP':
      return ScheduleCategory.popup;
    case 'TICKETING':
      return ScheduleCategory.ticketing;
    default:
      return ScheduleCategory.etc;
  }
}

String catToApi(ScheduleCategory c) {
  switch (c) {
    case ScheduleCategory.appointment:
      return 'APPOINTMENT';
    case ScheduleCategory.popup:
      return 'POPUP';
    case ScheduleCategory.ticketing:
      return 'TICKETING';
    case ScheduleCategory.etc:
      return 'ETC';
  }
}

// (UI에서 쓰는 한글 라벨이 필요하면)
String catLabel(ScheduleCategory c) {
  switch (c) {
    case ScheduleCategory.appointment:
      return '약속';
    case ScheduleCategory.popup:
      return '팝업';
    case ScheduleCategory.ticketing:
      return '티켓팅&예약';
    case ScheduleCategory.etc:
      return '기타';
  }
}

class Schedule {
  final int id;
  final String title;
  final String memo;
  final ScheduleCategory category;
  final DateTime date;

  Schedule({
    required this.id,
    required this.title,
    required this.memo,
    required this.category,
    required this.date,
  });

  factory Schedule.fromJson(Map<String, dynamic> j) => Schedule(
        id: (j['id'] as num).toInt(),
        title: j['title'] ?? '',
        memo: j['memo'] ?? '',
        category: catFromApi(j['category']),
        date: DateTime.parse(j['date']),
      );

  Map<String, dynamic> toBody({bool asDateOnly = false}) => {
        'title': title,
        'memo': memo,
        'category': catToApi(category),
        'date': asDateOnly
            ? '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
            : date.toUtc().toIso8601String(),
      };

  Schedule copyWith({
    int? id,
    String? title,
    String? memo,
    ScheduleCategory? category,
    DateTime? date,
  }) =>
      Schedule(
        id: id ?? this.id,
        title: title ?? this.title,
        memo: memo ?? this.memo,
        category: category ?? this.category,
        date: date ?? this.date,
      );
}
