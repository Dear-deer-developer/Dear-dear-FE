import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalendarController extends GetxController {
  final ScrollController scrollController = ScrollController();

  // 밤/낮 상태 (홈이랑 동일하게 사용 가능)
  final RxBool isNight = false.obs;
  Timer? _timer;

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

  @override
  void onInit() {
    super.onInit();
    _recompute(); // 첫 계산
    _scheduleNextTick(); // 다음 경계(07:00/18:00)에 갱신
  }

  void scrollUp() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeIn,
    );
  }

  // ---- 밤/낮 계산 로직 (HomeController와 동일) ----

  void _recompute() {
    // 한국 시간 기준 (KST)
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    final hour = now.hour;
    isNight.value = (hour < 7 || hour >= 18);
  }

  void _scheduleNextTick() {
    _timer?.cancel();

    // KST 현재시간
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    final hour = now.hour;

    // 다음 경계(07:00 / 18:00) 계산도 KST 기준으로 해야 함!
    DateTime nextBoundaryKst;
    if (hour < 7) {
      nextBoundaryKst = DateTime(now.year, now.month, now.day, 7);
    } else if (hour < 18) {
      nextBoundaryKst = DateTime(now.year, now.month, now.day, 18);
    } else {
      // 내일 07:00
      final tomorrow = now.add(const Duration(days: 1));
      nextBoundaryKst =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 7);
    }

    // diff 계산도 KST 기준
    final diff = nextBoundaryKst.difference(now);

    _timer = Timer(diff, () {
      _recompute();
      _scheduleNextTick();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ---- 일정 관련 기존 로직들 그대로 유지 ----

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
