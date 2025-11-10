import 'package:dear_deer_demo/data/calendar/reward_schedule.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/model/calendar/calendar_reward.dart';
import 'package:dear_deer_demo/service/calendar/calendar_rewards_service.dart';
import 'package:dear_deer_demo/data/debug_flags.dart';
import 'package:intl/intl.dart';

typedef ShowRewardDialog = Future<void> Function(CalendarReward reward);

class CalendarRewardsController extends GetxController {
  CalendarRewardsController(this._svc);
  final CalendarRewardsService _svc;

  /// 서버 결과에 따라 보상 팝업을 필요 시 1회 표시
  /// 디버그 모드에서는 날짜 기반으로 자동 지급 (11/1~12/25)
  Future<void> tryEnterAndShow(ShowRewardDialog showDialog) async {
    try {
      CalendarReward r;

      if (kDebugForceRewardPopup) {
        // 로컬 날짜 기반 지급 (11/1~12/25)
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final giftName = getRewardForToday(); // 날짜별 선물 가져오기

        if (giftName == null) return; // 11/1~12/25 사이가 아니면 패스

        r = CalendarReward(
          awarded: true,
          giftName: giftName,
          localDate: today,
          giftId: 0,
          awardedAt: DateTime.now(),
        );
      } else {
        // ✅ 실제 서버 호출
        r = await _svc.enter();
      }

      if (!r.awarded) return;
      await showDialog(r);
    } catch (e, st) {
      print('❌ [CalendarRewardsController] tryEnterAndShow() 예외: $e');
      print(st);
    }
  }
}
