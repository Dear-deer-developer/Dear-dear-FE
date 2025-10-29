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

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

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

  int _monthVersion(DateTime m) {
    final yyyymm = m.year * 100 + m.month;
    return _sc.monthlyVersion[yyyymm] ?? 0;
  }

  // 월 그리드 점/반원 표시용
  List<CalendarEvent> _eventsFor(DateTime d) {
    final key = _dateOnly(d);
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

  // 바텀시트 리스트용
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
        CalendarCategoryMeta.uiFromLabel(label),
      );

  // "d-123" 또는 "m-...-123"에서 정수 id만 추출
  int? _scheduleIdFromEvent(CalendarEvent e) {
    if (e.id.startsWith('d-')) return int.tryParse(e.id.substring(2));
    final parts = e.id.split('-');
    return parts.isNotEmpty ? int.tryParse(parts.last) : null;
  }

  // 추가 시트 → 결과(await) → 닫힌 뒤 생성/로딩/바텀시트 오픈
  void _openAddSheet() async {
    final AddEventResult? result = await showModalBottomSheet<AddEventResult>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // 두 시트 모두 동일 네비게이터 사용
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEvent(initialDate: _selectedDate ?? _today),
    );

    if (result == null || !mounted) return;

    final draft = Schedule(
      id: 0,
      title: result.title,
      memo: result.memo,
      category: _enumFromUiLabel(result.uiCategory),
      date: _dateOnly(result.date),
    );

    await _sc.addEvent(draft);
    _selectedDate = draft.date;
    await _sc.loadDaily(_selectedDate!);
    if (!mounted) return;
    _openDailyBottomSheet(_selectedDate!);
  }

  Future<void> _openDailyBottomSheet(DateTime date) async {
    setState(() => _selectedDate = _dateOnly(date));
    await _sc.loadDaily(_selectedDate!);

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // 추가 시트와 동일하게 맞춤
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CalendarBottomSheet(
        date: _selectedDate!,
        events: _dailyUi(),
        onDeleteEvent: (evt) async {
          final id = _scheduleIdFromEvent(evt);
          if (id == null) return;
          await _sc.removeEvent(id);
          await _sc.loadDaily(_selectedDate!);
          if (mounted) setState(() {});
        },
        onEditEvent: (evt) async {
          final id = _scheduleIdFromEvent(evt);
          if (id == null) return;

          final changed = Schedule(
            id: id,
            title: evt.title,
            memo: evt.memo,
            category: _enumFromUiLabel(evt.category),
            date: _dateOnly(evt.date),
          );

          final updated = await _sc.editEvent(id, changed);
          final newDate = _dateOnly(updated.date);
          await _sc.loadDaily(newDate);

          if (!mounted) return;
          final moved = _dateOnly(evt.date) != newDate;
          if (moved) {
            Navigator.of(context).pop(); // 기존 시트 닫기
            await _openDailyBottomSheet(newDate); // 새 날짜로 다시 열기
          } else {
            setState(() {});
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
                  _selectedDate = _dateOnly(date);
                  await _sc.loadDaily(_selectedDate!);
                  if (!mounted) return;
                  await _openDailyBottomSheet(_selectedDate!);
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
