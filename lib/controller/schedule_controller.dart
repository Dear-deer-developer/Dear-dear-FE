import 'package:get/get.dart';
import 'package:collection/collection.dart';

import 'package:dear_deer_demo/model/schedule.dart';
import 'package:dear_deer_demo/service/schedule_service.dart';

class ScheduleController extends GetxController {
  ScheduleController(this._svc);
  final ScheduleService _svc;

  final RxMap<DateTime, List<Schedule>> monthly =
      <DateTime, List<Schedule>>{}.obs;
  final RxList<Schedule> daily = <Schedule>[].obs;
  final RxMap<int, int> monthlyVersion = <int, int>{}.obs;

  int _yyyymm(DateTime d) => d.year * 100 + d.month;
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  void _bump(DateTime d) {
    final k = _yyyymm(d);
    monthlyVersion[k] = (monthlyVersion[k] ?? 0) + 1;
  }

  Future<void> loadMonthly(int year, int month) async {
    final list = await _svc.fetchMonthly(year, month);

    final map = <DateTime, List<Schedule>>{};
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

  Future<void> addEvent(Schedule draft) async {
    final created = await _svc.create(draft, asDateOnly: true);
    final k = _dateOnly(created.date);
    final cur = monthly[k] ?? <Schedule>[];
    monthly[k] = [...cur, created];
    _bump(created.date);
  }

  Future<Schedule> editEvent(int id, Schedule changed) async {
    Schedule? before = daily.firstWhereOrNull((e) => e.id == id) ??
        monthly.values.expand((e) => e).firstWhereOrNull((e) => e.id == id);

    final updated = await _svc.update(id, changed, asDateOnly: true);

    final beforeKey = _dateOnly(before?.date ?? updated.date);
    final afterKey = _dateOnly(updated.date);

    final oldList = [...(monthly[beforeKey] ?? const <Schedule>[])];
    oldList.removeWhere((e) => e.id == id);
    if (oldList.isEmpty) {
      monthly.remove(beforeKey);
    } else {
      monthly[beforeKey] = oldList;
    }
    _bump(beforeKey);

    final newList = [...(monthly[afterKey] ?? const <Schedule>[])];
    final idx = newList.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      newList[idx] = updated;
    } else {
      newList.add(updated);
    }
    monthly[afterKey] = newList;
    _bump(afterKey);

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
    final target = daily.firstWhereOrNull((e) => e.id == id) ??
        monthly.values.expand((e) => e).firstWhereOrNull((e) => e.id == id);

    await _svc.delete(id);

    if (target != null) {
      final key = _dateOnly(target.date);
      final list = [...(monthly[key] ?? const <Schedule>[])];
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
