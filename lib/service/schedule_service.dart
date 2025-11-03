import 'package:get/get.dart';
import 'package:dear_deer_demo/model/calendar/schedule.dart' as sch;
import 'calendar/calendar_service.dart';

class ScheduleService extends GetxService {
  final CalendarService _calendar;
  ScheduleService(this._calendar);

  Future<List<sch.Schedule>> fetchMonthly(int year, int month) =>
      _calendar.fetchMonthly(year, month);

  Future<List<sch.Schedule>> fetchDaily(DateTime day) =>
      _calendar.fetchDaily(day);

  Future<sch.Schedule> create(sch.Schedule draft, {bool asDateOnly = true}) =>
      _calendar.create(draft, asDateOnly: asDateOnly);

  Future<sch.Schedule> update(int id, sch.Schedule changed,
          {bool asDateOnly = true}) =>
      _calendar.update(id, changed, asDateOnly: asDateOnly);

  Future<void> delete(int id) => _calendar.delete(id);
}
