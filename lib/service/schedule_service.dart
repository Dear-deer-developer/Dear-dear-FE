import 'package:get/get.dart';
import '../model/schedule.dart';
import '../util/custom_get_connect.dart'; // 너의 래퍼
import '../util/logger.dart'; // 있으면 사용

class ScheduleService extends GetxService {
  final CustomGetConnect _api;

  // baseUrl은 custom_get_connect 안에서 지정돼 있다면 생략 가능.
  ScheduleService(this._api);

  // 월별: [{id, category, date}]
  Future<List<Schedule>> fetchMonthly(int year, int month) async {
    final res = await _api.get(
      '/api/v1/schedules/monthly',
      query: {'year': '$year', 'month': '$month'},
    );
    _throwIfNotOk(res);
    final list = (res.body as List).map<Schedule>((e) {
      // monthly는 title/memo 없음 → 빈값으로
      final cat = catFromApi(e['category']);
      return Schedule(
        id: (e['id'] as num).toInt(),
        title: '',
        memo: '',
        category: cat,
        date: DateTime.parse(e['date']),
      );
    }).toList();
    return list;
  }

  // 일별: 전체 필드
  Future<List<Schedule>> fetchDaily(DateTime day) async {
    final res = await _api.get(
      '/api/v1/schedules/daily',
      query: {'date': _yyyyMmDd(day)},
    );
    _throwIfNotOk(res);
    return (res.body as List)
        .map<Schedule>((e) => Schedule.fromJson(e))
        .toList();
  }

  Future<Schedule> create(Schedule draft, {bool asDateOnly = true}) async {
    final res = await _api.post(
        '/api/v1/schedules', draft.toBody(asDateOnly: asDateOnly));
    _throwIfNotOk(res, expect: [201]);
    return Schedule.fromJson(res.body);
  }

  Future<Schedule> update(int id, Schedule changed,
      {bool asDateOnly = true}) async {
    final res = await _api.patch(
        '/api/v1/schedules/$id', changed.toBody(asDateOnly: asDateOnly));
    _throwIfNotOk(res);
    return Schedule.fromJson(res.body);
  }

  Future<void> delete(int id) async {
    final res = await _api.delete('/api/v1/schedules/$id');
    _throwIfNotOk(res, expect: [204]);
  }

  String _yyyyMmDd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _throwIfNotOk(Response res, {List<int> expect = const [200]}) {
    if (!expect.contains(res.statusCode)) {
      // logger.w('Schedule API error: ${res.statusCode} ${res.bodyString}');
      throw 'API ${res.request?.url} → ${res.statusCode}';
    }
  }
}
