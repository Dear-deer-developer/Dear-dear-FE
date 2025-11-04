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
  /// (하루 1회 제한은 서버/백업 로직에 위임. 필요 시 SharedPreferences로 클라에서도 재도입 가능)
  Future<void> tryEnterAndShow(ShowRewardDialog showDialog) async {
    try {
      CalendarReward r = await _svc.enter();

      // 개발 중 강제 팝업(배포 전 false 유지)
      if (kDebugForceRewardPopup) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        r = r.copyWith(
          awarded: true,
          giftName: r.giftName ?? kDebugDefaultGiftName,
          localDate: r.localDate.isNotEmpty ? r.localDate : today,
        );
      }

      if (!r.awarded) return;
      await showDialog(r);
    } catch (_) {
      // 네트워크/파싱 오류 시 조용히 스킵
    }
  }
}
