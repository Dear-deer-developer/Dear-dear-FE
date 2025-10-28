import 'package:flutter/material.dart';
import 'package:dear_deer_demo/model/schedule.dart' show ScheduleCategory;

/// UI에서 쓰는 카테고리(한글 라벨은 여기서 관리)
enum UiCategory { appointment, popup, ticketing, etc }

const Map<UiCategory, String> _labels = {
  UiCategory.appointment: '약속',
  UiCategory.popup: '팝업',
  UiCategory.ticketing: '티켓팅&예약',
  UiCategory.etc: '기타',
};

const Map<UiCategory, Color> _colors = {
  UiCategory.appointment: Colors.red,
  UiCategory.popup: Colors.green,
  UiCategory.ticketing: Colors.yellow,
  UiCategory.etc: Colors.black,
};

/// 낮을수록 우선 (약속 > 팝업 > 티켓팅&예약 > 기타)
const Map<UiCategory, int> _priority = {
  UiCategory.appointment: 0,
  UiCategory.popup: 1,
  UiCategory.ticketing: 2,
  UiCategory.etc: 3,
};

class CalendarCategoryMeta {
  // ===== Label / Color / Priority (UI 기준) =====
  static List<String> get labels =>
      UiCategory.values.map(labelOf).toList(growable: false);

  static String labelOf(UiCategory u) => _labels[u]!;
  static Color colorOf(UiCategory u) => _colors[u]!;
  static int priorityOf(UiCategory u) => _priority[u]!;

  static UiCategory uiFromLabel(String label) => _labels.entries
      .firstWhere((e) => e.value == label, orElse: () => _labels.entries.last)
      .key;

  // ===== 서버 enum <-> UI 매핑 =====
  static UiCategory uiFromServer(ScheduleCategory s) {
    switch (s) {
      case ScheduleCategory.appointment:
        return UiCategory.appointment;
      case ScheduleCategory.popup:
        return UiCategory.popup;
      case ScheduleCategory.ticketing:
        return UiCategory.ticketing;
      case ScheduleCategory.etc:
        return UiCategory.etc;
    }
  }

  static ScheduleCategory serverFromUi(UiCategory u) {
    switch (u) {
      case UiCategory.appointment:
        return ScheduleCategory.appointment;
      case UiCategory.popup:
        return ScheduleCategory.popup;
      case UiCategory.ticketing:
        return ScheduleCategory.ticketing;
      case UiCategory.etc:
        return ScheduleCategory.etc;
    }
  }

  // ===== 라벨(String) 편의 함수 (기존 위젯 호환) =====
  static String labelFromServer(ScheduleCategory s) => labelOf(uiFromServer(s));
  static Color colorByLabel(String label) => colorOf(uiFromLabel(label));
  static int priorityByLabel(String label) => priorityOf(uiFromLabel(label));
}
