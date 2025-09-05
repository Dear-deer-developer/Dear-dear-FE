import 'dart:convert';

import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final Rxn<DeardeerUser> me = Rxn<DeardeerUser>();

  @override
  void onInit() {
    _restoreFromCache(); // 1) 캐시 선적용
    refreshMe(); // 2) 서버 최신화
    super.onInit();
  }

  // === 게터들 (뷰에서 사용) ===
  String getUserName() => me.value?.nickname ?? '';
  String getZipCodeText() {
    final zc = me.value?.zipCode ?? 0;
    // 0 이거나 미설정이면 대시로 표시
    return zc > 0 ? zc.toString() : '--';
  }

  int getProfileImageIdx() {
    // 백엔드가 imageIdx를 주면 모델에 추가해 여기에 매핑
    return 0;
  }

  /// 서버에서 최신 유저 정보 가져와서 반영
  Future<void> refreshMe() async {
    final api = Get.find<ApiService>();
    final auth = Get.find<AuthService>();

    final DeardeerUser? fetched = await api.getUser();
    if (fetched != null) {
      me.value = fetched; // 로컬 상태
      auth.user.value = fetched; // 전역 상태(다른 화면에서도 반응)
    }
  }

  // === 내부: 캐시 복구 ===
  void _restoreFromCache() {
    final raw = sharedPreferences.getString('user_json');
    if (raw == null || raw.isEmpty) return;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final cached = DeardeerUser.fromJson(map);

      // 로컬/전역 동기화
      me.value = cached;
      if (Get.isRegistered<AuthService>()) {
        Get.find<AuthService>().user.value = cached;
      }
    } catch (_) {
      // 캐시 파싱 실패는 무시
    }
  }
}
