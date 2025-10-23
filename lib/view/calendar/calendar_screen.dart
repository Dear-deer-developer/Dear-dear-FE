import 'package:dear_deer_demo/data/today_ex.dart';
import 'package:dear_deer_demo/view/calendar/calendar_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_add_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_view.dart';
import 'package:get/get.dart';

// 🔗 일정 컨트롤러 & 모델
import 'package:dear_deer_demo/controller/schedule_controller.dart';
import 'package:dear_deer_demo/model/schedule.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final int currentYear;
  late final List<DateTime> months;
  final PageController _pageController = PageController(initialPage: 0);

  // ⚠️ 로컬맵은 유지하되, 서버 동기화가 우선 (점/반원 UI만 쓰면 그대로 둬도 됨)
  Map<String, List<CalendarEvent>> _events = {};

  // 🔗 컨트롤러
  final sc = Get.find<ScheduleController>();

  @override
  void initState() {
    super.initState();
    currentYear = fakeToday.year;
    months = [
      DateTime(currentYear, 11),
      DateTime(currentYear, 12),
    ];
    _events = {};
    // 필요 시 월 데이터 선 로드 (dots/반원용)
    sc.loadMonthly(fakeToday.year, fakeToday.month);
  }

  String _formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return _events[_formatDateKey(date)] ?? [];
  }

  // 🔗 ScheduleCategory ↔︎ UI라벨
  ScheduleCategory _catFromLabel(String label) {
    switch (label) {
      case '약속':
        return ScheduleCategory.appointment;
      case '팝업':
        return ScheduleCategory.popup;
      case '티켓팅&예약':
        return ScheduleCategory.ticketing;
      default:
        return ScheduleCategory.etc;
    }
  }

  CalendarEvent _toUiEvent(Schedule s) => CalendarEvent(
        title: s.title,
        memo: s.memo,
        category: _labelFromCat(s.category),
      );

  String _labelFromCat(ScheduleCategory c) {
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

  Future<void> _openBottomSheetFromServer(DateTime date) async {
    await sc.loadDaily(date);
    final list = sc.daily.map(_toUiEvent).toList();
    _events[_formatDateKey(date)] = list; // 로컬맵도 동기화(점/반원용 유지시)
    _showCalendarBottomSheet(date, list);
  }

  void _showAddEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEvent(
        initialDate: fakeToday,
        onAddEvent: (date, title, memo, categoryLabel) async {
          // 🔗 서버 생성
          final schedule = Schedule(
            id: 0,
            title: title,
            memo: memo,
            category: _catFromLabel(categoryLabel),
            date: date,
          );
          try {
            await sc.addEvent(schedule);
            Navigator.pop(context);
            await _openBottomSheetFromServer(date);
          } catch (e) {
            Navigator.pop(context);
            Get.snackbar('저장 실패', '$e');
          }
        },
      ),
    );
  }

  void _showCalendarBottomSheet(DateTime date, [List<CalendarEvent>? preset]) {
    final events = preset ?? _getEventsForDate(date);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => CalendarBottomSheet(
        date: date,
        events: events,
        onDeleteEvent: (_) {
          // 삭제 UI를 BottomSheet에 추가하면 여기서 sc.removeEvent로 연결
          // 현재 시트 UI엔 삭제 버튼이 없어 no-op
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: _showAddEvent,
        child: const Icon(Icons.add, size: 40, color: Color(0xFFA14E4A)),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: months.length,
          itemBuilder: (context, index) => CalendarView(
            monthDate: months[index],
            onDayTap: (day) => _openBottomSheetFromServer(day),
          ),
        ),
      ),
    );
  }
}
