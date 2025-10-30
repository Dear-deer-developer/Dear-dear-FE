import 'package:get/get.dart';
// ⛔️ 삭제: import 'package:collection/collection.dart';
import 'package:dear_deer_demo/model/schedule.dart' as sch;
import 'package:dear_deer_demo/service/schedule_service.dart';

class ScheduleController extends GetxController {
  ScheduleController(this._svc);
  final ScheduleService _svc;

  final RxMap<DateTime, List<sch.Schedule>> monthly =
      <DateTime, List<sch.Schedule>>{}.obs;
  final RxList<sch.Schedule> daily = <sch.Schedule>[].obs;
  final RxMap<int, int> monthlyVersion = <int, int>{}.obs;

  int _yyyymm(DateTime d) => d.year * 100 + d.month;
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  void _bump(DateTime d) {
    final k = _yyyymm(d);
    monthlyVersion[k] = (monthlyVersion[k] ?? 0) + 1;
  }

  Future<void> loadMonthly(int year, int month) async {
    final list = await _svc.fetchMonthly(year, month);
    final map = <DateTime, List<sch.Schedule>>{};
    for (final s in list) {
      final key = _dateOnly(s.date);
      (map[key] ??= []).add(s);
    }
    final toRemove = monthly.keys
        .where((k) => k.year == year && k.month == month)
        .toList(growable: false);
    for (final k in toRemove) {
      monthly.remove(k);
    }
    monthly.addAll(map);
    _bump(DateTime(year, month, 1));
  }

  Future<void> loadDaily(DateTime day) async {
    final list = await _svc.fetchDaily(_dateOnly(day));
    daily.assignAll(list.map((e) => e.copyWith(date: _dateOnly(e.date))));
  }

  Future<void> addEvent(sch.Schedule draft) async {
    final created = await _svc.create(draft, asDateOnly: false); // ✅
    final k = _dateOnly(created.date);
    final cur = monthly[k] ?? <sch.Schedule>[];
    monthly[k] = [...cur, created];
    _bump(created.date);
  }

  Future<sch.Schedule> editEvent(int id, sch.Schedule changed) async {
    sch.Schedule? before;
    try {
      before = daily.firstWhere((e) => e.id == id);
    } catch (_) {
      try {
        before = monthly.values.expand((e) => e).firstWhere((e) => e.id == id);
      } catch (_) {
        before = null;
      }
    }

    final updated = await _svc.update(id, changed, asDateOnly: false); // ✅

    final beforeKey = _dateOnly((before?.date ?? updated.date));
    final afterKey = _dateOnly(updated.date);

    // old day에서 제거
    final oldList = [...(monthly[beforeKey] ?? const <sch.Schedule>[])];
    oldList.removeWhere((e) => e.id == id);
    if (oldList.isEmpty) {
      monthly.remove(beforeKey);
    } else {
      monthly[beforeKey] = oldList;
    }
    _bump(beforeKey);

    // new day에 삽입/갱신
    final newList = [...(monthly[afterKey] ?? const <sch.Schedule>[])];
    final idx = newList.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      newList[idx] = updated;
    } else {
      newList.add(updated);
    }
    monthly[afterKey] = newList;
    _bump(afterKey);

    // daily 갱신
    final i = daily.indexWhere((e) => e.id == id);
    if (i >= 0) {
      final sameDay = _dateOnly(daily[i].date) == _dateOnly(updated.date);
      if (sameDay) {
        daily[i] = updated;
        daily.refresh();
      } else {
        final copy = [...daily]..removeAt(i);
        daily.assignAll(copy);
      }
    }
    return updated;
  }

  Future<void> removeEvent(int id) async {
    sch.Schedule? target;
    try {
      target = daily.firstWhere((e) => e.id == id);
    } catch (_) {
      try {
        target = monthly.values.expand((e) => e).firstWhere((e) => e.id == id);
      } catch (_) {
        target = null;
      }
    }

    await _svc.delete(id);

    if (target != null) {
      final key = _dateOnly(target.date);
      final list = [...(monthly[key] ?? const <sch.Schedule>[])];
      list.removeWhere((e) => e.id == id);
      if (list.isEmpty) {
        monthly.remove(key);
      } else {
        monthly[key] = list;
      }
      _bump(target.date);

      final di = daily.indexWhere((e) => e.id == id);
      if (di >= 0) {
        final copy = [...daily]..removeAt(di);
        daily.assignAll(copy);
      }
    }
  }
}
