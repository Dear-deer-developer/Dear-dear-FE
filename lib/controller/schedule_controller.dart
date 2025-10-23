import 'package:get/get.dart';
import '../model/schedule.dart';
import '../service/schedule_service.dart';

class ScheduleController extends GetxController {
  final ScheduleService service;
  ScheduleController(this.service);

  // 캘린더 점/반원용 월 데이터
  final monthly = <DateTime, List<Schedule>>{}.obs;
  // 바텀시트 리스트용 일 데이터
  final daily = <Schedule>[].obs;

  final isLoadingMonthly = false.obs;
  final isLoadingDaily = false.obs;

  // ===== READ =====
  Future<void> loadMonthly(int year, int month) async {
    isLoadingMonthly.value = true;
    try {
      final data = await service.fetchMonthly(year, month);
      final map = <DateTime, List<Schedule>>{};
      for (final s in data) {
        final k = DateTime(s.date.year, s.date.month, s.date.day);
        (map[k] ??= []).add(s);
      }
      monthly.value = map;
    } finally {
      isLoadingMonthly.value = false;
    }
  }

  Future<void> loadDaily(DateTime day) async {
    isLoadingDaily.value = true;
    try {
      daily.value = await service.fetchDaily(day);
      _sortByPriority();
    } finally {
      isLoadingDaily.value = false;
    }
  }

  // ===== CREATE =====
  Future<void> addEvent(Schedule draft) async {
    // UX: 낙관적 업데이트
    daily.add(draft);
    _sortByPriority();
    try {
      final created = await service.create(draft);
      final i = daily.indexOf(draft);
      if (i != -1) daily[i] = created;
      await loadMonthly(created.date.year, created.date.month);
    } catch (e) {
      daily.remove(draft);
      rethrow;
    }
  }

  // ===== UPDATE =====
  Future<void> editEvent(int id, Schedule changed) async {
    final i = daily.indexWhere((e) => e.id == id);
    if (i == -1) return;
    final old = daily[i];
    daily[i] = changed;
    _sortByPriority();
    try {
      final updated = await service.update(id, changed);
      daily[i] = updated;
      await loadMonthly(updated.date.year, updated.date.month);
    } catch (e) {
      daily[i] = old;
      rethrow;
    }
  }

  // ===== DELETE =====
  Future<void> removeEvent(int id) async {
    final i = daily.indexWhere((e) => e.id == id);
    if (i == -1) return;
    final removed = daily.removeAt(i);
    try {
      await service.delete(id);
      await loadMonthly(removed.date.year, removed.date.month);
    } catch (e) {
      daily.insert(i, removed);
      rethrow;
    }
  }

  // 우선순위: 약속 > 팝업 > 티켓팅&예약 > 기타
  void _sortByPriority() {
    int pri(Schedule s) {
      switch (s.category) {
        case ScheduleCategory.appointment:
          return 0;
        case ScheduleCategory.popup:
          return 1;
        case ScheduleCategory.ticketing:
          return 2;
        case ScheduleCategory.etc:
          return 3;
      }
    }

    daily.sort((a, b) {
      final p = pri(a).compareTo(pri(b));
      if (p != 0) return p;
      return a.date.compareTo(b.date);
    });
  }
}
