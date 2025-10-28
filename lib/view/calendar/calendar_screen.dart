import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dear_deer_demo/controller/schedule_controller.dart';
import 'package:dear_deer_demo/model/schedule.dart';

import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_view.dart';
import 'package:dear_deer_demo/view/calendar/calendar_bottom_sheet.dart';
import 'package:dear_deer_demo/view/calendar/calendar_add_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_category_meta.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _sc = Get.find<ScheduleController>();

  late final int _currentYear;
  late final List<DateTime> _months;
  final DateTime _today = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentYear = DateTime.now().year;
    _months = [DateTime(_currentYear, 11), DateTime(_currentYear, 12)];
    _selectedDate = _today;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final m in _months) {
        await _sc.loadMonthly(m.year, m.month);
      }
      await _sc.loadDaily(_selectedDate!);
      if (mounted) setState(() {});
    });
  }

  // 해당 월의 일정 개수 합계를 버전으로 사용 (월 변경 감지용)
  int _monthVersion(DateTime m) {
    final y = m.year, mo = m.month;
    int v = 0;
    _sc.monthly.forEach((day, list) {
      if (day.year == y && day.month == mo) v += list.length;
    });
    return v;
  }

  // 점/반원: monthly 기반(제목/메모 없음)
  List<CalendarEvent> _eventsFor(DateTime d) {
    final key = DateTime(d.year, d.month, d.day);
    final schedules = _sc.monthly[key] ?? const <Schedule>[];
    return [
      for (final s in schedules)
        CalendarEvent(
          id: 'm-${key.toIso8601String()}-${s.id}',
          title: '',
          memo: '',
          category: CalendarCategoryMeta.labelFromServer(s.category),
          date: s.date,
        )
    ];
  }

  // 바텀시트: daily 기반(제목/메모 포함)
  List<CalendarEvent> _dailyUi() {
    return [
      for (final s in _sc.daily)
        CalendarEvent(
          id: 'd-${s.id}',
          title: s.title,
          memo: s.memo,
          category: CalendarCategoryMeta.labelFromServer(s.category),
          date: s.date,
        )
    ];
  }

  ScheduleCategory _enumFromUiLabel(String label) =>
      CalendarCategoryMeta.serverFromUi(
          CalendarCategoryMeta.uiFromLabel(label));

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEvent(
        initialDate: _selectedDate ?? _today,
        onAddEvent: (date, title, memo, uiLabel) async {
          final draft = Schedule(
            id: 0,
            title: title,
            memo: memo,
            category: _enumFromUiLabel(uiLabel),
            date: DateTime(date.year, date.month, date.day),
          );
          await _sc.addEvent(draft); // 생성 + monthly 갱신
          await _sc.loadDaily(draft.date); // 바텀시트용 최신
          if (!mounted) return;
          _openDailyBottomSheet(draft.date);
        },
      ),
    );
  }

  Future<void> _openDailyBottomSheet(DateTime date) async {
    setState(() => _selectedDate = date);
    await _sc.loadDaily(date);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CalendarBottomSheet(
        date: date,
        events: _dailyUi(),
        onDeleteEvent: (evt) async {
          final target = _sc.daily.firstWhereOrNull(
            (s) =>
                s.title == evt.title &&
                s.memo == evt.memo &&
                s.date == evt.date,
          );
          if (target != null) {
            await _sc.removeEvent(target.id);
            await _sc.loadDaily(date);
            if (mounted) setState(() {});
          }
        },
        onEditEvent: (evt) async {
          final target = _sc.daily.firstWhereOrNull(
            (s) =>
                s.title == evt.title &&
                s.memo == evt.memo &&
                s.date == evt.date,
          );
          final use = target ??
              _sc.daily.firstWhereOrNull((s) =>
                  CalendarCategoryMeta.labelFromServer(s.category) ==
                      evt.category &&
                  s.date == evt.date);
          if (use != null) {
            final changed = Schedule(
              id: use.id,
              title: evt.title,
              memo: evt.memo,
              category: _enumFromUiLabel(evt.category),
              date: DateTime(evt.date.year, evt.date.month, evt.date.day),
            );
            await _sc.editEvent(use.id, changed);
            await _sc.loadDaily(date);
            if (mounted) setState(() {});
          }
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
        onPressed: _openAddSheet,
        child: const Icon(Icons.add, size: 40, color: Color(0xFFA14E4A)),
      ),
      body: SafeArea(
        child: Obx(() {
          final _ = _sc.monthly.length;
          final __ = _sc.daily.length;

          return PageView.builder(
            itemCount: _months.length,
            onPageChanged: (i) async {
              final m = _months[i];
              await _sc.loadMonthly(m.year, m.month);
              if (mounted) setState(() {});
            },
            itemBuilder: (context, index) {
              final monthDate = _months[index];
              final version = _monthVersion(monthDate);

              return CalendarView(
                key: ValueKey(
                    'cv-${monthDate.year}-${monthDate.month}-$version'),
                monthDate: monthDate,
                selectedDate: _selectedDate,
                today: _today,
                getEventsForDate: _eventsFor,
                onDayTap: (date) async {
                  _selectedDate = date;
                  await _sc.loadDaily(date);
                  if (!mounted) return;
                  await _openDailyBottomSheet(date);
                },
                dataVersion: version,
              );
            },
          );
        }),
      ),
    );
  }
}
