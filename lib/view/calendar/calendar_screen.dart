import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:dear_deer_demo/controller/schedule_controller.dart';
import 'package:dear_deer_demo/model/schedule.dart';

import 'package:dear_deer_demo/view/calendar/calendar_view.dart';
import 'package:dear_deer_demo/view/calendar/calendar_bottom_sheet.dart';
import 'package:dear_deer_demo/view/calendar/calendar_add_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_category_meta.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _sc = Get.find<ScheduleController>();
  final _uuid = const Uuid();

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

    // 최초 진입: 두 달 월데이터 + 선택일 일데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final m in _months) {
        try {
          await _sc.loadMonthly(m.year, m.month);
        } catch (_) {}
      }
      try {
        await _sc.loadDaily(_selectedDate!);
      } catch (_) {}
      if (mounted) setState(() {}); // 상단 선택바 첫 표기
    });
  }

  // ---- UI 변환 도우미 ----

  // 월 점/반원: category 정보만 필요 → monthly 사용
  List<CalendarEvent> _uiFromMonthly(DateTime d) {
    final key = DateTime(d.year, d.month, d.day);
    final list = _sc.monthly[key] ?? const <Schedule>[];
    return list
        .map((s) => CalendarEvent(
              id: _uuid.v4(),
              title: '', // monthly에는 제목/메모가 없음
              memo: '',
              category: CalendarCategoryMeta.labelFromServer(s.category),
              date: s.date,
            ))
        .toList();
  }

  // 바텀시트 리스트: 제목/메모 필요 → daily 사용
  List<CalendarEvent> _uiFromDaily() {
    return _sc.daily
        .map((s) => CalendarEvent(
              id: '${s.id}',
              title: s.title,
              memo: s.memo,
              category: CalendarCategoryMeta.labelFromServer(s.category),
              date: s.date,
            ))
        .toList();
  }

  ScheduleCategory _serverCatFromLabel(String label) =>
      CalendarCategoryMeta.serverFromUi(
          CalendarCategoryMeta.uiFromLabel(label));

  // ---- 액션 ----

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
          // AddEvent에서 먼저 pop() 호출됨 → 여기서는 생성 & 갱신
          final onlyDate = DateTime(date.year, date.month, date.day);
          final draft = Schedule(
            id: 0,
            title: title,
            memo: memo,
            category: _serverCatFromLabel(uiLabel),
            date: onlyDate,
          );

          try {
            await _sc.addEvent(draft); // 서버 생성 + 해당 월 재로딩
            await _sc.loadDaily(onlyDate); // 바텀시트용 일 데이터 재로딩
            if (!mounted) return;
            await _openDailyBottomSheet(onlyDate);
          } catch (e) {
            // TODO: 필요시 스낵바로 실패 안내
          }
        },
      ),
    );
  }

  Future<void> _openDailyBottomSheet(DateTime date) async {
    setState(() => _selectedDate = date);
    try {
      await _sc.loadDaily(date); // 제목/메모 확보
    } catch (_) {}

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CalendarBottomSheet(
        date: date,
        events: _uiFromDaily(),
        onDeleteEvent: (evt) async {
          final target = _sc.daily.firstWhereOrNull((s) =>
              s.id.toString() == evt.id ||
              (s.title == evt.title &&
                  s.memo == evt.memo &&
                  s.date == evt.date));
          if (target != null) {
            try {
              await _sc.removeEvent(target.id);
              await _sc.loadDaily(date);
              if (mounted) setState(() {});
            } catch (_) {}
          }
        },
        onEditEvent: (evt) async {
          final target = _sc.daily.firstWhereOrNull((s) =>
              s.id.toString() == evt.id ||
              (s.title == evt.title && s.date == evt.date));
          if (target != null) {
            final changed = Schedule(
              id: target.id,
              title: evt.title,
              memo: evt.memo,
              category: _serverCatFromLabel(evt.category),
              date: DateTime(evt.date.year, evt.date.month, evt.date.day),
            );
            try {
              await _sc.editEvent(target.id, changed);
              await _sc.loadDaily(date);
              if (mounted) setState(() {});
            } catch (_) {}
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
          // 월 데이터 "내용"까지 반영한 digest → 반드시 리빌드
          final monthlyDigest = _sc.monthly.entries.fold<int>(
            _sc.monthly.length,
            (acc, e) {
              final keyHash = e.key.year ^ e.key.month ^ e.key.day;
              final len = e.value.length;
              // 일정 id 섞어서 내용 변화까지 반영
              final idsXor = e.value.fold<int>(0, (a, s) => a ^ s.id);
              return acc ^ keyHash ^ len ^ idsXor;
            },
          );

          return PageView.builder(
            itemCount: _months.length,
            onPageChanged: (i) async {
              final m = _months[i];
              try {
                await _sc.loadMonthly(m.year, m.month);
              } catch (_) {}
              if (mounted) setState(() {}); // 점/상단바 갱신
            },
            itemBuilder: (context, index) {
              final monthDate = _months[index];
              return CalendarView(
                key: ValueKey(
                    'cal-${monthDate.year}-${monthDate.month}-$monthlyDigest'),
                monthDate: monthDate,
                selectedDate: _selectedDate,
                today: _today,
                getEventsForDate: _uiFromMonthly,
                onDayTap: (date) async {
                  _selectedDate = date;
                  try {
                    await _sc.loadDaily(date);
                  } catch (_) {}
                  if (!mounted) return;
                  await _openDailyBottomSheet(date);
                },
                dataVersion: monthlyDigest,
              );
            },
          );
        }),
      ),
    );
  }
}
