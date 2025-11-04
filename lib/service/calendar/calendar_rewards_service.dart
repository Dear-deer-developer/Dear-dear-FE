import 'dart:convert';
import 'package:get/get.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/model/calendar/calendar_reward.dart';

class CalendarRewardsService extends GetxService {
  final ApiService api;
  CalendarRewardsService(this.api);

  Future<CalendarReward> enter() async {
    // 서버에 바디 필요 없으면 {} 전달, 401 시 자동 재시도는 guardedPostJson 사용 가능
    final res = await api.guardedPostJson('/calendar-rewards/enter', {});
    if (res.statusCode == 200 && res.bodyString?.isNotEmpty == true) {
      final map = jsonDecode(res.bodyString!) as Map<String, dynamic>;
      return CalendarReward.fromJson(map);
    }
    throw Exception(
        'enter() 실패: ${res.statusCode} ${res.bodyString ?? '(no body)'}');
  }
}
