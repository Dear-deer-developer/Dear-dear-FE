import 'package:get/get.dart';

class CalendarController extends GetxController {
  // 현재 선택된 연도와 월
  var selectedYear = 2025.obs;
  var selectedMonth = 3.obs;

  // 달력에서 선택한 날짜
  Rx<DateTime> selectedDate = DateTime.now().obs;

  // 날짜별 일정 목록을 저장하는 맵
  RxMap<String, List<String>> events = <String, List<String>>{}.obs;

  /// 연도와 월 업데이트
  void updateYearAndMonth(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
  }

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