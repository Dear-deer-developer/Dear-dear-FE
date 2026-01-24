import 'package:flutter/material.dart';
import 'package:dear_deer_demo/view/calendar/calendar_category_meta.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String memo;

  /// 한글 라벨(약속/팝업/티켓팅&예약/기타)
  final String category;
  final DateTime date;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.memo,
    required this.category,
    required this.date,
  });

  Color get categoryColor => CalendarCategoryMeta.colorByLabel(category);

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? memo,
    String? category,
    DateTime? date,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }
}
