// schedule.dart

enum ScheduleCategory { appointment, popup, ticketing, etc }

String enumToApi(ScheduleCategory c) {
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

ScheduleCategory catFromApi(String s) {
  switch (s) {
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

class Schedule {
  final int id;
  final String title;
  final String memo;
  final ScheduleCategory category;
  final DateTime date; // 항상 '로컬의 자정' 형태로 유지

  Schedule({
    required this.id,
    required this.title,
    required this.memo,
    required this.category,
    required this.date,
  });

  // YYYY-MM-DD만 보내기
  Map<String, dynamic> toBody({bool asDateOnly = true}) {
    String _yyyyMmDd(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final onlyDate = DateTime(date.year, date.month, date.day);
    return {
      'title': title,
      'memo': memo,
      'category': enumToApi(category),
      'date': asDateOnly
          ? _yyyyMmDd(onlyDate) // 날짜만
          : onlyDate.toIso8601String(), // (필요시) 시간 포함하되 UTC 변환 금지
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final raw = json['date'] as String? ?? '';
    DateTime parsed;

    if (raw.length >= 19) {
      // ISO8601 (예: 2025-11-05T00:00:00.000Z)
      parsed = DateTime.parse(raw).toLocal();
    } else if (raw.length >= 10) {
      // YYYY-MM-DD
      final d = raw.substring(0, 10);
      parsed = DateTime.parse('$d' 'T00:00:00');
    } else {
      parsed = DateTime.now();
    }

    final onlyDate = DateTime(parsed.year, parsed.month, parsed.day);

    return Schedule(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      memo: json['memo'] as String? ?? '',
      category: catFromApi(json['category'] as String? ?? 'ETC'),
      date: onlyDate, // 항상 날짜만
    );
  }
}
