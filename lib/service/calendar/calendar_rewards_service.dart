import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/model/calendar/calendar_reward.dart';

class CalendarRewardsService extends GetxService {
  final ApiService api;
  CalendarRewardsService(this.api);

  Future<CalendarReward> enter() async {
    final res = await api.guardedPostJson('/calendar-rewards/enter', {});
    debugPrint('📮 /calendar-rewards/enter status=${res.statusCode}');
    final body = res.bodyString;

    if (body == null || body.trim().isEmpty) {
      debugPrint('⚠️ /calendar-rewards/enter 빈 응답(Body empty)');
      throw Exception('Empty body');
    }
    debugPrint('📦 /calendar-rewards/enter body: $body');

    if (res.statusCode == 200) {
      final map = jsonDecode(body) as Map<String, dynamic>;
      return CalendarReward.fromJson(map);
    }
    throw Exception('enter() 실패: ${res.statusCode} $body');
  }
}
