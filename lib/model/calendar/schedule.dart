enum ScheduleCategory { appointment, popup, reservation, etc }

String enumToApi(ScheduleCategory c) {
  switch (c) {
    case ScheduleCategory.appointment:
      return 'APPOINTMENT';
    case ScheduleCategory.popup:
      return 'POPUP';
    case ScheduleCategory.reservation:
      return 'RESERVATION';
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
    case 'RESERVATION':
      return ScheduleCategory.reservation;
    default:
      return ScheduleCategory.etc;
  }
}

class Schedule {
  final int id;
  final String title;
  final String memo;
  final ScheduleCategory category;
  final DateTime date; // 로컬 자정 기준

  Schedule({
    required this.id,
    required this.title,
    required this.memo,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toBody({bool asDateOnly = true}) {
    String _yyyyMmDd(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final only = DateTime(date.year, date.month, date.day);
    return {
      'title': title,
      'memo': memo,
      'category': enumToApi(category),
      'date': asDateOnly
          ? _yyyyMmDd(only)
          : DateTime.utc(only.year, only.month, only.day).toIso8601String(),
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final raw = json['date'] as String? ?? '';
    DateTime parsed;
    if (raw.length >= 19) {
      parsed = DateTime.parse(raw).toLocal();
    } else if (raw.length >= 10) {
      final d = raw.substring(0, 10);
      parsed = DateTime.parse('${d}T00:00:00');
    } else {
      parsed = DateTime.now();
    }
    final only = DateTime(parsed.year, parsed.month, parsed.day);

    return Schedule(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      memo: json['memo'] as String? ?? '',
      category: catFromApi(json['category'] as String? ?? 'ETC'),
      date: only,
    );
  }

  Schedule copyWith({
    int? id,
    String? title,
    String? memo,
    ScheduleCategory? category,
    DateTime? date,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }
}
