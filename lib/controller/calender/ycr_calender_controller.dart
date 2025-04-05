import 'package:get/get.dart';

class YcrCalenderController extends GetxController {
  var selectedDate = DateTime.now().obs; // 선택된 날짜
  var focusedDate = DateTime.now().obs; // 포커스된 날짜
  var daysToChristmas = 0.obs; // 크리스마스까지 남은 D-Day
  var events = <DateTime, List<String>>{}.obs; // 날짜별 이벤트 저장

// 초기 디데이를 계산하고, focusedDate가 바뀔 때마다 calculateDaysToChristmas() 자동 호출
// 반응형 변수를 감지하여 콜백하는 기능
  @override
  void onInit() {
    super.onInit();
    calculateDaysToChristmas();
    ever(focusedDate, (_) => calculateDaysToChristmas());
  }

  //MARK: 일정 추가 메소드
  // 특정 날짜에 이벤트를 추가하는 메서드 날짜별로 리스트에 추가됨
  void addEvent(DateTime date, String event) {
    if (events[date] == null) {
      events[date] = [];
    }
    events[date]?.add(event);
  }

  //MARK: 특정 날짜의 일정 가져오기
  // 전달한 날에 맞추어 이벤트를 출력함
  // 없다면 일정이 없습니다. 빈 리스트를 반환
  List<String> getEventsForDay(DateTime date) {
    return events[date] ?? [];
  }

  //MARK: 크리스마스까지 남은 D-Day 계산 (포커스된 날짜 기준)
  // 현재 날짜가 크리스마스를 지난 경우 다음 해의 크리스마스로 계산
  void calculateDaysToChristmas() {
    final now = focusedDate.value;
    final currentYearChristmas = DateTime(now.year, 12, 25);

    final christmas = now.isAfter(currentYearChristmas)
        ? DateTime(now.year + 1, 12, 25)
        : currentYearChristmas;

    daysToChristmas.value = christmas.difference(now).inDays;
  }

  //MARK: 특정 날짜 기준으로 크리스마스까지 남은 D-Day 계산
  int calculateDaysToChristmasForDate(DateTime date) {
    final currentYearChristmas = DateTime(date.year, 12, 25);

    //MARK: 클릭한 날짜가 크리스마스를 지난 경우 다음 해의 크리스마스로 계산
    final christmas = date.isAfter(currentYearChristmas)
        ? DateTime(date.year + 1, 12, 25)
        : currentYearChristmas;

    return christmas.difference(date).inDays;
  }

  //MARK: 캘린더에서 선택된 날짜를 업데이트하는 메서드
  // refresh()를 통해 UI 강제 갱신
  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  void deleteEvent(DateTime date, String event) {
    if (events[date] != null) {
      events[date]!.remove(event);
      if (events[date]!.isEmpty) {
        events.remove(date);
      }
      events.refresh();
    }
  }
}
