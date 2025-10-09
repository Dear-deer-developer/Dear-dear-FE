// lib/controller/app_start_controller.dart
import 'package:get/get.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/service/fcm_token_service.dart';

class AppStartController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  bool _registered = false;

  Worker? _userWatcher; // ✅ ever 구독 해제용

  @override
  void onInit() {
    super.onInit();

    // 이미 로그인된 상태로 앱이 열렸을 때도 커버
    if (_auth.user.value != null) {
      _registerOnce();
    }

    // 이후 로그인/로그아웃 변화 감시
    _userWatcher = ever(_auth.user, (user) async {
      if (user != null) {
        _registerOnce();
      } else {
        // 필요 시 로그아웃 시 토큰 해제 API 호출도 여기에
        // await FcmTokenService.unregisterToken();
        _registered = false; // 다음 로그인 때 다시 등록
      }
    });
  }

  Future<void> _registerOnce() async {
    if (_registered) return;
    _registered = true;
    try {
      await FcmTokenService.registerToken(); // 내부에서 onTokenRefresh도 등록
      // 성공적으로 끝나면 그대로 true 유지
    } catch (e) {
      // 실패 시 다시 시도할 수 있도록 플래그 복구
      _registered = false;
      // 원하면 로그 출력/스낵바 등 처리
      // logger.e('[FCM] register failed: $e');
    }
  }

  @override
  void onClose() {
    _userWatcher?.dispose(); // ✅ ever 구독 해제
    super.onClose();
  }
}
