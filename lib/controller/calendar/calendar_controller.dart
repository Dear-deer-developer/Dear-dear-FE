import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CalendarController extends GetxController {
  final ScrollController scrollController = ScrollController();

  void scrollUp() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 700), curve: Curves.easeIn);
  }

  // 현재 날짜를 저장합니다. (앱 실행 시점의 날짜)
  final DateTime now = DateTime.now();

  // 사용자가 선택한 첫 번째 날짜 (반응형 변수)
  final Rxn<DateTime> selectedDt1 = Rxn<DateTime>();

  // 사용자가 선택한 두 번째 날짜 (반응형 변수)
  final Rxn<DateTime> selectedDt2 = Rxn<DateTime>();

  // 달력에서 선택한 날짜
  Rx<DateTime> selectedDate = DateTime.now().obs;

  // 날짜별 일정 목록을 저장하는 맵
  RxMap<String, List<String>> events = <String, List<String>>{}.obs;

  // /// 연도와 월 업데이트
  // void updateYearAndMonth(int year, int month) {
  //   selectedYear.value = year;
  //   selectedMonth.value = month;
  // }

  /// 선택된 날짜 변경
  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  /// 일정 추가
  void addEvent(DateTime date, String event) {
    String key = _dateToString(date);
    if (events.containsKey(key)) {
      events[key]!.add(event);
    } else {
      events[key] = [event];
    }
    events.refresh(); // UI 갱신
  }

  /// 특정 날짜의 일정 목록 가져오기
  List<String> getEventsForDate(DateTime date) {
    return events[_dateToString(date)] ?? [];
  }

  /// 일정 삭제
  void deleteEvent(DateTime date, String event) {
    String key = _dateToString(date);
    if (events.containsKey(key)) {
      events[key]!.remove(event);
      if (events[key]!.isEmpty) {
        events.remove(key); // 일정이 없으면 해당 날짜 삭제
      }
      events.refresh(); // UI 갱신
    }
  }

  /// 날짜를 문자열로 변환 (Map 키로 사용)
  String _dateToString(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }
}
