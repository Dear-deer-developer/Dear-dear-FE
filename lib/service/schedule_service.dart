// lib/service/schedule_service.dart
import 'package:get/get.dart';

import 'package:dear_deer_demo/model/schedule.dart';
import 'calendar/calendar_service.dart';

/// 기존 컨트롤러/코드가 ScheduleService에 의존하므로,
/// 내부적으로 CalendarService로 위임하는 어댑터.
/// 새로 만드는 화면은 CalendarService를 직접 주입해도 됨.
class ScheduleService extends GetxService {
  final CalendarService _calendar;
  ScheduleService(this._calendar);

  Future<List<Schedule>> fetchMonthly(int year, int month) =>
      _calendar.fetchMonthly(year, month);

  Future<List<Schedule>> fetchDaily(DateTime day) => _calendar.fetchDaily(day);

  Future<Schedule> create(Schedule draft, {bool asDateOnly = true}) =>
      _calendar.create(draft, asDateOnly: asDateOnly);

  Future<Schedule> update(int id, Schedule changed, {bool asDateOnly = true}) =>
      _calendar.update(id, changed, asDateOnly: asDateOnly);

  Future<void> delete(int id) => _calendar.delete(id);
}
