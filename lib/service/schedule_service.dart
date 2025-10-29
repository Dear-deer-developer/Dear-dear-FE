import 'package:get/get.dart';

import 'package:dear_deer_demo/model/schedule.dart';
import 'calendar/calendar_service.dart';

/// 기존 호출부 호환용 어댑터
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
