import 'package:flutter/material.dart';

/// UI -> API enum
const Map<String, String> kUiToApiCategory = {
  '약속': 'APPOINTMENT',
  '팝업': 'POPUP',
  '티켓팅&예약': 'TICKETING',
  '기타': 'ETC',
};

/// API -> UI 라벨
const Map<String, String> kApiToUiCategory = {
  'APPOINTMENT': '약속',
  'POPUP': '팝업',
  'TICKETING': '티켓팅&예약',
  'ETC': '기타',
};

/// 정렬 우선순위(낮을수록 우선)
const Map<String, int> kCategoryPriority = {
  '약속': 0,
  '팝업': 1,
  '티켓팅&예약': 2,
  '기타': 3,
};

/// 카테고리별 색상
const Map<String, Color> kCategoryColors = {
  '약속': Colors.red,
  '팝업': Colors.green,
  '티켓팅&예약': Colors.yellow,
  '기타': Colors.black,
};

class CalendarEvent {
  final String id;
  final String title;
  final String memo;
  final String category; // 약속/팝업/티켓팅&예약/기타
  final DateTime date; // 이벤트 날짜

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.memo,
    required this.category,
    required this.date,
  });

  Color get categoryColor => kCategoryColors[category] ?? Colors.grey;

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
