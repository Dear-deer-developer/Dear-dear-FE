// lib/controller/schedule_controller.dart
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../model/schedule.dart';
import '../service/calendar/schedule_service.dart'; // 경로는 네가 쓴 폴더 기준

class ScheduleController extends GetxController {
  ScheduleController(this.api);
  final ScheduleService api;

  /// 날짜별 스케줄 (로컬 자정 키)
  final RxMap<DateTime, List<Schedule>> monthly =
      <DateTime, List<Schedule>>{}.obs;

  /// 선택일의 상세 목록(바텀시트용)
  final RxList<Schedule> daily = <Schedule>[].obs;

  /// 월별 데이터 변경 버전 (yyyy*100 + mm → version)
  final RxMap<int, int> monthlyVersion = <int, int>{}.obs;

  int _keyOfMonth(int y, int m) => y * 100 + m;

  /// 해당 월 키들을 싹 지운다.
  void _clearMonthBucket(int year, int month) {
    final toRemove = <DateTime>[];
    for (final d in monthly.keys) {
      if (d.year == year && d.month == month) toRemove.add(d);
    }
    for (final k in toRemove) {
      monthly.remove(k);
    }
  }

  Future<void> loadMonthly(int year, int month) async {
    final items = await api.fetchMonthly(year, month);
    // 1) 기존 월 데이터 삭제
    _clearMonthBucket(year, month);

    // 2) 일자별로 다시 채우기 (date는 이미 서비스에서 로컬자정)
    for (final s in items) {
      final dayKey = DateTime(s.date.year, s.date.month, s.date.day);
      final list = monthly[dayKey] ?? <Schedule>[];
      list.add(s);
      monthly[dayKey] = list;
    }

    // 3) 강제 트리거
    monthly.refresh();
    final k = _keyOfMonth(year, month);
    monthlyVersion[k] = (monthlyVersion[k] ?? 0) + 1;
    monthlyVersion.refresh();
  }

  Future<void> loadDaily(DateTime day) async {
    final items = await api.fetchDaily(day);
    daily
      ..clear()
      ..addAll(items);
    daily.refresh();
  }

  Future<void> addEvent(Schedule draft) async {
    final created = await api.create(draft, asDateOnly: true);
    // 생성된 날짜의 월만 리프레시
    await loadMonthly(created.date.year, created.date.month);
  }

  Future<void> editEvent(int id, Schedule changed) async {
    final updated = await api.update(id, changed, asDateOnly: true);
    await loadMonthly(updated.date.year, updated.date.month);
  }

  Future<void> removeEvent(int id) async {
    // 삭제 전에 대상 찾기(월 리프레시 범위 산정)
    final entry =
        monthly.entries.firstWhereOrNull((e) => e.value.any((s) => s.id == id));
    await api.delete(id);
    if (entry != null) {
      await loadMonthly(entry.key.year, entry.key.month);
    }
  }
}
